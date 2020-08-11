package config

import (
	"os"

	"github.com/sirupsen/logrus"
	"github.com/vrischmann/envconfig"
	"gopkg.in/yaml.v2"
)

type Config2 struct {
	Data struct {
		UsingDatabase string `yaml:"using_database" envconfig:"using_database"`
		DoImport      string `yaml:"do_import" envconfig:"do_import"`
	} `yaml:"data"`
	MongoDB struct {
		MongoHost     string `yaml:"mongo_host" envconfig:"mongo_host"`
		MongoPort     string `yaml:"mongo_port" envconfig:"mongo_port"`
		MongoDatabase string `yaml:"mongo_database" envconfig:"mongo_database"`
	} `yaml:"mongodb"`
	RouterPort string `yaml:"router_port" envconfig:"router_port"`
}

type Config struct {
	UsingDatabase string `yaml:"using_database"`
	DoImport      string `yaml:"do_import"`
	MongoHost     string `yaml:"mongo_host"`
	MongoPort     string `yaml:"mongo_port"`
	MongoDatabase string `yaml:"mongo_database"`
	RouterPort    string `yaml:"router_port"`
}

var CFG Config

// Setup sets up the global configurations.
func Setup() {
	readFile(&CFG)
	readEnv(&CFG)
	logrus.Warn(CFG)
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
