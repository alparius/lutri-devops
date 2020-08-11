import React, { useState } from "react";
import { Header, Grid, Container } from "semantic-ui-react";

import { Food, food, NewFood, newFood } from "../model/Food";
import useDeleteThenFetch from "../requests/useDeleteThenFetch";
import useFetchToo from "../requests/useFetchToo";
import usePostThenFetch from "../requests/usePostThenFetch";
import usePutThenFetch from "../requests/usePutThenFetch";
import FoodList from "./FoodList";
import CreateFood from "./CreateFood";

const FoodContainer: React.FC = () => {
    const [fetchResponse, setFetchResponse] = useState<Food[] | undefined>();
    const [loading, setLoading] = useState<boolean>(false);

    const { showError } = useFetchToo<Food[]>("/foods", setFetchResponse, setLoading);

    const [editFood, setEditFood] = useState(food);
    const [createFood, setCreateFood] = useState(newFood);

    const { showError: postShowError, asyncPost } = usePostThenFetch<NewFood, Food[]>("/food", createFood, "/foods", setFetchResponse, setLoading);

    const { showError: putShowError, asyncPut } = usePutThenFetch<Food, Food[]>("/food", editFood, "/foods", setFetchResponse, setLoading);

    const { showError: deleteShowError, asyncDelete } = useDeleteThenFetch<Food[]>("/food/" + editFood.ID, "/foods", setFetchResponse, setLoading);

    return (
        <Container style={{ marginTop: "3em" }}>
            <Header as="h1">Lutri</Header>

            <Grid columns={2} style={{ marginTop: "2em" }}>
                <Grid.Row>
                    <Grid.Column>
                        <Header as="h3">list of foods:</Header>
                    </Grid.Column>
                    <Grid.Column textAlign="right">
                        <CreateFood food={createFood} setFood={setCreateFood} asyncPost={asyncPost} />
                    </Grid.Column>
                </Grid.Row>
            </Grid>
            <FoodList
                response={fetchResponse}
                loading={loading}
                showError={showError}
                postShowError={postShowError}
                putShowError={putShowError}
                deleteShowError={deleteShowError}
                asyncPut={asyncPut}
                asyncDelete={asyncDelete}
                editFood={editFood}
                setEditFood={setEditFood}
            />
        </Container>
    );
};

export default FoodContainer;
