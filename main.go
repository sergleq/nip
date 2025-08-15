package main

import (
	"flag"
	"fmt"
	"os"
	"path/filepath"

	"github.com/sirupsen/logrus"

	"nip/internal"
)

var logger *logrus.Logger

func init() {
	// Инициализация логгера
	logger = logrus.New()
	logger.SetLevel(logrus.InfoLevel)
	logger.SetFormatter(&logrus.TextFormatter{
		FullTimestamp: true,
	})

	// Устанавливаем логгер для internal пакета
	internal.SetLogger(logger)
}

func main() {
	// Парсинг аргументов командной строки
	flag.Usage = func() {
		fmt.Fprintf(os.Stderr, "Использование: %s <URL>\n", os.Args[0])
		fmt.Fprintf(os.Stderr, "Преобразует веб-страницу в markdown файл\n\n")
		fmt.Fprintf(os.Stderr, "Аргументы:\n")
		fmt.Fprintf(os.Stderr, "  URL    URL веб-страницы для преобразования\n\n")
		fmt.Fprintf(os.Stderr, "Примеры:\n")
		fmt.Fprintf(os.Stderr, "  %s https://example.com\n", os.Args[0])
		fmt.Fprintf(os.Stderr, "  %s https://github.com/user/repo\n", os.Args[0])
	}

	flag.Parse()

	// Проверяем количество аргументов
	if flag.NArg() != 1 {
		fmt.Fprintf(os.Stderr, "Ошибка: требуется ровно один аргумент - URL\n\n")
		flag.Usage()
		os.Exit(1)
	}

	url := flag.Arg(0)

	// Проверка валидности URL
	if !internal.IsValidURL(url) {
		logger.Fatal("Неверный URL. Пожалуйста, укажите корректный URL")
	}

	// Отправляем сообщение о начале обработки
	fmt.Println("Обрабатываю URL:", url)

	// Извлекаем контент
	content, err := internal.ExtractContent(url)
	if err != nil {
		logger.Fatalf("Ошибка при извлечении контента: %v", err)
	}

	// Получаем локаль (используем русскую по умолчанию)
	locale := internal.GetLocale(nil) // nil для командной строки

	// Конвертируем в markdown
	markdown := internal.ConvertToMarkdown(content, url, locale)

	// Генерируем имя файла
	filename := internal.GenerateFilename(url, content.Title)

	// Получаем текущую директорию
	currentDir, err := os.Getwd()
	if err != nil {
		logger.Fatalf("Ошибка при получении текущей директории: %v", err)
	}

	// Создаем полный путь к файлу
	filePath := filepath.Join(currentDir, filename)

	// Записываем файл
	err = os.WriteFile(filePath, []byte(markdown), 0644)
	if err != nil {
		logger.Fatalf("Ошибка при записи файла: %v", err)
	}

	fmt.Printf("Файл успешно сохранен: %s\n", filePath)
	fmt.Printf("Размер файла: %d байт\n", len(markdown))
}
