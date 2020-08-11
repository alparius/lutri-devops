import axios from "axios";
import { useEffect, useState } from "react";

const useFetchToo = <T extends {}>(
    url: string,
    setFetchResponse: React.Dispatch<React.SetStateAction<T | undefined>>,
    setLoading: React.Dispatch<React.SetStateAction<boolean>>
): { showError: boolean; responseStatus: number | undefined } => {
    const [responseStatus, setResponseStatus] = useState<number | undefined>();
    const [showError, setShowError] = useState(false);

    const URL = process.env.REACT_APP_API_URL + url;

    useEffect(() => {
        const fetchData = async () => {
            setShowError(false);
            setLoading(true);
            try {
                const result = await axios.request<T>({ url: URL });
                setResponseStatus(result.status);
                setFetchResponse(result.data);
            } catch (error) {
                setShowError(true);
            }
            setLoading(false);
        };
        fetchData();
    }, [URL, setFetchResponse, setLoading]);

    return { showError, responseStatus };
};

export default useFetchToo;
