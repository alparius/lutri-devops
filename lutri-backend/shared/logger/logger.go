package logger

import (
	"github.com/rifflock/lfshook"
	"github.com/sirupsen/logrus"
)

var jSONFormat = &logrus.JSONFormatter{TimestampFormat: "2006 Jan _2 15:04:05"}

// Setup sets up the global logger configuration for the logrus package.
func Setup() {
	logrus.SetFormatter(&logrus.TextFormatter{ForceColors: true, TimestampFormat: "2006 Jan _2 15:04:05", FullTimestamp: true})
	// logrus.SetOutput(colorable.NewColorableStdout())
	logrus.SetLevel(logrus.TraceLevel)
	logrus.SetReportCaller(true)

	//setupDirectElasticLogging()
	setupLogstashLogging()
	setupFileLogging()
}

func setupFileLogging() {
	pathMap := lfshook.PathMap{
		logrus.DebugLevel: "./logs/lutri-low.log",
		logrus.InfoLevel:  "./logs/lutri-low.log",
		logrus.WarnLevel:  "./logs/lutri-high.log",
		logrus.ErrorLevel: "./logs/lutri-high.log",
	}

	logrus.AddHook(lfshook.NewHook(pathMap, jSONFormat))
}
