#!/bin/sh

sudo screen -ls > test.txt

filename="test.txt"
flask_run=true
door_run=true

echo "Date : $(date)\n"

while read -r line
do
    name="$line"
    #echo "Line - $name"
        
    #if printf -- '%s' "$name" | egrep -q -- "No Sockets found"
    #then
        #printf "Found needle in haystack"
    #    flask_run=true
    #    door_run=true
    #fi
    
    if printf -- '%s' "$name" | egrep -q -- "pistartup"
    then
        #printf "Found needle in haystack"
        flask_run=false
    fi
    
    if printf -- '%s' "$name" | egrep -q -- "doorStartup"
    then
        #printf "Found needle in haystack"
        door_run=false
    fi


done < "$filename"

if [ "$flask_run" = true ];
then
    printf "Flask restarting\n"
    sleep 5
    cd /
    cd /home/pi
    sudo screen -dm -S pistartup ~/app.py
else
    printf "Flask running\n"
fi

if [ "$door_run" = true ];
then
    printf "Door restarting\n"
    sleep 5
    cd /
    cd /home/pi
    sudo screen -dm -S doorStartup ~/doorSensor.py
else
    printf "Door  running\n"
fi