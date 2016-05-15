#!/usr/bin/python

class Heater(object):
	
	def __init__(self, id, day_no, record_enabled, boost_used, heating_used, water_used, heater_type, time_start, time_end):
		self.id = id
		self.day_no = day_no
		self.record_enabled = record_enabled
		self.boost_used = boost_used
		self.heating_used = heating_used
		self.water_used = water_used
		self.heater_type = heater_type
		self.time_start = time_start
		self.time_end = time_end
	
	def getID(self):
		return self.id
		
	def getDay(self):
		return self.day_no
		
	def getRecordEnabled(self):
		return self.record_enabled
		
	def getBoostUsed(self):
		return self.boost_used
	
	def getHeatingUsed(self):
		return self.heating_used

	def getWaterUsed(self):
		return self.water_used
        
	def getHeaterType(self):
		return self.heater_type
		
  	def getTimeStart(self):
		return self.time_start
		
  	def getTimeEnd(self):
		return self.time_end

	def setID(self, id ):
		self.id = id
		
	def setDay(self, day_no):
		self.day_no = day_no
		
	def setRecordEnabled(self, record_enabled):
		self.record_enabled = record_enabled
		
	def setBoostUsed(self, boost_used):
		self.boost_used = boost_used
		
   	def setHeatingUsed(self, heating_used):
		self.heating_used = heating_used

   	def setWaterUsed(self, water_used):
		self.water_used = water_used
        
   	def setHeaterType(self, heater_type):
		self.heater_type = heater_type
		
   	def setTimeStart(self, time_start):
		self.time_start = time_start
		
   	def setTimeEnd(self, time_end):
		self.time_end = time_end
	
			