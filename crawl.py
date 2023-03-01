import requests
import json
import datetime
import time

url = 'http://www.coinex.net/api/v1/validators/0xebeDB77b225C461f4823dA085F087Dc591302937/stakes'
headers = {'apikey': '63f216f505de49c744999125'}

def get_data():
    data  = requests.get(url, headers=headers)
    if data.status_code == 200:
        file = open("data.json", "w")
        json.dump(data.json(), file)
        file.close()

def checkpoint():
    f = open("checkpoint.txt", "w")
    f.write(str(datetime.datetime.now()))
    f.close()

while (True):
    try:
        get_data()
        print(datetime.datetime.now())
        time.sleep(10)
    except:
        print("Error!")
        time.sleep(10)

