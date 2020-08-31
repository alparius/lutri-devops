import React from "react";
import { Card, Message } from "semantic-ui-react";

import FoodCard from "./FoodCard";
import { Food } from "../model/Food";
import { listRequestCounter, listSizeHistogram } from "../requests/Prometheus";

interface IFoodListProps {
    response: Food[] | undefined;
    loading: boolean;
    showError: boolean;
    editFood: Food;
    postShowError: boolean;
    putShowError: boolean;
    deleteShowError: boolean;
    setEditFood(food: Food): void;
    asyncPut(): Promise<void>;
    asyncDelete(): Promise<void>;
}

const FoodList: React.FC<IFoodListProps> = (props: IFoodListProps) => {
    const { response, loading, showError, editFood, putShowError, deleteShowError, postShowError, setEditFood, asyncPut, asyncDelete } = props;

    if (showError) {
        return <Message negative>Connection error.</Message>;
    } else if (loading) {
        return <Message warning>Loading..</Message>;
    } else if (!response || response.length === 0) {
        return <Message info>No foods yet.</Message>;
    } else {
        listRequestCounter.inc();
        listSizeHistogram.observe(response.length, { path: "/api/users", status: 200 });
        return (
            <>
                {(postShowError || deleteShowError || putShowError) && <Message negative>Server error.</Message>}
                <Card.Group>
                    {response
                        .sort((a: Food, b: Food) => {
                            if (a.name < b.name) {
                                return -1;
                            }
                            if (a.name > b.name) {
                                return 1;
                            }
                            return 0;
                        })
                        .map((_, index: number) => (
                            <FoodCard
                                key={index}
                                food={response[index]}
                                editFood={editFood}
                                setEditFood={setEditFood}
                                asyncPut={asyncPut}
                                asyncDelete={asyncDelete}
                            />
                        ))}
                </Card.Group>
            </>
        );
    }
};

export default FoodList;
