#!/usr/bin/env python

from flask import Flask, render_template, make_response, jsonify, Response, request
import urllib2
from json import dumps
import datetime
import time
import threading
import RPi.GPIO as GPIO
from datetime import datetime
import MySQLdb
import json
import flask
import requests
import io
import base64
from picamera import PiCamera
import glob
import os


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

PIN1 = 18
PIN2 = 23
flag = 0

localIP = ''

def json_serial(obj):
	"""JSON serializer for objects not serializable by default json code"""

	if isinstance(obj, datetime):
		serial = obj.isoformat()
		return serial
	raise TypeError ("Type not serializable")


class myThread (threading.Thread):
	def __init__(self, threadID, name, pin, wait, off):
		threading.Thread.__init__(self)
		self.threadID = threadID
		self.name = name
		self.pin = pin
		self.wait = wait
		self.off = off
	def run(self):
		print "Starting " + self.name
		time.sleep(self.wait)
		if self.off:
			print "On"
			GPIO.output(int(self.pin), GPIO.LOW)
		else:
		   print "Off"
		   GPIO.output(int(self.pin), GPIO.HIGH) 

def makeResponse():
	response = make_response(data)
	response.headers['Content-Type'] = 'text/javascript; charset=utf-8'
	response.headers['Etag']=datahash
	return response

def send_data(url, jsondata):
	req = urllib2.Request(url)
	req.add_header('Content-Type', 'application/json')
	response = urllib2.urlopen(req, json.dumps(jsondata))


def get_heater():
	data = ""
	with open('', 'r') as f:
		data = json.load(f)
	return data 

def control_GPIO():
	#print "gpio"
	#GPIO.cleanup()
	# GPIO.setwarnings(False)
	GPIO.setmode(GPIO.BCM)
	GPIO.setup(PIN1, GPIO.OUT)
	GPIO.setup(PIN2, GPIO.IN) 
	if GPIO.input(int(PIN2)) == True:
		#print "Pins On"
		GPIO.setup(PIN2, GPIO.OUT) 
		thread1 = myThread(1, "Thread-1", PIN1, 0, False)
		thread2 = myThread(2, "Thread-2", PIN2, 0, False)
		thread1.start()
		thread2.start()
		thread3 = myThread(3, "Thread-3", PIN1, 30, True)
		thread4 = myThread(4, "Thread-4", PIN2, 120, True)
		thread3.start()
		thread4.start()
	else:
		#print "Pins Off"
		thread3 = myThread(11, "Thread-11", PIN1, 0, True)
		thread4 = myThread(12, "Thread-12", PIN2, 120, True)
		thread3.start()
		thread4.start()
	return 'OK'


def create_app():
	control_GPIO()

def captureImage():
	image_64 = ''
	print('image taking')
	with PiCamera() as camera:
		camera.hflip = False
		stream = io.BytesIO()
		camera.capture(stream, format='jpeg')
		image_64 = base64.b64encode(stream.getvalue())
		camera.close()
	return image_64

def send_data(url, jsondata):
	req = urllib2.Request(url)
	req.add_header('Content-Type', 'application/json')
	response = urllib2.urlopen(req, json.dumps(jsondata))


@app.route("/get/logs/<filename>",  methods=['GET'])
def getLogs(filename):
	data = []
	with open('/home/pi/'+filename+'.txt', 'r') as file_handle:
		for line in file_handle:
			data.append(line)
	return jsonify({'status' : data}), 201 

@app.route("/logs/get/<filename>", methods=['POST', 'GET'])
def onGetLogs(filename):
	print filename
	try:
		response = requests.get(localIP+'/get/logs/'+filename)
	except requests.ConnectionError:
		print 'Connection Error'
	data = json.loads(response.text)
	return jsonify({'logs' : data}), 201
	
@app.route("/image/take", methods=['POST', 'GET'])
def onGetImage():
	content = request.get_json(silent=True)
	jsonData = json.dumps(content)
	imageArr = []
	if content['imageCount'] == 3:
		imageArr.append(captureImage())
		time.sleep(2)
		imageArr.append(captureImage())
		time.sleep(2)
		imageArr.append(captureImage())
	
	content['images'] = imageArr
	send_data("", content)
	return jsonify({'succeed' : 'ok'}), 201

@app.route("/image/get", methods= ['POST', 'GET'])
def takeImage():
	imageArr = []
	imageArr.append(captureImage())
	return jsonify({'image' : imageArr }), 201

@app.route("/boost/send", methods=['POST', 'GET'])
def onBoostSend():
	content = request.get_json(silent=True)
	jsonData = json.dumps(content)
	r = requests.post(localIP+'/boost', json=jsonData)
	print json.dumps(content)
	return jsonify({'succeed' : 'ok'}), r.status_code 

@app.route("/heater/send", methods=['POST', 'GET'])
def onHeaterSend():
	content = request.get_json(silent=True)
	jsonData = json.dumps(content)
	r = requests.post(localIP+'/send', json=jsonData)
	print json.dumps(content)
	return jsonify({'succeed' : 'ok'}), r.status_code 

@app.route("/control/send", methods=['POST', 'GET'])
def onControlSend():
	content = request.get_json(silent=True)
	jsonData = json.dumps(content)
	r = requests.post(localIP+'/send/control', json=jsonData)
	print json.dumps(content)
	return jsonify({'succeed' : 'ok'}), r.status_code 


@app.route("/control/get",  methods=['GET', 'POST'])
def getControlJSON():
	uri = localIP+"/get/control"
	print uri
	try:
		response = requests.get(uri)
	except requests.ConnectionError:
	   return "Connection Error"  
	data = json.loads(response.text)
	return jsonify(data), 201    

@app.route("/gpio", methods=['POST'])
def onPin():
	return control_GPIO()

@app.route("/bluetooth/send", methods=['POST', 'GET'])
def onBluetoothSend():
	content = request.get_json(silent=True)
	jsonData = json.dumps(content)
	r = requests.post(localIP+'/send/bluetooth', json=jsonData)
	print json.dumps(content)
	return jsonify({'succeed' : 'ok'}), r.status_code 


@app.route("/heater/get",  methods=['GET', 'POST'])
def getHeaterJSON():
	uri = localIP+"/get"
	print uri
	try:
		response = requests.get(uri)
	except requests.ConnectionError:
	   return "Connection Error"  
	data = json.loads(response.text)
	return jsonify(data), 201    

@app.route("/heater",  methods=['GET', 'POST'])
def getHeater():
	 return jsonify({'heater' : get_heater()}), 201
	
	
if __name__ == "__main__":
   app.run(host='', port=, debug=True)
			
