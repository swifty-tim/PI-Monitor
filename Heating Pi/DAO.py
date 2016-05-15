#!/usr/bin/python

import MySQLdb as mdb
from Heater import Heater


class DBAO(object):

	conn = None

	def __init__(self):
		self.conn = mdb.connect()

	def insertDB(self, heater):
		print("DB Inserting..")
		try:
			cur = self.conn.cursor()
			cur.execute(
				"INSERT INTO PI_HEATER (day_no , heater_type , water_used , heating_used, time_start, time_end, boost_used, record_enabled) VALUES ( %s , %s , %s , %s , %s , %s , %s , %s )",
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
				"UPDATE PI_HEATER SET day_no =%s, heater_type =%s, water_used =%s, heating_used =%s, time_start =%s, time_end =%s, boost_used =%s, record_enabled =%s WHERE id = %s",
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
				"DELETE FROM PI_HEATER WHERE id =%s",
				(heater.getID()))
			self.conn.commit()
			return "Succesfully Deleted"
		except mdb.Error, msg:
			self.conn.rollback()
			return "Error in Deleted"

	def selectDB(self):
		objectList = []
		print("DB Selecting...")
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
		return objectList

	def closeDB(self):
		self.conn.close()
