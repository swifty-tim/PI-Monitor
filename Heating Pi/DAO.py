#!/usr/bin/python

import MySQLdb as mdb
from Heater import Heater


class DBAO(object):

	conn = None
	
	def connect(self):
		self.conn = mdb.connect('', '', '', '')
	
	def selectControl(self):
		objectList = []
		print("DB Control Selecting...")
		cur = self.conn.cursor()
		cur.execute("SELECT *  from table ")
		rows = cur.fetchall()
		desc = cur.description
		# id, day_no, record_enabled, boost_used, heating_used, water_used, heater_type, time_start, time_end):
		for row in rows:
		    print row[1]
		    objectList.append({'id': row[0], 'pumpOn' : row[1], 'heatingOn' : row[2], 'waterOn':row[3]})
		return objectList
		
	def updateControl(self, water, heating, pump):
		print("DB Control Updating...")
		try:
			cur = self.conn.cursor()
			cur.execute(
				"UPDATE table SET pumpOn =%s, heatingOn =%s, waterOn =%s WHERE id = 1",
				(pump, heating water))
			self.conn.commit()
			return "Succesfully Updating"
		except mdb.Error, msg:
			self.conn.rollback()
			return "Error in Updating"
        
	def insertDB(self, heater):
		print("DB Inserting..")
		try:
			cur = self.conn.cursor()
			cur.execute(
				"INSERT INTO table (day_no , heater_type , water_used , heating_used, time_start, time_end, boost_used, record_enabled) VALUES ( %s , %s , %s , %s , %s , %s , %s , %s )",
				(heater.getDay(),
			 	heater.getHeaterType(),
			 	heater.getWaterUsed(),
			 	heater.getHeatingUsed(),
			 	heater.getTimeStart(),
			 	heater.getTimeEnd(),
			 	heater.getBoostUsed(),
			 	heater.getRecordEnabled()))
			self.conn.commit()
			return "Succesfully Added"
			
		except mdb.Error as msg:
			self.conn.rollback()
			return "Error in Adding"

	def updateDB(self, heater):
		print("DB Updating...")
		try:
			cur = self.conn.cursor()
			cur.execute(
				"UPDATE table SET day_no =%s, heater_type =%s, water_used =%s, heating_used =%s, time_start =%s, time_end =%s, boost_used =%s, record_enabled =%s WHERE id = %s",
				(heater.getDay(),
			 	heater.getHeaterType(),
			 	heater.getWaterUsed(),
			 	heater.getHeatingUsed(),
			 	heater.getTimeStart(),
			 	heater.getTimeEnd(),
			 	heater.getBoostUsed(),
			 	heater.getRecordEnabled(),
			 	heater.getID()))
			self.conn.commit()
			return "Succesfully Updating"
		except mdb.Error, msg:
			self.conn.rollback()
			return "Error in Updating"
			
	def deleteDB(self, heater):
		print("DB Deleteing...")
		try:
			cur = self.conn.cursor()
			cur.execute(
				"DELETE FROM table WHERE id =%s",
				(heater.getID()))
			self.conn.commit()
			return "Succesfully Deleted"
		except mdb.Error, msg:
			self.conn.rollback()
			return "Error in Deleted"

	def selectDB(self):
		objectList = []
		try:
			print("DB Selecting...")
			cur = self.conn.cursor()
			cur.execute("SELECT *  from table ")
		except (AttributeError, MySQLdb.OperationalError):
			print("DB Error Selecting...")
			self.connect()
			cur = self.conn.cursor()
			cur.execute("SELECT *  from table ")
			
		rows = cur.fetchall()
		desc = cur.description
		# id, day_no, record_enabled, boost_used, heating_used, water_used, heater_type, time_start, time_end):
		for row in rows:
			heater = Heater(
				row[0],
				row[1],
				row[8],
				row[7],
				row[4],
				row[3],
				row[2],
				row[5],
				row[6])
			objectList.append(heater)
		return objectList

	def closeDB(self):
		self.conn.close()
	
	def __init__(self):
		self.connect()
