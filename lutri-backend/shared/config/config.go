package config

import (
	"os"

	"github.com/sirupsen/logrus"
	"github.com/vrischmann/envconfig"
	"gopkg.in/yaml.v2"
)

type Config struct {
	UsingDatabase string `yaml:"using_database"`
	DoImport      string `yaml:"do_import"`
	MongoHost     string `yaml:"mongo_host"`
	MongoPort     string `yaml:"mongo_port"`
	MongoDatabase string `yaml:"mongo_database"`
	RouterPort    string `yaml:"router_port"`
	LogstashURL   string `yaml:"logstash_url"`
}

var CFG Config

// Setup sets up the global configurations.
func Setup() {
	readFile(&CFG)
	readEnv(&CFG)
	logrus.Info(CFG)
}

func readFile(cfg *Config) {
	f, err := os.Open("config.yml")
	if err != nil {
		logrus.Error(err)
	}
	defer f.Close()

	decoder := yaml.NewDecoder(f)
	if err := decoder.Decode(cfg); err != nil {
		logrus.Error(err)
	}
}

func readEnv(cfg *Config) {
	if err := envconfig.Init(&cfg); err != nil {
		logrus.Error(err)
	}
}
