
from flask import Flask, render_template, make_response, jsonify, Response, request
from json import dumps
from DBService import Service
import json
import flask
from Heater import Heater
from pytz import utc
from apscheduler.jobstores.base import JobLookupError
from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler import events
from datetime import datetime
import time

service = Service()
dbArr = service.getAllHeater()
scheduler = BackgroundScheduler()

class MyResponse(Response):
    @classmethod
    def force_type(cls, rv, environ=None):
        if isinstance(rv, dict):
            rv = jsonify(rv)
        return super(MyResponse, cls).force_type(rv, environ)
        
class MyFlask(Flask):
    response_class = MyResponse
    

app = MyFlask(__name__)
app.debug = True  

def my_listener(event):
    if event.exception:
        print('The job crashed :(')
    else:
        print('The job worked :)')

def start_hello(scheduler):
    print "job completed"
    #scheduler.add_job(hello, 'interval', seconds=2, id='hello_job')

@app.route("/update", methods=['GET'])
def onUpdate():
    for db in dbArr:
        print db['time_start']
        scheduler.add_job(start_hello, 'cron', hour=23, minute=10, id=str(db['id']), args=[scheduler])
    scheduler.start()
    scheduler.add_listener(my_listener, events.EVENT_JOB_ERROR | events.EVENT_JOB_ERROR)
    return "OK"      

@app.route("/delete", methods=['POST', 'GET'])
def onHeaterSend():
    if scheduler.get_jobs() != []:
        print "Shutting down"
        scheduler.shutdown(wait=False)
    return "OK"
    

@app.route("/get",  methods=['GET'])
def getHeater():
    print scheduler.get_jobs()
    return "OK"
    
    
if __name__ == "__main__":
    app.run(host='', port=, debug=True)
			
