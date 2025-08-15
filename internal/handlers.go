package internal

import (
	"github.com/sirupsen/logrus"
)

var logger *logrus.Logger

// SetLogger устанавливает логгер для пакета
func SetLogger(l *logrus.Logger) {
	logger = l
}
