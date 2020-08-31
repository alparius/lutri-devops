import React, { useState } from "react";
import { Button, Form, Message, Modal } from "semantic-ui-react";

import { cancelClicked, myGauge } from "../requests/Prometheus";
import { newFood, NewFood } from "../model/Food";
import sendLog from "../requests/ElasticLog";

interface ICreateFoodProps {
    food: NewFood;
    setFood(food: NewFood): void;
    asyncPost(): Promise<void>;
}

const CreateFood: React.FC<ICreateFoodProps> = (props: ICreateFoodProps) => {
    const { food, setFood, asyncPost } = props;

    const [errorMsg, setErrorMsg] = useState(false);
    const [open, setOpen] = useState(false);

    const handleModalChange = (_: any) => {
        if (open) {
            setOpen(false);
            cancelClicked.inc();
            sendLog("createFood", "Oh naw man, cancel again..");
        } else {
            setFood(newFood);
            setOpen(true);
        }
    };

    const handleChange = (event: any) => {
        const { name, value } = event.target;
        if (name !== "name") {
            setFood({ ...food, [name]: Number(value) });
            myGauge.set(Number(value));
        } else {
            setFood({ ...food, [name]: value });
        }
    };

    const handleSubmit = () => {
        if (food.name === "") {
            setErrorMsg(true);
        } else {
            setErrorMsg(false);
            setOpen(false);
            sendLog("createFood", "That is one successful create, my boy.");
            asyncPost();
        }
    };

    return (
        <>
            <Button color="green" secondary onClick={handleModalChange}>
                Record a food
            </Button>
            <Modal open={open}>
                <Modal.Header>Record a food</Modal.Header>
                <Modal.Content>
                    <Form onSubmit={handleSubmit}>
                        {errorMsg && <Message negative>Invalid fields.</Message>}
                        <Form.Input type="text" value={food.name} name="name" label="name" onChange={handleChange} />
                        <Form.Input type="number" value={food.kcal} name="kcal" label="kcal" onChange={handleChange} />
                        <Form.Input type="number" value={food.carbs} name="carbs" label="carbs" onChange={handleChange} />
                        <Form.Input type="number" value={food.fats} name="fats" label="fats" onChange={handleChange} />
                        <Form.Input type="number" value={food.protein} name="protein" label="protein" onChange={handleChange} />
                    </Form>
                </Modal.Content>
                <Modal.Actions>
                    <Button type="reset" color="red" onClick={handleModalChange}>
                        Cancel
                    </Button>
                    <Button type="submit" color="blue" onClick={handleSubmit}>
                        Confirm
                    </Button>
                </Modal.Actions>
            </Modal>
        </>
    );
};

export default CreateFood;
