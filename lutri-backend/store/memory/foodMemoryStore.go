package memory

import (
	"lutri/model"
	"time"

	"github.com/sirupsen/logrus"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

type FoodMemoryStore struct {
	items []model.Food
}

// GetByID returns a Food with the given ID.
func (impl *FoodMemoryStore) GetByID(ID string) (*model.Food, error) {
	objectID, err := primitive.ObjectIDFromHex(ID)
	if err != nil {
		logrus.WithField("error", err.Error()).Error("ObjectIDFromHex error")
		return nil, err
	}

	for _, item := range impl.items {
		if item.ID == objectID {
			return &item, nil
		}
	}
	return nil, err
}

// GetAll gets the list of Foods.
func (impl *FoodMemoryStore) GetAll() (*[]model.Food, error) {
	return &impl.items, nil
}

// Insert saves a new Food into the collection.
func (impl *FoodMemoryStore) Insert(food *model.Food) (string, error) {
	food.ID = primitive.NewObjectIDFromTimestamp(time.Now())
	impl.items = append(impl.items, *food)
	return food.ID.String(), nil
}

// Update updates an existing Food in the collection.
func (impl *FoodMemoryStore) Update(food *model.Food) error {
	for index, item := range impl.items {
		if item.ID == food.ID {
			impl.items[index] = *food
			return nil
		}
	}

	return nil
}

// Delete deletes a Food from collection.
func (impl *FoodMemoryStore) Delete(ID string) error {
	objectID, err := primitive.ObjectIDFromHex(ID)
	if err != nil {
		logrus.WithField("error", err.Error()).Error("ObjectIDFromHex error")
		return err
	}

	for index, item := range impl.items {
		if item.ID == objectID {
			impl.items[index] = impl.items[len(impl.items)-1]
			impl.items[len(impl.items)-1] = model.Food{}
			impl.items = impl.items[:len(impl.items)-1]
			return nil
		}
	}

	return nil
}

// InsertMany saves an array of Foods into the collection.
func (impl *FoodMemoryStore) InsertMany(foods *[]model.Food) error {
	impl.items = *foods
	return nil
}

// DeleteAll is not needed here.
func (impl *FoodMemoryStore) DeleteAll() error {
	return nil
}
