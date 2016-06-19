#!/usr/bin/env python

import time
import RPi.GPIO as gpio
import bluetooth
import subprocess
from instapush import Instapush, App
import urllib2
import json
import logging
from picamera import PiCamera
from time import sleep
import io
import base64
import urllib2
import requests

logging.basicConfig(level=logging.DEBUG,
format='%(asctime)s %(levelname)-8s %(message)s',
datefmt='%a, %d %b %Y %H:%M:%S',
filename='logs/sample.log' )
#info

console = logging.StreamHandler()
console.setLevel(logging.INFO)
# set a format which is simpler for console use
formatter = logging.Formatter('%(name)-12s: %(levelname)-8s %(message)s')
# tell the handler to use this format
console.setFormatter(formatter)
# add the handler to the root logger
logging.getLogger('').addHandler(console)

appPush = App(appid='', secret='')

gpio.setmode(gpio.BCM)

door_pin = 25

gpio.setup( door_pin, gpio.IN, pull_up_down=gpio.PUD_UP)
welcomeHomeBash = './chat.sh'
goodbyeHomeBash = './chatBye.sh'
intruderOpenBash = './chatIntruder.sh'
intruderClosedBash = './chatIntruderBye.sh'

door = 1
#stream = io.BytesIO()
#camera = PiCamera()
#camera.hflip = True

def send_data(url, jsonData):
	r = requests.post(url, json=jsonData)
	return r.status_code 

#def send_data(url, jsondata):
#	logging.debug("Sending URL")
#	req = urllib2.Request(url)
#	req.add_header('Content-Type', 'application/json')
#	response = urllib2.urlopen(req, json.dumps(jsondata))
	
def doorChange(user, status, imageCount):
	
	jsonData = {
		'user':user,
		'status':status,
		'imageCount':imageCount,
		'action':'send'
	}
	send_data("", jsonData)
	

while True:
	if ( gpio.input(door_pin) and door == 1 ):
		logging.debug("Checking Opened")
		result = bluetooth.lookup_name('', timeout=5)
		
		if (result != None):
			logging.debug("Tim opened door")
			doorChange('tim', 1, 0)
			process = subprocess.Popen(welcomeHomeBash.split(), stdout=subprocess.PIPE)
			output = process.communicate()[0]
		else:
			logging.debug("Unknown opened door")
			process = subprocess.Popen(intruderOpenBash.split(), stdout=subprocess.PIPE)
			output = process.communicate()[0]
			appPush.notify(event_name='Test', trackers={ 'event': 'Door Opened'})
			doorChange('unknown', 1,3)
		
		door = 0
		time.sleep(1)
	
	if ( gpio.input(door_pin) == False and door!= 1):
		logging.debug("Checking Closed")
		result = bluetooth.lookup_name('', timeout=5)
		
		if (result != None):
			logging.debug("Tim closed the door")
			doorChange('tim', 0, 0)
			process = subprocess.Popen(goodbyeHomeBash.split(), stdout=subprocess.PIPE)
			output = process.communicate()[0]
		else:
			logging.debug("Unknown closed door")
			process = subprocess.Popen(intruderClosedBash.split(), stdout=subprocess.PIPE)
			output = process.communicate()[0]
			appPush.notify(event_name='Test', trackers={ 'event': 'Door Closed'})
			doorChange('unknown', 0, 3)
		door = 1