package memory

import "lutri/store"

type MemoryStore struct {
}

// New returns a new MemoryStore instance.
func New() (*MemoryStore, error) {
	return &MemoryStore{}, nil
}

// GetFoodStore returns a FoodStore instance with a pointer to the Foods collection.
func (m *MemoryStore) GetFoodStore() store.FoodStore {
	return &FoodMemoryStore{}
}
