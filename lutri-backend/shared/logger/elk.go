package logger

import (
	"fmt"
	"lutri/shared/config"
	"net"
	"time"

	logrus_logstash "github.com/bshuster-repo/logrus-logstash-hook"
	elastic_logrus "github.com/interactive-solutions/go-logrus-elasticsearch"
	elastic "github.com/olivere/elastic/v7"
	logrus "github.com/sirupsen/logrus"
)

func indexName() string {
	//return "lutri"
	return fmt.Sprintf("%s-%s", "lutri-direct", time.Now().Format("2006-01-02"))
}

// setupDirectElasticLogging sets up logrus for direct logging into the elastic client
func setupDirectElasticLogging() {
	// TODO: "http://elk.apps.okd.codespring.ro:80" or "http://okd-5mthh-worker-tb667.apps.okd.codespring.ro:30029"
	var ElasticURL = "http://elk.apps.okd.codespring.ro:80"

	ecs7, err := elastic.NewClient(elastic.SetURL(ElasticURL), elastic.SetSniff(false))
	if err != nil {
		logrus.WithError(err).Error("failed to create elasticsearch client")
		return
	}

	// create logger with 15 seconds flush interval
	hook, err := elastic_logrus.NewElasticHook(ecs7, ElasticURL, logrus.DebugLevel, indexName, time.Second*15)
	if err != nil {
		logrus.WithError(err).Error("failed to create elasticsearch hook for logrus")
		return
	}

	logrus.AddHook(hook)
}

// setupLogstashLogging sets up logrus for logging into the local logstash instance
func setupLogstashLogging() {
	conn, err := net.Dial("tcp", config.CFG.LogstashURL)
	if err != nil {
		logrus.WithError(err).Error("failed to create connection with logstash")
		return
	}

	hook := logrus_logstash.New(conn, jSONFormat)

	logrus.AddHook(hook)
}
