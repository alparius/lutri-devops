import axios from "axios";

const URL = "http://csa-lutri2-elastic.apps.okd.codespring.ro:80/lutri";

const sendLog = (component: string, message: string) => {
    const data = { _index: "lutri-frontend", message, component };

    axios.post(URL, JSON.stringify(data)).then(
        async (_) => {},
        (error) => {
            console.log(data);
            console.log(error);
        }
    );
};

export default sendLog;
