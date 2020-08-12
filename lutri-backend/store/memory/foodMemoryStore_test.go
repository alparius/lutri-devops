package memory

import (
	"lutri/model"
	"lutri/shared/importer"
	"lutri/store"
	"testing"

	"github.com/tj/assert"
)

func getFoodStoreMock() store.FoodStore {
	store, _ := New()
	foodStore := store.GetFoodStore()
	importer := &importer.Importer{FoodStore: foodStore}
	importer.ImportDatabase("../../static/foodsData.json")
	return foodStore
}

func TestFoodStoreGetByID(t *testing.T) {
	foodStore := getFoodStoreMock()
	food, err := foodStore.GetByID("5d6385f3f250a816135d1002")
	assert.Equal(t, food.Name, "salmon", "should get the name")
	assert.Nil(t, err, "should not have error")
}

func TestFoodStoreGetAll(t *testing.T) {
	foodStore := getFoodStoreMock()
	foods, err := foodStore.GetAll()
	assert.Equal(t, len(*foods), 17, "should get all foods")
	assert.Nil(t, err, "should not have error")
}

func TestFoodStoreInsert(t *testing.T) {
	foodStore := getFoodStoreMock()
	insertedID, err := foodStore.Insert(&model.Food{})
	assert.NotNil(t, insertedID, "should not be nil")
	assert.Nil(t, err, "should not have error")
	foods, err := foodStore.GetAll()
	assert.Equal(t, len(*foods), 18, "should get all foods")
	assert.Nil(t, err, "should not have error")
}

func TestFoodStoreDelete(t *testing.T) {
	foodStore := getFoodStoreMock()
	err := foodStore.Delete("5d6385f3f250a816135d1002")
	assert.Nil(t, err, "should not have error")
	foods, err := foodStore.GetAll()
	assert.Equal(t, len(*foods), 16, "should get all foods")
	assert.Nil(t, err, "should not have error")
}
