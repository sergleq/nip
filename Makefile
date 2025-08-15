.PHONY: build clean test install uninstall help

# Переменные
BINARY_NAME=nip
VERSION=$(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
BUILD_TIME=$(shell date -u '+%Y-%m-%d_%H:%M:%S')
LDFLAGS=-ldflags "-X main.Version=${VERSION} -X main.BuildTime=${BUILD_TIME}"

# Цели по умолчанию
all: build

# Сборка
build:
	@echo "Сборка ${BINARY_NAME}..."
	go build ${LDFLAGS} -o ${BINARY_NAME} main.go
	@echo "Готово! Исполняемый файл: ${BINARY_NAME}"

# Сборка для релиза (без отладочной информации)
release:
	@echo "Сборка релизной версии ${BINARY_NAME}..."
	CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo ${LDFLAGS} -o ${BINARY_NAME} main.go
	@echo "Готово! Релизная версия: ${BINARY_NAME}"

# Сборка для разных платформ
build-linux:
	@echo "Сборка для Linux..."
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build ${LDFLAGS} -o ${BINARY_NAME}-linux-amd64 main.go

build-darwin:
	@echo "Сборка для macOS..."
	CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 go build ${LDFLAGS} -o ${BINARY_NAME}-darwin-amd64 main.go

build-windows:
	@echo "Сборка для Windows..."
	CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build ${LDFLAGS} -o ${BINARY_NAME}-windows-amd64.exe main.go

# Сборка для всех платформ
build-all: build-linux build-darwin build-windows
	@echo "Сборка для всех платформ завершена!"

# Очистка
clean:
	@echo "Очистка..."
	rm -f ${BINARY_NAME}
	rm -f ${BINARY_NAME}-*
	rm -f *.md
	@echo "Очистка завершена!"

# Тестирование
test:
	@echo "Запуск тестов..."
	go test -v ./internal/...

# Установка зависимостей
deps:
	@echo "Загрузка зависимостей..."
	go mod tidy
	go mod download

# Установка в систему (требует sudo)
install: build
	@echo "Установка ${BINARY_NAME} в /usr/local/bin..."
	sudo cp ${BINARY_NAME} /usr/local/bin/
	@echo "Установка завершена!"

# Удаление из системы
uninstall:
	@echo "Удаление ${BINARY_NAME} из /usr/local/bin..."
	sudo rm -f /usr/local/bin/${BINARY_NAME}
	@echo "Удаление завершено!"

# Проверка кода
lint:
	@echo "Проверка кода..."
	golangci-lint run

# Форматирование кода
fmt:
	@echo "Форматирование кода..."
	go fmt ./...

# Документация
docs:
	@echo "Генерация документации..."
	godoc -http=:6060

# Пример использования
example:
	@echo "Пример использования:"
	@echo "./${BINARY_NAME} https://example.com"

# Помощь
help:
	@echo "Доступные команды:"
	@echo "  build       - Сборка программы"
	@echo "  release     - Сборка релизной версии"
	@echo "  build-all   - Сборка для всех платформ"
	@echo "  clean       - Очистка файлов сборки"
	@echo "  test        - Запуск тестов"
	@echo "  deps        - Загрузка зависимостей"
	@echo "  install     - Установка в систему"
	@echo "  uninstall   - Удаление из системы"
	@echo "  lint        - Проверка кода"
	@echo "  fmt         - Форматирование кода"
	@echo "  docs        - Генерация документации"
	@echo "  example     - Пример использования"
	@echo "  help        - Показать эту справку"
