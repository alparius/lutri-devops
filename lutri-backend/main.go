package main

import (
	"lutri/controller"
	"lutri/router"
	"lutri/shared/config"
	"lutri/shared/importer"
	"lutri/shared/logger"
	"lutri/store"
	"lutri/store/memory"
	"lutri/store/mongodb"
)

func main() {
	config.Setup()
	logger.Setup()

	var store store.Store

	if config.CFG.UsingDatabase == "true" {
		store, _ = mongodb.New(config.CFG.MongoHost, config.CFG.MongoPort, config.CFG.MongoDatabase)
	} else {
		store, _ = memory.New()
	}

	foodStore := store.GetFoodStore()

	if config.CFG.DoImport == "true" {
		importer := &importer.Importer{FoodStore: foodStore}
		importer.ImportDatabase("static/foodsData.json")
	}

	foodCtrl := controller.FoodController{FoodStore: foodStore}

	router.Run(&foodCtrl, config.CFG.RouterPort)
}
