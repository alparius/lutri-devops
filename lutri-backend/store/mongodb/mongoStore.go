package mongodb

import (
	"context"
	"lutri/store"
	"time"

	"github.com/sirupsen/logrus"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

const TIMEOUT = 5 * time.Second

type MongoStore struct {
	database *mongo.Database
}

// New returns a new MongoStore instance connected to the database.
func New(dbHost string, dbPort string, dbName string) (*MongoStore, error) {
	clientOptions := options.Client().ApplyURI("mongodb://" + dbHost + ":" + dbPort)
	client, err := mongo.Connect(context.TODO(), clientOptions)
	if err != nil {
		logrus.WithField("error", err.Error()).Error("database connection error")
		return nil, err
	}
	database := client.Database(dbName)

	return &MongoStore{database}, nil
}

// GetFoodStore returns a FoodStore instance with a pointer to the Foods collection.
func (m *MongoStore) GetFoodStore() store.FoodStore {
	collection := m.database.Collection("foods")
	return &FoodMongoStore{collection}
}
