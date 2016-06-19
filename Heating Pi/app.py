#!/usr/bin/python
from __future__ import division
from flask import Flask, render_template, make_response, jsonify, Response, request
import urllib2
from json import dumps
from datetime import datetime
import time
import threading
import RPi.GPIO as GPIO
from datetime import datetime
from DBService import Service
import json
import flask
from Heater import Heater
from pytz import utc
from apscheduler.jobstores.base import JobLookupError
from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler import events
from instapush import Instapush, App
import logging
import dht11
import bluetooth
import subprocess
import io
import base64
from picamera import PiCamera
import glob
import os

appPush = App(appid='', secret='')

os.system('modprobe w1-gpio')
os.system('modprobe w1-therm')
base_dir = '/sys/bus/w1/devices/'

device_folder1 = glob.glob(base_dir + '')[0]
device_file1 = device_folder1 + '/w1_slave'

device_folder2 = glob.glob(base_dir + '')[0]
device_file2 = device_folder2 + '/w1_slave'

service = Service()
#dbArr = service.getAllHeater()
scheduler = BackgroundScheduler()

logging.basicConfig()

PIN1 = 18 #pump
PIN2 = 23 #boost
PIN3 = 24 #water
PIN4 = 25 #door sensor
#GPIO 4 = tempSensor

welcomeHomeBash = './chat.sh'

GPIO.setwarnings(False)
GPIO.setmode(GPIO.BCM)
GPIO.cleanup()

#stream = io.BytesIO()
#camera = PiCamera()
#camera.hflip = True

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
    
def read_temp_raw(file_name):
    catdata = subprocess.Popen(['cat',file_name], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out,err = catdata.communicate()
    out_decode = out.decode('utf-8')
    lines = out_decode.split('\n')
    return lines
    
def read_temp(lines):
    while lines[0].strip()[-3:] != 'YES':
        time.sleep(0.2)
        lines = read_temp_raw()
    equals_pos = lines[1].find('t=')
    if equals_pos != -1:
        temp_string = lines[1][equals_pos+2:]
        temp_c = float(temp_string) / 1000.0
        temp_f = temp_c * 9.0 / 5.0 + 32.0
        return temp_c

def read_all_temp():
	waterLines = read_temp_raw(device_file1)
	roomLines = read_temp_raw(device_file2)
	
	waterTemp = read_temp(waterLines)
	roomTemp = read_temp(roomLines)
	
	return { 'waterTemp' : waterTemp, 'roomTemp' : roomTemp }
	


def my_listener(event):
	if event.exception:
		print('The job crashed :(')
	else:
		print('The job worked :)')


def boost_control(state):
	print 'boost'
	GPIO.setup(PIN2, GPIO.OUT)
	if state == 1:
		GPIO.setup(PIN2, GPIO.LOW)
	else:
		GPIO.setup(PIN2, GPIO.HIGH)

def water_control(state):
	print 'water'
	GPIO.setup(PIN3, GPIO.OUT)
	if state == 1:
		GPIO.setup(PIN3, GPIO.LOW)
	else:
		GPIO.setup(PIN3, GPIO.HIGH)

def pump_on(state):
	print state
	GPIO.setup(PIN1, GPIO.OUT)
	if state == 1:
		GPIO.setup(PIN1, GPIO.LOW)
	else:
		GPIO.setup(PIN1, GPIO.HIGH)
	

def stop_boost(scheduler):
	print "boost stopped"
	appPush.notify(event_name='Test', trackers={ 'event': 'bosot off'})
	boost_control(0)
	service.deleteBoost()

def stop_hello(scheduler):
	print "job stopped"
	appPush.notify(event_name='Test', trackers={ 'event': 'off'})
	water_control(0)

def start_hello(scheduler):
	print "job completed"
	appPush.notify(event_name='Test', trackers={ 'event': 'on'})
	water_control(1)

def onUpdate():
	stopJobs()
	#readTemp()
	print "Schedule Starting up"
	contArr = service.getControl()
	#pump_on(contArr[0]['pumpOn']))
	#water_control(contArr[0]['waterOn'])
	if contArr[0]['waterOn'] == 1 :
		print "Water On"
		dbArr = service.getAllHeater()
		for db in dbArr:
			recordEnabled = db['record_enabled']
			boostUsed = db['boost_used']
			if recordEnabled == 1 and boostUsed == 0:
				print('adding new job')
				timeStart = db['time_start'].strip().split(':')
				timeEnd = db['time_end'].strip().split(':')
				day = db['day_no'] - 1
				#print day
				scheduler.add_job(start_hello, 'cron', day_of_week=day, hour=int(timeStart[0]), minute=int(timeStart[1]), args=[scheduler])
				scheduler.add_job(stop_hello, 'cron', day_of_week=day, hour=int(timeEnd[0]), minute=int(timeEnd[1]), args=[scheduler])
	else:
		print "Water OFF"
	return "OK" 
	
def stopJobs():
	for job in scheduler.get_jobs():
		scheduler.remove_job(job.id)
	return "OK" 
	

@app.route("/boost", methods= ['POST', 'GET'])
def boost():
	content = request.get_json()
	data = json.loads(content)
	
	for job in scheduler.get_jobs():
	    if job.id == 'boost_id':
	        scheduler.remove_job(job.id)
	
	boostEnd = data['boost_end']
	
	if int(boostEnd) > 0:
		now = datetime.now()
		boost_control(1)
		timeFrac = int(boostEnd) / 60
		hourFrac, minFrac = divmod(timeFrac, 1)
		min = int(minFrac * 60) + now.minute
		hour = int(hourFrac) + now.hour
		print hour, min
		scheduler.add_job(stop_boost, 'cron', id = 'boost_id', hour=hour, minute=min, args=[scheduler])
		
		heater = Heater( -1, now.weekday(), 1, 1, 0, 1, 'Boost',
			( str(now.hour)+':'+str(now.minute) ),
			( str(hour)+':'+str(min) ) )
		service.updateHeater(heater)
	else:
		boost_control(0)
	return "OK"
	


@app.route("/image", methods= ['POST', 'GET'])
def takeImage():
	imageArr = []
	with PiCamera() as camera:
		camera.hflip = False
		stream = io.BytesIO()
		camera.capture(stream, format='jpeg')
		image_64 = base64.b64encode(stream.getvalue())
		imageArr.append(image_64)
		camera.close()
	return jsonify({'image' : imageArr }), 201

@app.route("/get/logs/<filename>",  methods=['GET'])
def getLogs(filename):
	data = []
	with open('/home/pi/logs/'+filename+'.log', 'r') as file_handle:
		for line in file_handle:
			data.append(line)
	return jsonify({'status' : data}), 201 

@app.route("/get/jobs",  methods=['GET'])
def getJobs():
	print(scheduler.get_jobs())
	return "OK"

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
	print data
	pump_on(int(data['pumpOn']))
	#water_control(int(data['waterOn']))
	service.updateControl(data["waterOn"], data["heatingOn"], data["pumpOn"] )
	if data['waterOn'] == '0':
		stopJobs()
		water_control(0)
		boost_control(0)
	else:
		onUpdate()
	return jsonify({'status' : 'ok'}), 201  

@app.route("/get",  methods=['POST', 'GET'])
def getHeater():
	jsonData = {'heater':service.getAllHeater(), 'control':service.getControl(), 'temp' : read_all_temp() }
	return jsonify(jsonData), 201
 
def create_app(debug=True):
	onUpdate()
	scheduler.start()
	scheduler.add_listener(my_listener, events.EVENT_JOB_ERROR | events.EVENT_JOB_ERROR)
	
if __name__ == "__main__":
   create_app(True)
   app.run(host='', port=, debug=True)
			

			
