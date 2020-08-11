import axios from "axios";
import { useState } from "react";

const usePutThenFetch = <T extends {}, F extends {}>(
    url: string,
    data: T,
    url2: string,
    setFetchResponse: React.Dispatch<React.SetStateAction<F | undefined>>,
    setLoading: React.Dispatch<React.SetStateAction<boolean>>
): { showError: boolean; asyncPut: () => Promise<void> } => {
    const [showError, setShowError] = useState(false);

    const URL = process.env.REACT_APP_API_URL + url;
    const URL2 = process.env.REACT_APP_API_URL + url2;

    const asyncPut = async () => {
        await axios.put<T>(URL, data).then(
            async (resp) => {
                setShowError(false);
                setLoading(true);
                try {
                    const result = await axios.request<F>({ url: URL2 });
                    setFetchResponse(result.data);
                } catch (error) {
                    setShowError(true);
                }
                setLoading(false);
            },
            (error) => {
                setShowError(true);
            }
        );
    };

    return { showError, asyncPut };
};

export default usePutThenFetch;
