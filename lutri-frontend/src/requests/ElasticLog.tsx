import axios from "axios";

const sendLog = (level: string, component: string, message: string, ) => {
    const data = { timestamp: new Date(), func: component, Message: message, Level: level };

    // log directly into my elastic (with cors)
    axios.post("http://csa-lutri2-elastic.apps.okd.codespring.ro:80/lutri/_doc/", data).then(
        async (_) => {
        },
        (error) => {
            console.log(error);
        }
    );

    // log to logstash
    axios.post("http://localhost:5000", data).then(
        async (_) => {
        },
        (error) => {
            console.log(error);
        }
    );

}


export default sendLog;
