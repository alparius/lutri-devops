export interface Food {
    ID: number;
    name: string;
    kcal: number;
    carbs: number;
    fats: number;
    protein: number;
}

export let food: Food = {
    ID: 0,
    name: "",
    kcal: 0,
    carbs: 0,
    fats: 0,
    protein: 0
};

export interface NewFood {
    name: string;
    kcal: number;
    carbs: number;
    fats: number;
    protein: number;
}

export let newFood: NewFood = {
    name: "",
    kcal: 0,
    carbs: 0,
    fats: 0,
    protein: 0
};
