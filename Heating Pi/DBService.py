#!/usr/local/bin/python

from DAO import DBAO
import json
# dbao = DBAO()
# dbao.createDB()
# #dbao.insertDB("ARROW",2,1)
# #
# arrayTV = dbao.selectDB()
# dbao.closeDB()

class Service(object):
	
	dbao = None

	def __init__(self):
		self.dbao = DBAO()
		
	def updateControl(self, water, heating, pump):
		return self.dbao.updateControl(water, heating, pump)
		
	def getControl(self):
		return self.dbao.selectControl()
	
	def deleteBoost(self):
		return self.dbao.deleteBoost()
		
	def updateHeater(self, heater ):
		if heater.getRecordEnabled() == -1:
			return self.dbao.deleteDB(heater)
		elif heater.getID() == -1:
			return self.dbao.insertDB(heater)
		else:
			return self.dbao.updateDB(heater)
		
	def close(self):
		self.dbao.close()
		
	def getAllHeater(self):
		
		response = []
		
		for item in self.dbao.selectDB():
			response.append({'id': item.getID(), 'day_no' : item.getDay(), 'heater_type' : item.getHeaterType(), 'water_used':item.getWaterUsed() ,  'heater_used': item.getHeatingUsed(),'time_start':item.getTimeStart() , 'time_end':item.getTimeEnd(),
			 'boost_used':item.getBoostUsed(), 'record_enabled':item.getRecordEnabled() })
						
		return response
			
			
			