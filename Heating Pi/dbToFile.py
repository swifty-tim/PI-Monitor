#!/usr/bin/python
from datetime import datetime
import MySQLdb
import json


def json_serial(obj):
    """JSON serializer for objects not serializable by default json code"""

    if isinstance(obj, datetime):
        serial = obj.isoformat()
        return serial
    raise TypeError ("Type not serializable")

HOST = "localhost"
PORT = 3306
USER = "root"
PASSWORD = "root1988"
DB = "heater"

db = MySQLdb.connect(host=HOST,    # your host, usually localhost
                     user=USER,         # your username
                     passwd=PASSWORD,  # your password
                     db=DB)        # name of the data base

# you must create a Cursor object. It will let
#  you execute all the queries you need
cur = db.cursor()

# Use all the SQL you like
cur.execute("SELECT * FROM PI_HEATER")

# print all the first cell of all the rows

columns = [desc[0] for desc in cur.description]
result = []
for row in cur.fetchall():
    row = dict(zip(columns, row))
    result.append(row)

db.close()

with open('data.txt', 'w') as outfile:
    json.dump(result, outfile, default=json_serial)

print json.dumps(result, default=json_serial)