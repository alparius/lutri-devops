package store

import (
	"lutri/model"
)

type FoodStore interface {
	GetByID(ID string) (*model.Food, error)
	GetAll() (*[]model.Food, error)
	Insert(*model.Food) (string, error)
	Update(*model.Food) error
	Delete(ID string) error
	InsertMany(food *[]model.Food) error
	DeleteAll() error
}
