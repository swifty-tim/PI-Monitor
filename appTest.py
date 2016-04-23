#!/usr/bin/env python

from flask import Flask, render_template, make_response, jsonify
import urllib2
from json import dumps
import datetime
import time
import threading
import RPi.GPIO as GPIO

app = Flask(__name__)
app.debug = True

PIN1 = 18
PIN2 = 23
flag = 0;


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
        print "Exiting " + self.name


def control_GPIO():
    print "gpio"
    #GPIO.cleanup()
    GPIO.setwarnings(False)
    GPIO.setmode(GPIO.BCM)
    GPIO.setup(PIN1, GPIO.OUT)
    GPIO.setup(PIN2, GPIO.IN) 
    if GPIO.input(int(PIN2)) == True:
        print "Pins On"
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
        print "Pins Off"
        thread3 = myThread(11, "Thread-11", PIN1, 0, True)
        thread4 = myThread(12, "Thread-12", PIN2, 120, True)
        thread3.start()
        thread4.start()




def create_app(debug=False):
    control_GPIO()

@app.route("/gpio")
def onPin():
    control_GPIO()
    
if __name__ == "__main__":
   create_app(True)
   app.run(host='192.168.1.11', port=5010, debug=True)
			
