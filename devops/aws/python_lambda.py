import json
import requests # pip installed and zip uploaded to aws console

def lambda_handler(event, context):

    url = 'https://nominatim.openstreetmap.org/search?q=' + event['location'] + '&format=json'
    r = requests.get(url)
    robj = r.json()[0]
    
    return {
        'statusCode': 200,
        'body': {
            'lat': robj['lat'],
            'lon': robj['lon']
        }
    }