#!/usr/bin/python

from __future__ import division
from subprocess import PIPE, Popen
import subprocess
import urllib2
import json
import socket 
import re
import socket
import re
import requests
import random
from bs4 import BeautifulSoup
from urllib2 import urlopen
import datetime  
import psutil


def get_cpu_temperature():
	process = Popen(['vcgencmd', 'measure_temp'], stdout=PIPE)
	output, _error = process.communicate()
	return float(output[output.index('=') + 1:output.rindex("'")])


def getPIData():
	cpu_temperature = get_cpu_temperature()
	cpu_usage = psutil.cpu_percent()
	
	ram = psutil.virtual_memory()
	ram_total = ram.total / 2**20       # MiB.
	ram_used = ram.used / 2**20
	ram_free = ram.free / 2**20
	ram_percent_used = ram.percent
	
	disk = psutil.disk_usage('/')
	disk_total = disk.total / 2**30     # GiB.
	disk_used = disk.used / 2**30
	disk_free = disk.free / 2**30
	disk_percent_used = disk.percent
	
	jsonData = {
    	'cpu_temperature':cpu_temperature,
    	'cpu_usage':cpu_usage,
    	'ram_total':ram_total,
    	'ram_used':ram_used,
    	'ram_free':ram_free,
    	'ram_percent_used':ram_percent_used,
    	'disk_total':disk_total,
    	'disk_used':disk_used,
    	'disk_free':disk_free,
    	'disk_percent_used':disk_percent_used,
	}
	send_data("URL", jsonData)

def contains_digits(s):
	return any(char.isdigit() for char in s)

def readJSON(jsonstring):
	msg = json.loads(jsonstring)

def build_http_headers(website):
	"""
	Creates a specific http header for the website that we are
	requesting the sample from so we can bypass bot checks otherwise
	a default generic header is assigned.
	Args:
		website (str) containing the name of the website the http headers
		need to be built for
	Returns:
		web_request_headers (dict) containing key:value pairs of http header options
	"""

	web_request_headers={}

	if 'pedump' in website:
		web_request_headers['Accept'] = 'text/html'
		web_request_headers['Accept-Language'] = 'en-US, en;'
		web_request_headers['Accept-Encoding'] = 'gzip, deflate'
		web_request_headers['User-Agent'] = get_random_user_agent()
		web_request_headers['Referer'] = 'http://pedump.me/'
	else:
		web_request_headers['Accept'] = 'text/html'
		web_request_headers['Accept-Language'] = 'en-US, en;'
		web_request_headers['Accept-Encoding'] = 'gzip, deflate'
		web_request_headers['User-Agent'] = get_random_user_agent()
		web_request_headers['Referer'] = 'http://google.com/'


	return web_request_headers

def get_random_user_agent():
	"""
	Reads user_agent.txt then returns a random user agent
	Returns: user_agent_list(str) containing random user agent
	"""

	user_agent_list = []
	lines = 0

	with open('path to file', 'r') as file_handle:
		for line in file_handle:
			user_agent_list.append(line)
			lines += 1

	return user_agent_list[random.randint(0, lines-1)].strip()

def find_loc(ip_add):
	path = "http://ipinfo.io/"+ip_add
	web_request_headers = build_http_headers(path)
	web_request = requests.get(path, headers=web_request_headers)
	data = web_request.content
	soup = BeautifulSoup(data)
	titles = soup.findAll('pre', attrs = { 'class' : 'example-results-basic' })
	#print geo_txt[32:].strip()
	#output = subprocess.check_output(["curl", path])
	datas = titles[0].text.split('\n')[-12:]
	co_ord = ""
	loc = ""
	carrier = ""
	org = ""
	city = ""
	country = ""
	if "Rate limit exceeded. Subscribe to a paid plan to increase your usage limits at http://ipinfo.io/pricing, or contact us via http://ipinfo.io/contact" in datas[0]:
		find_loc(ip_add)
	else:
		for data in datas:
			if 'country' in data: 
				country=data.split(':')[1].replace("\"", "").replace(" ", "")
				country = country[:-1]
			if 'city' in data: 
				city = data.split(':')[1].replace("\"", "").replace(" ", "")
				city = city[:-1]
			if 'loc' in data: 
				co_ord = data.split(':')[1].replace("\"", "")
				co_ord = co_ord[:-1]
			if 'org' in data: 
				org = data.split(':')[1].replace("\"", "")
			if 'carrier' in data:
				carrier = data.split(':')[1].replace("\"", "")
		if city != "":
			loc = country + ", " + city
		else:
			loc = country
	return (loc, co_ord, carrier, org)

def find_between( s, start, end ):
	return s[s.find("(")+1:s.find(")")]

def getRoute(dest_name):
	dest_addr = socket.gethostbyname(dest_name)
	output = subprocess.check_output(["traceroute", dest_name])
	data = output.split('\n')
	expression = re.compile('\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}')
	routeTook = []
	for row in data:
		route_ip = ""
		route_coord = ""
		rttArr = []
		route_loc = ""
		carrier = ""
		org = ""
		if expression.search(row):
			splitStr = row.split(")")
			route_ip = find_between(row, '(', ')')
			route_loc, route_coord, carrier,org = find_loc(route_ip)
			pings = splitStr[1].split(" ")
			for ping in pings:
				if contains_digits(ping): 
					rttArr.append(ping.strip())
		i = datetime.datetime.now()		
		route = {
			"route_ip":route_ip,
			"location":route_loc,
			"coord":route_coord,
			"rtt" : rttArr,
			"carrier":carrier,
			"org":org,
			"test_date":("%s" % i)
		}
		if route_ip != "":
			routeTook.append(route)	
	return routeTook


def send_data(url, jsondata):
	req = urllib2.Request(url)
	req.add_header('Content-Type', 'application/json')
	response = urllib2.urlopen(req, json.dumps(jsondata))


#getPIData()
ping_Add = []
ping_Add.append("www.google.ie")
ping_Add.append("www.facebook.com")
ping_Add.append("www.google.com")
ping_Add.append("www.twitter.com")
ping_Add.append("www.google.co.uk")
ping_Add.append("www.timothybarnard.org")
ping_Add.append("www.motorspy.org")

for address in ping_Add:
	ip = socket.gethostbyname(address)
	output = subprocess.check_output(["ping", "-c","3", "-W","2", ip])
	i = datetime.datetime.now()
	output = output.split('\n')[-3:]
	xmit_stats = output[0].split(",")
	timing_stats = output[1].split("=")[1].split("/")

	packet_loss = float(xmit_stats[2].split("%")[0])

	ping_min = float(timing_stats[0])
	ping_avg = float(timing_stats[1])
	ping_max = float(timing_stats[2])
		
	location, coord, carrier,org = find_loc(ip)
	jsond = {
		'address': ip,
		'ping_loc':location,
		'hostname':address,
		'coord':coord,
		'ping_min': ping_min,
		'ping_avg': ping_avg,
		'ping_max': ping_max,
		'packet_loss': packet_loss,
		'net_type': 1,
		'carrier':carrier,
		'org': org,
		'route' : getRoute(address),
		"test_date":("%s" % i)
	}
	#print(json.dumps(jsond))	
	send_data("URL path", jsond)