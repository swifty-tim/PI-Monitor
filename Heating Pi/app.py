#!/usr/bin/env python

from flask import Flask, render_template, make_response, jsonify, Response, request
import urllib2
from json import dumps
import datetime
import time
import threading
import RPi.GPIO as GPIO
from datetime import datetime
from DBService import Service
import MySQLdb
import json
import flask
from Heater import Heater

service = Service()

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
    return jsonify({'status' : 'ok'}), 201 
    

@app.route("/get",  methods=['GET'])
def getHeater():
    return jsonify({'heater' : service.getAllHeater()}), 201
    
    
if __name__ == "__main__":
   app.run(host='', port=, debug=True)
			
