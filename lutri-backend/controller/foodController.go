package controller

import (
	"encoding/json"
	"lutri/model"
	"lutri/store"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/sirupsen/logrus"
)

type FoodController struct {
	FoodStore store.FoodStore
}

// GetByID returns one Food with given ID.
func (ctrl *FoodController) GetByID(context *gin.Context) {
	ID := context.Param("id")
	food, err := ctrl.FoodStore.GetByID(ID)
	if err != nil && food != nil {
		context.AbortWithStatus(http.StatusNotFound)
		logrus.WithField("foodID", ID).Error("food not found")
		return
	}

	logrus.WithField("ID", ID).Info("returning food")
	context.JSON(http.StatusOK, food)
}

// GetAll returns all Foods.
func (ctrl *FoodController) GetAll(context *gin.Context) {
	foods, err := ctrl.FoodStore.GetAll()
	if err != nil {
		context.AbortWithStatus(http.StatusInternalServerError)
		logrus.WithField("error", err.Error()).Error("returning with error")
		return
	}

	if len(*foods) == 0 {
		context.AbortWithStatus(http.StatusNoContent)
		logrus.Info("returning without results")
		return
	}

	logrus.WithField("length", len(*foods)).Info("returning all foods")
	context.JSON(http.StatusOK, foods)

}

// Insert adds a new Food.
func (ctrl *FoodController) Insert(context *gin.Context) {
	var newFood model.Food
	decoder := json.NewDecoder(context.Request.Body)
	err := decoder.Decode(&newFood)
	if err != nil {
		context.AbortWithStatus(http.StatusBadRequest)
		logrus.WithField("error", err.Error()).Error("decode entity error")
		return
	}

	// check whether Food is already present in the collection
	foods, err := ctrl.FoodStore.GetAll()
	if err != nil {
		context.AbortWithStatus(http.StatusInternalServerError)
		logrus.WithField("error", err.Error()).Error("returning with error")
		return
	}
	for _, item := range *foods {
		if item.Name == newFood.Name {
			context.AbortWithStatus(http.StatusConflict)
			logrus.WithField("error", err.Error()).Error("already exists")
			return
		}
	}

	insertedID, err := ctrl.FoodStore.Insert(&newFood)
	if err != nil {
		context.AbortWithStatus(http.StatusInternalServerError)
		logrus.WithField("error", err.Error()).Error("database error")
		return
	}

	logrus.WithField("food", newFood.ID).Info("new food created")
	context.JSON(http.StatusOK, gin.H{"insertedID": insertedID})
}

// Update updates a Food.
func (ctrl *FoodController) Update(context *gin.Context) {
	var food model.Food

	decoder := json.NewDecoder(context.Request.Body)
	decoder.DisallowUnknownFields()
	err := decoder.Decode(&food)
	if err != nil {
		context.AbortWithStatus(http.StatusBadRequest)
		logrus.WithField("error", err.Error()).Error("decode entity error")
		return
	}

	logrus.WithField("ID:", food.ID).Info("updating food")

	err = ctrl.FoodStore.Update(&food)
	if err != nil {
		context.AbortWithStatus(http.StatusInternalServerError)
		logrus.WithField("error", err.Error()).Error("database error")
		return
	}

	logrus.WithField("ID:", food.ID).Info("update successful")
	context.Status(http.StatusOK)
}

// Delete deletes a Food.
func (ctrl *FoodController) Delete(context *gin.Context) {
	ID := context.Param("id")

	_, err := ctrl.FoodStore.GetByID(ID)
	if err != nil {
		context.AbortWithStatus(http.StatusNotFound)
		logrus.WithField("foodID", ID).Error("food not found")
		return
	}

	err = ctrl.FoodStore.Delete(ID)
	if err != nil {
		context.AbortWithStatus(http.StatusInternalServerError)
		logrus.WithField("error", err.Error()).Error("database error")
		return
	}

	logrus.WithField("ID:", ID).Info("delete successful")
	context.Status(http.StatusOK)
}
