# PI-Projects

1. Pi Network 
2. Pi Heating
3. iOS Pi Network
4. iOS Pi Heating
5. Mac OS Monitor

1.Pi Network
Monitoring network speeds, ping test, traceroute, location of each IP
Each data retrieved is sent to database stored remotely,
the idea behind is that I can then see if my network is down,
each ping is done every 15mins.

2.Pi Heating 
This project has a mysql database, scheduler and flask written in python. 
The database contains all the on and off times for the heater. Flask runs the scheduler looking after
the execution time of the GPIO pins to turn and off relays.

3.iOS Pi Network
iOS App written in swift to notify me if the connection is down, can view all ping requests sent out and speed tests.
Maps are used to view the location of each ping hop made

4.iOS Pi Heating
iOS app interface in swift, this enables me to see today's scheduler, go to any day and change the times for
central heating or hot water.

5.Mac OS Monitor 
A simple OSX app, to show me the status of the two raspberry's running. I read the current temperater, CPU usuage etc.


