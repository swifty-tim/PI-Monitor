#!/usr/bin/env python

from flask import Flask, render_template, make_response, jsonify, Response, request
import urllib2
from json import dumps
from datetime import datetime
import time
import threading
import RPi.GPIO as GPIO
from datetime import datetime
from DBService import Service
import MySQLdb
import json
import flask
from Heater import Heater
from pytz import utc
from apscheduler.jobstores.base import JobLookupError
from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler import events
from instapush import Instapush, App
import logging

appPush = App(appid='', secret='')

service = Service()
#dbArr = service.getAllHeater()
scheduler = BackgroundScheduler()

logging.basicConfig()

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

def stop_hello(scheduler):
    print "job stopped"
    appPush.notify(event_name='Test', trackers={ 'event': 'off'})
    #scheduler.add_job(hello, 'interval', seconds=2, id='hello_job')

def start_hello(scheduler):
    print "job completed"
    appPush.notify(event_name='Test', trackers={ 'event': 'on'})
    #scheduler.add_job(hello, 'interval', seconds=2, id='hello_job')

def onUpdate():
    stopJobs()
    print "Schedule Starting up"
    dbArr = service.getAllHeater()
    for db in dbArr:
        #print db['time_start']
        #print db['time_end']
        timeStart = db['time_start'].strip().split(':')
        timeEnd = db['time_end'].strip().split(':')
        day = db['day_no'] - 1
        #print day
        scheduler.add_job(start_hello, 'cron', day_of_week=day, hour=int(timeStart[0]), minute=int(timeStart[1]), args=[scheduler])
        scheduler.add_job(stop_hello, 'cron', day_of_week=day, hour=int(timeEnd[0]), minute=int(timeEnd[1]), args=[scheduler])
    scheduler.start()
    scheduler.add_listener(my_listener, events.EVENT_JOB_ERROR | events.EVENT_JOB_ERROR)
    return "OK" 
    
def stopJobs():
    if scheduler.get_jobs() != []:
        print "Shutting down"
        scheduler.shutdown(wait=False)
    return "OK" 

@app.route("/get/jobs",  methods=['GET'])
def getJobs():
    print scheduler.get_jobs()
    return "Ok"  

@app.route("/send", methods=['POST', 'GET'])
def onHeaterSend():
    content = request.get_json()
    data = json.loads(content)
    # id, day_no, record_enabled, boost_used, heating_used, water_used, heater_type, time_start, time_end):
    heater = Heater(
        int(data['id']),
        int(data['day_no']),
        int(data['record_enabled']),
        int(data['boost_used']),
        int(data['heating_used']),
        int(data['water_used']),
        data['heater_type'],
        data['time_start'],
        data['time_end'])
    service.updateHeater(heater)
    onUpdate()
    return jsonify({'status' : 'ok'}), 201 

@app.route("/get/control",  methods=['POST', 'GET'])
def getControl():
    return jsonify({'control' : service.getControl()}), 201    

@app.route("/send/control",  methods=['POST', 'GET'])
def sendControl():
    content = request.get_json()
    data = json.loads(content)
    service.updateControl(data["waterOn"], data["heatingOn"], data["pumpOn"] )
    if data['waterOn'] == '0':
        stopJobs()
    else:
        onUpdate()
    return jsonify({'status' : 'ok'}), 201  

@app.route("/get",  methods=['POST', 'GET'])
def getHeater():
    return jsonify({'heater' : service.getAllHeater()}), 201
 
def create_app(debug=True):
    onUpdate() 
    
if __name__ == "__main__":
   create_app(True)
   app.run(host='', port=, debug=True)
			
