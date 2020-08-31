import axios from "axios";
import prom from "promjs";

const registry = prom();

export const myGauge = registry.create("gauge", "frontend_gauge", "A gauge from the far end");
export const cancelClicked = registry.create("counter", "frontend_cancels", "Counting the nr of cancels");
export const listRequestCounter = registry.create("counter", "frontend_list_requests", "A counter for food list requests");
export const listSizeHistogram = registry.create("histogram", "frontend_list_size", "A histogram for food list size", [5, 10, 15, 20]);

const URL = "http://csa-lutri2-promagg.apps.okd.codespring.ro/metrics/";

setInterval(function () {
    axios.post(URL, registry.metrics()).then(
        async (_) => {
            registry.reset();
        },
        (error) => {
            console.log(error);
        }
    );
}, 5000);
