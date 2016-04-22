#!/usr/bin/python2.7

from __future__ import division
from subprocess import PIPE, Popen
import psutil
import json


def get_cpu_temperature():
	process = Popen(['vcgencmd', 'measure_temp'], stdout=PIPE)
	output, _error = process.communicate()
	return float(output[output.index('=') + 1:output.rindex("'")])


def main():
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
    	'ram_total':ram_total,
    	'ram_used':ram_used,
    	'ram_free':ram_free,
    	'ram_percent_used':ram_percent_used,
    	'disk_total':disk_total,
    	'disk_used':disk_used,
    	'disk_free':disk_free,
    	'disk_percent_used':disk_percent_used,
	}
	print json.dumps(jsonData)
	


if __name__ == '__main__':
	main()