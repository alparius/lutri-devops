package controller

import (
	"encoding/json"
	"lutri/model"
	"lutri/store"
	"net/http"

	"github.com/gorilla/mux"
	"github.com/sirupsen/logrus"
)

type FoodController struct {
	FoodStore store.FoodStore
}

func (ctrl *FoodController) GetByID(w http.ResponseWriter, r *http.Request) {

	ID := mux.Vars(r)["id"]
	food, err := ctrl.FoodStore.GetByID(ID)
	if err != nil && food != nil {
		w.WriteHeader(http.StatusNotFound)
		logrus.WithField("foodID", ID).Error("food not found")
		return
	}

	logrus.WithField("ID", ID).Info("returning food")
	w.WriteHeader(http.StatusOK)
	if err = json.NewEncoder(w).Encode(food); err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		logrus.Error("encoding error")
		return
	}
}

func (ctrl *FoodController) GetAll(w http.ResponseWriter, r *http.Request) {
	foods, err := ctrl.FoodStore.GetAll()
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		logrus.WithField("error", err.Error()).Error("returning with error")
		return
	}

	if len(*foods) == 0 {
		w.WriteHeader(http.StatusNoContent)
		logrus.Info("returning without results")
		return
	}

	logrus.WithField("length", len(*foods)).Info("returning all foods")
	w.WriteHeader(http.StatusOK)
	if err = json.NewEncoder(w).Encode(foods); err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		logrus.Error("encoding error")
		return
	}
}

func (ctrl *FoodController) Insert(w http.ResponseWriter, r *http.Request) {
	var newFood model.Food
	decoder := json.NewDecoder(r.Body)
	err := decoder.Decode(&newFood)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		logrus.WithField("error", err.Error()).Error("decode entity error")
		return
	}

	// check whether Food is already present in the collection
	foods, err := ctrl.FoodStore.GetAll()
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		logrus.WithField("error", err.Error()).Error("returning with error")
		return
	}
	for _, item := range *foods {
		if item.Name == newFood.Name {
			w.WriteHeader(http.StatusConflict)
			logrus.WithField("error", err.Error()).Error("already exists")
			return
		}
	}

	insertedID, err := ctrl.FoodStore.Insert(&newFood)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		logrus.WithField("error", err.Error()).Error("database error")
		return
	}

	logrus.WithField("food", newFood.ID).Info("new food created")
	w.WriteHeader(http.StatusOK)
	if _, err = w.Write([]byte(`{"insertedID": "` + insertedID + `"}`)); err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		logrus.Error("write error")
		return
	}
}

// Update updates a Food.
func (ctrl *FoodController) Update(w http.ResponseWriter, r *http.Request) {
	var food model.Food

	decoder := json.NewDecoder(r.Body)
	decoder.DisallowUnknownFields()
	err := decoder.Decode(&food)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		logrus.WithField("error", err.Error()).Error("decode entity error")
		return
	}

	logrus.WithField("ID:", food.ID).Info("updating food")

	err = ctrl.FoodStore.Update(&food)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		logrus.WithField("error", err.Error()).Error("database error")
		return
	}

	logrus.WithField("ID:", food.ID).Info("update successful")
	w.WriteHeader(http.StatusOK)
}

// Delete deletes a Food.
func (ctrl *FoodController) Delete(w http.ResponseWriter, r *http.Request) {
	ID := mux.Vars(r)["id"]

	_, err := ctrl.FoodStore.GetByID(ID)
	if err != nil {
		w.WriteHeader(http.StatusNotFound)
		logrus.WithField("foodID", ID).Error("food not found")
		return
	}

	err = ctrl.FoodStore.Delete(ID)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		logrus.WithField("error", err.Error()).Error("database error")
		return
	}

	logrus.WithField("ID:", ID).Info("delete successful")
	w.WriteHeader(http.StatusOK)
}
