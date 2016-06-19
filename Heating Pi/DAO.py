#!/usr/bin/python

import sqlite3

from Heater import Heater


class DBAO(object):

	conn = None
	
	def closeDB(self):
		self.conn.close()
	
	def __init__(self):
		self.connect()
	
	def connectDB(self):
		self.conn = sqlite3.connect('heater.db')
		print('Opened DB')
	
	def connect(self):
		self.conn = sqlite3.connect('heater.db')
		print 'Opened database'
		self.createHeaterTable()
		self.createControlTable()
	
	def createHeaterTable(self):
		self.connectDB()
		self.conn.execute('''CREATE TABLE IF NOT EXISTS PI_HEATER
		   (id INTEGER PRIMARY KEY AUTOINCREMENT,
		   day_no         INTEGER,
		   heater_type    CHAR(255),
		   water_used     INTEGER DEFAULT 0,
		   heating_used   INTEGER DEFAULT 0,
		   time_start     CHAR(100),
		   time_end       CHAR(100),
		   boost_used     INTEGER DEFAULT 0,
		   record_enabled INTEGER DEFAULT 1);''')
		self.closeDB()
		print "Table created successfully";
		
	def createControlTable(self):
		self.connectDB()
		self.conn.execute('''CREATE TABLE IF NOT EXISTS PI_CONTROL
		   (id INTEGER PRIMARY KEY AUTOINCREMENT,
		   pumpOn         INTEGER DEFAULT 0,
		   heatingOn     INTEGER DEFAULT 0,
		   waterOn   INTEGER DEFAULT 0);''')
		self.closeDB()
		print "Table created successfully";
		
	def selectControl(self):
		self.connectDB()
		objectList = []
		print("DB Control Selecting...")
		try:
			cur = self.conn.cursor()
			cur.execute("SELECT *  from PI_CONTROL ")
		except (AttributeError, sqlite3.OperationalError):
			self.connect()
			cur = self.conn.cursor()
			cur.execute("SELECT *  from PI_CONTROL ")
		
		rows = cur.fetchall()
		desc = cur.description
		# id, day_no, record_enabled, boost_used, heating_used, water_used, heater_type, time_start, time_end):
		for row in rows:
		    print row[1]
		    objectList.append({'id': row[0], 'pumpOn' : row[1], 'heatingOn' : row[2], 'waterOn':row[3]})
		self.closeDB()
		return objectList
		
	def updateControl(self, water, heating, pump):
		self.connectDB()
		print("DB Control Updating...")
		try:
			cur = self.conn.cursor()
			cur.execute(
				"UPDATE PI_CONTROL SET pumpOn =?, heatingOn =?, waterOn =? WHERE id = 1",
				(pump, heating, water))
			print 'Updated.......'
			self.conn.commit()
			self.closeDB()
			return "Succesfully Updating"
		except sqlite3.Error, msg:
			self.conn.rollback()
			self.closeDB()
			return "Error in Updating"
        
	def insertDB(self, heater):
		self.connectDB()
		print("DB Inserting..")
		try:
			cur = self.conn.cursor()
			cur.execute(
				"INSERT INTO PI_HEATER (day_no , heater_type , water_used , heating_used, time_start, time_end, boost_used, record_enabled) VALUES ( ? ,? , ? , ? , ? , ? , ? , ? )",
				(heater.getDay(),
			 	heater.getHeaterType(),
			 	heater.getWaterUsed(),
			 	heater.getHeatingUsed(),
			 	heater.getTimeStart(),
			 	heater.getTimeEnd(),
			 	heater.getBoostUsed(),
			 	heater.getRecordEnabled()))
			self.conn.commit()
			self.closeDB()
			return "Succesfully Added"
		except sqlite3.Error as msg:
			print msg
			self.conn.rollback()
			self.closeDB()
			return "Error in Adding"

	def updateDB(self, heater):
		self.connectDB()
		print("DB Updating...")
		try:
			cur = self.conn.cursor()
			cur.execute(
				"UPDATE PI_HEATER SET day_no =?, heater_type =?, water_used =?, heating_used =?, time_start =?, time_end =?, boost_used =?, record_enabled =? WHERE id = ?",
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
		except sqlite3.Error, msg:
			self.conn.rollback()
			return "Error in Updating"
	
	def deleteBoost(self):
		self.connectDB()
		print("DB Deleteing...")
		try:
			cur = self.conn.cursor()
			cur.execute(
				"DELETE FROM PI_HEATER WHERE boost_used =1 ")
			self.conn.commit()
			self.closeDB()
			return "Succesfully Deleted"
		except sqlite3.Error, msg:
			self.conn.rollback()
			self.closeDB()
			return "Error in Deleted"
			
	def deleteDB(self, heater):
		self.connectDB()
		print("DB Deleteing...")
		print(heater.getID())
		try:
			cur = self.conn.cursor()
			cur.execute(
				"DELETE FROM PI_HEATER WHERE id =?",
				(heater.getID(),))
			self.conn.commit()
			self.closeDB()
			return "Succesfully Deleted"
		except sqlite3.Error, msg:
			self.conn.rollback()
			self.closeDB()
			return "Error in Deleted"

	def selectDB(self):
		self.connectDB()
		objectList = []
		try:
			print("DB Selecting...")
			cur = self.conn.cursor()
			cur.execute("SELECT *  from PI_HEATER ")
		except (AttributeError, sqlite3.OperationalError):
			print("DB Error Selecting...")
			self.connect()
			cur = self.conn.cursor()
			cur.execute("SELECT *  from PI_HEATER ")
			
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
		self.closeDB()
		return objectList	
	