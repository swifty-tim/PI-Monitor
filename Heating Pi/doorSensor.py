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


def captureImage():
	with PiCamera() as camera:
		camera.hflip = False
		stream = io.BytesIO()
		camera.capture(stream, format='jpeg')
		image_64 = base64.b64encode(stream.getvalue())
		camera.close()
	return image_64

def send_data(url, jsondata):
	logging.debug("Sending URL")
	req = urllib2.Request(url)
	req.add_header('Content-Type', 'application/json')
	response = urllib2.urlopen(req, json.dumps(jsondata))
	
def doorChange(user, status, images):
	
	jsonData = {
		'user':user,
		'images':images,
		'status':status,
		'':''
	}
	send_data("", jsonData)
	

while True:
	if ( gpio.input(door_pin) and door == 1 ):
		logging.debug("Checking Opened")
		images = []
		result = bluetooth.lookup_name('', timeout=5)
		
		if (result != None):
			logging.debug("????? opened door")
			doorChange('????', 1, images)
			process = subprocess.Popen(welcomeHomeBash.split(), stdout=subprocess.PIPE)
			output = process.communicate()[0]
		else:
			images.append( captureImage() )
			logging.debug("Unknown opened door")
			process = subprocess.Popen(intruderOpenBash.split(), stdout=subprocess.PIPE)
			output = process.communicate()[0]
			appPush.notify(event_name='Test', trackers={ 'event': 'Door Opened'})
			time.sleep(2)
			images.append( captureImage() )
			time.sleep(2)
			images.append( captureImage() )
			doorChange('unknown', 1, images)
		
		door = 0
		time.sleep(1)
	
	if ( gpio.input(door_pin) == False and door!= 1):
		logging.debug("Checking Closed")
		images = []
		result = bluetooth.lookup_name('', timeout=5)
		
		if (result != None):
			logging.debug("???? closed the door")
			doorChange('????', 0, images)
			process = subprocess.Popen(goodbyeHomeBash.split(), stdout=subprocess.PIPE)
			output = process.communicate()[0]
		else:
			images.append( captureImage() )
			logging.debug("Unknown closed door")
			process = subprocess.Popen(intruderClosedBash.split(), stdout=subprocess.PIPE)
			output = process.communicate()[0]
			appPush.notify(event_name='Test', trackers={ 'event': 'Door Closed'})
			time.sleep(2)
			images.append( captureImage() )
			time.sleep(2)
			images.append( captureImage() )
			doorChange('unknown', 0, images)
		door = 1