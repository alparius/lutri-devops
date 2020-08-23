const http = require('https')
var aws = require('aws-sdk')


exports.handler = async(event) => {

    var otherLambda = await getCoords(event.location)
    var coords = JSON.parse(otherLambda.Payload).body

    return httprequest(coords.lat, coords.lon).then((data) => {
        return {
            statusCode: 200,
            body: {
                temp: data.main.temp,
                image: data.weather[0].main,
                text: data.weather[0].description,
                location: data.name + ", " + data.sys.country
            },
        };
    });
};


async function getCoords(location) {
    var lambda = new aws.Lambda({ region: 'eu-west-3' });

    var params = {
        FunctionName: 'csalpi-lambda-5', //
        InvocationType: 'RequestResponse',
        LogType: 'Tail',
        Payload: JSON.stringify({ location : location })
    };

    return await lambda.invoke(params, function(err, data) {
        if (err) {
            throw err;
        }
    })
    .promise();
}


function httprequest(lat, lon) {
    return new Promise((resolve, reject) => {

        const options = {
            host: 'api.openweathermap.org',
            path: `/data/2.5/weather?lat=${lat}&lon=${lon}&units=metric&lang=hu&APPID=${process.env.OPENWEATHERMAP_APIKEY}`,
            method: 'GET'
        };

        const req = http.request(options, (res) => {
            if (res.statusCode < 200 || res.statusCode >= 300) {
                return reject(new Error('statusCode=' + res.statusCode));
            }
            var body = [];
            res.on('data', function(chunk) {
                body.push(chunk);
            });
            res.on('end', function() {
                try {
                    body = JSON.parse(Buffer.concat(body).toString());
                }
                catch (e) {
                    reject(e);
                }
                resolve(body);
            });
        });
        req.on('error', (e) => {
            reject(e.message);
        });

        req.end(); // send the request
    });
}
