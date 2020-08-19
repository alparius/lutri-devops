package importer

import (
	"encoding/json"
	"io/ioutil"
	"lutri/model"
	"lutri/store"
	"os"

	"github.com/sirupsen/logrus"
)

type Importer struct {
	FoodStore store.FoodStore
}

// readFile reads and returns the bytes of the given file.
func readFile(filename string) ([]byte, error) {
	jsonFile, err := os.Open(filename)
	if err != nil {
		logrus.Error(err)
		return nil, err
	}
	defer jsonFile.Close()

	byteValue, err := ioutil.ReadAll(jsonFile)
	if err != nil {
		logrus.Error(err)
		return nil, err
	}

	return byteValue, nil
}

// ImportDatabase loads data from the given JSON file.
func (imp *Importer) ImportDatabase(file string) {

	fileData, err := readFile(file)
	if err != nil {
		logrus.Error(err)
	}

	var foods []model.Food
	err = json.Unmarshal(fileData, &foods)
	if err != nil {
		logrus.Error(err)
	}

	err = imp.FoodStore.DeleteAll()
	if err != nil {
		logrus.Error(err)
	}

	err = imp.FoodStore.InsertMany(&foods)
	if err != nil {
		logrus.Error(err)
	}
}
