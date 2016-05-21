#!/usr/bin/python

from pytz import utc
from apscheduler.jobstores.base import JobLookupError
from apscheduler.schedulers.background import BackgroundScheduler
from datetime import datetime
from DBService import Service
import time


service = Service()
dbArr = service.getAllHeater()

def hello():
    print(time.localtime().tm_sec)


def kill_hello(scheduler):
    try:
      for db in dbArr:
        scheduler.remove_job(str(db['id']))
        print "job removed"
    except JobLookupError:
      return

def start_hello(scheduler):
    print "job completed"
    kill_hello(scheduler)
    #scheduler.add_job(hello, 'interval', seconds=2, id='hello_job')


if __name__ == '__main__':
    
    scheduler = BackgroundScheduler()
    
    for db in dbArr:
        print db['time_start']
        scheduler.add_job(start_hello, 'cron', day_of_week=5, id=str(db['id']), args=[scheduler])
    scheduler.start()
    
    #scheduler.add_job(kill_hello, 'cron', second=0, id='kill_hello', args=[scheduler])
    while True:
        time.sleep(1)