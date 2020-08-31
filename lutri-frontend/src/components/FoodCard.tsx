import React, { useState } from "react";
import { Button, Card, Form, Message, Modal, Grid } from "semantic-ui-react";

import { Food } from "../model/Food";
import sendLog from "../requests/ElasticLog";

interface IFoodCardProps {
    food: Food;
    editFood: Food;
    setEditFood(food: Food): void;
    asyncPut(): Promise<void>;
    asyncDelete(): Promise<void>;
}

const FoodCard: React.FC<IFoodCardProps> = (props: IFoodCardProps) => {
    const { food, editFood, setEditFood, asyncPut, asyncDelete } = props;

    const [errorMsg, setErrorMsg] = useState(false);
    const [editModalOpen, setEditModalOpen] = useState(false);
    const [deleteModalOpen, setDeleteModalOpen] = useState(false);

    const handleChange = (event: any) => {
        const { name, value } = event.target;
        if (name !== "name") {
            setEditFood({ ...editFood, [name]: Number(value) });
        } else {
            setEditFood({ ...editFood, [name]: value });
        }
    };

    const handleEditSubmit = () => {
        if (editFood.name === "") {
            setErrorMsg(true);
        } else {
            setErrorMsg(false);
            setEditModalOpen(false);
            asyncPut();
        }
    };

    const handleDeleteSubmit = () => {
        setDeleteModalOpen(false);
        asyncDelete();
    };

    const handleEditModalChange = (_: any) => {
        if (editModalOpen) {
            setEditModalOpen(false);
        } else {
            setEditFood(food);
            setEditModalOpen(true);
        }
    };

    const handleDeleteModalChange = (_: any) => {
        if (deleteModalOpen) {
            setDeleteModalOpen(false);
            sendLog("deleteFood", "Somebody canceled a delete. That's hot!'");
        } else {
            setEditFood(food);
            setDeleteModalOpen(true);
        }
    };

    return (
        <>
            <Card key={food.ID} fluid>
                <Card.Content header>
                    <b>{food.name}</b>
                    <Button id="deleteButton" floated="right" icon="trash" color="red" inverted onClick={handleDeleteModalChange} />
                    <Button id="editButton" floated="right" icon="edit outline" color="orange" inverted onClick={handleEditModalChange} />
                </Card.Content>
                <Card.Content description style={{ "white-space": "pre-wrap" }}>
                    <Grid>
                        <Grid.Row columns={6}>
                            <Grid.Column>
                                <i>Kcal:</i> <b>{food.kcal}</b>
                            </Grid.Column>
                            <Grid.Column>
                                <i>Carbs:</i> <b>{food.carbs}</b>
                            </Grid.Column>
                            <Grid.Column>
                                <i>Fats:</i> <b>{food.fats}</b>
                            </Grid.Column>
                            <Grid.Column>
                                <i>Protein:</i> <b>{food.protein}</b>
                            </Grid.Column>
                        </Grid.Row>
                    </Grid>
                </Card.Content>
            </Card>

            <Modal open={editModalOpen}>
                <Modal.Header>Edit a food</Modal.Header>
                <Modal.Content>
                    <Form onSubmit={handleEditSubmit}>
                        {errorMsg && <Message negative>Invalid fields.</Message>}
                        <Form.Input type="text" value={editFood.name} name="name" label="name" onChange={handleChange} />
                        <Form.Input type="number" value={editFood.kcal} name="kcal" label="kcal" onChange={handleChange} />
                        <Form.Input type="number" value={editFood.carbs} name="carbs" label="carbs" onChange={handleChange} />
                        <Form.Input type="number" value={editFood.fats} name="fats" label="fats" onChange={handleChange} />
                        <Form.Input type="number" value={editFood.protein} name="protein" label="protein" onChange={handleChange} />
                    </Form>
                </Modal.Content>
                <Modal.Actions>
                    <Button type="reset" color="red" onClick={handleEditModalChange}>
                        Cancel
                    </Button>
                    <Button type="submit" color="blue" onClick={handleEditSubmit}>
                        Save
                    </Button>
                </Modal.Actions>
            </Modal>

            <Modal open={deleteModalOpen}>
                <Modal.Header>Delete a food</Modal.Header>
                <Modal.Actions>
                    <Button type="reset" color="red" onClick={handleDeleteModalChange}>
                        Cancel
                    </Button>
                    <Button type="submit" color="blue" onClick={handleDeleteSubmit}>
                        Delete
                    </Button>
                </Modal.Actions>
            </Modal>
        </>
    );
};

export default FoodCard;
