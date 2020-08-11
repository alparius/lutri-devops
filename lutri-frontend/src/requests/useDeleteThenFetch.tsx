import axios from "axios";
import { useState } from "react";

const useDeleteThenFetch = <F extends {}>(
    url: string,
    url2: string,
    setFetchResponse: React.Dispatch<React.SetStateAction<F | undefined>>,
    setLoading: React.Dispatch<React.SetStateAction<boolean>>
): { showError: boolean; asyncDelete: () => Promise<void> } => {
    const [showError, setShowError] = useState(false);

    const URL = process.env.REACT_APP_API_URL + url;
    const URL2 = process.env.REACT_APP_API_URL + url2;

    const asyncDelete = async () => {
        await axios.delete(URL).then(
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

    return { showError, asyncDelete };
};

export default useDeleteThenFetch;
