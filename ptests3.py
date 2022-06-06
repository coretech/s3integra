#!/root/s3_python/bin/python

import sys
import json
import s3mod
#from kafka import KafkaProducer
import requests


#producer = KafkaProducer(bootstrap_servers='141.94.5.150:9092,51.38.198.90:9092,137.74.249.151:9092')

astr = json.loads(sys.argv[1])
url = "http://localhost:8888/kafka/fspbx_events/s3"
basedir = "/usr/local/freeswitch"


action = astr['action']
action_id = astr['action_id']
secret_key = astr['data']['secret_key']
key_id = astr['data']['key_id']
bucket_name = astr['data']['bucket_name']
region = astr['data']['region']
filename = basedir + astr['data']['filename']


# store to s3
if action == "pbx.s3.store":
    try:
        result = s3mod.s3up(secret_key, key_id, bucket_name, region, filename)
    except:
        result = "s3_access_error"
#    print(result)

# send report to  kafka through http req
if  result == "comlete":
    data = {'action':action, 'action_id':action_id, 'upload_status':result}
#    print(url,data)
#    producer.send('fspbx_events', json.dumps(data, default=json_util.default).encode('utf-8'))
    r = requests.post(url, json.dumps(data))
else:
    data = {'action':action, 'action_id':action_id, 'upload_status':result}
    r = requests.post(url, json.dumps(data))
    
#if action == "pbx.s3.delete":
#    s3mod.s3del(secret_key, key_id, bucket_name, region, file_upload)

#print("Action ", action, " with ", file_upload, " complete")

