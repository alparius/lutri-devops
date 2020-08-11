package mongodb

import (
	"context"
	"lutri/model"

	"github.com/sirupsen/logrus"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
)

type FoodMongoStore struct {
	collection *mongo.Collection
}

// GetByID returns a Food with the given ID.
func (impl *FoodMongoStore) GetByID(ID string) (*model.Food, error) {
	objectID, err := primitive.ObjectIDFromHex(ID)
	if err != nil {
		logrus.WithField("error", err.Error()).Error("ObjectIDFromHex error")
		return nil, err
	}

	ctx, cancel := context.WithTimeout(context.Background(), TIMEOUT)
	defer cancel()

	var food model.Food
	err = impl.collection.FindOne(ctx, bson.M{"_id": objectID}).Decode(&food)
	if err != nil {
		logrus.WithField("error", err.Error()).Error("decode entity error")
		return nil, err
	}

	return &food, nil
}

// GetAll fetches the database for the list of Foods.
func (impl *FoodMongoStore) GetAll() (*[]model.Food, error) {
	ctx, cancel := context.WithTimeout(context.Background(), TIMEOUT)
	defer cancel()

	cursor, err := impl.collection.Find(ctx, bson.D{})
	if err != nil {
		logrus.WithField("error", err.Error()).Error("database find error")
		return nil, err
	}
	defer cursor.Close(ctx)

	var foods []model.Food
	for cursor.Next(ctx) {
		var p model.Food
		err = cursor.Decode(&p)
		if err != nil {
			logrus.WithField("error", err.Error()).Error("decode entity error")
			return nil, err
		}
		foods = append(foods, p)
	}

	logrus.WithField("length", len(foods)).Info("returning all Foods")
	return &foods, nil
}

// Insert saves a new Food into the collection.
func (impl *FoodMongoStore) Insert(food *model.Food) (string, error) {
	ctx, cancel := context.WithTimeout(context.Background(), TIMEOUT)
	defer cancel()

	result, err := impl.collection.InsertOne(ctx, food)
	if err != nil {
		logrus.WithField("error", err.Error()).Error("database insert error")
		return "", err
	}

	logrus.WithField("id", result.InsertedID).Info("inserted a Food")
	return result.InsertedID.(primitive.ObjectID).Hex(), nil
}

// Update updates an existing Food in the collection.
func (impl *FoodMongoStore) Update(food *model.Food) error {
	ctx, cancel := context.WithTimeout(context.Background(), TIMEOUT)
	defer cancel()

	result, err := impl.collection.ReplaceOne(ctx, bson.M{"_id": food.ID}, food)
	if err != nil {
		logrus.WithField("error", err.Error()).Error("database update error")
		return err
	}

	logrus.WithField("updateSize", result.MatchedCount).Info("updated a Food")
	return nil
}

// Delete deletes a Food from collection.
func (impl *FoodMongoStore) Delete(ID string) error {
	ctx, cancel := context.WithTimeout(context.Background(), TIMEOUT)
	defer cancel()

	objectID, err := primitive.ObjectIDFromHex(ID)
	if err != nil {
		logrus.WithField("error", err.Error()).Error("ObjectIDFromHex error")
		return err
	}

	result, err := impl.collection.DeleteOne(ctx, bson.M{"_id": objectID})
	if err != nil {
		logrus.WithField("error", err.Error()).Error("database delete error")
		return err
	}

	logrus.WithField("deleteCount", result.DeletedCount).Info("deleted a Food")
	return nil
}

// InsertMany saves an array of Foods into the collection.
func (impl *FoodMongoStore) InsertMany(foods *[]model.Food) error {
	ctx, cancel := context.WithTimeout(context.Background(), TIMEOUT)
	defer cancel()

	var documents []interface{}
	for _, food := range *foods {
		documents = append(documents, food)
	}

	result, err := impl.collection.InsertMany(ctx, documents)
	if err != nil {
		logrus.WithField("error", err.Error()).Error("database insertMany error")
		return err
	}

	logrus.WithField("insertCount", len(result.InsertedIDs)).Info("inserted an array of Foods")
	return nil
}

// DeleteAll empties the collection.
func (impl *FoodMongoStore) DeleteAll() error {
	ctx, cancel := context.WithTimeout(context.Background(), TIMEOUT)
	defer cancel()

	err := impl.collection.Drop(ctx)
	if err != nil {
		logrus.WithField("error", err.Error()).Error("database drop error")
		return err
	}

	logrus.Info("collection dropped successfully")
	return nil
}
