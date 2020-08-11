package model

import "go.mongodb.org/mongo-driver/bson/primitive"

type Food struct {
	ID      primitive.ObjectID `json:"ID,omitempty" bson:"_id,omitempty"`
	Name    string             `json:"name,omitempty" bson:"name,omitempty"`
	Kcal    int                `json:"kcal" bson:"kcal"`
	Carbs   int                `json:"carbs" bson:"carbs"`
	Fats    int                `json:"fats" bson:"fats"`
	Protein int                `json:"protein" bson:"protein"`
}
