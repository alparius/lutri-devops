package logger

import (
	"github.com/mattn/go-colorable"
	"github.com/sirupsen/logrus"
)

// Setup sets up the global logger configuration for the logrus package.
func Setup() {
	logrus.SetFormatter(&logrus.TextFormatter{ForceColors: true, TimestampFormat: "2006 Jan _2 15:04:05", FullTimestamp: true /*DisableLevelTruncation: true*/})
	logrus.SetOutput(colorable.NewColorableStdout())
	logrus.SetLevel(logrus.TraceLevel)
	logrus.SetReportCaller(true)
}
