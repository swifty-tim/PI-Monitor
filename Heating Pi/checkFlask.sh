#!/bin/sh

screen -ls > test.txt

filename="test.txt"
flask_run=false

echo "Date : $(date)\n"

while read -r line
do
    name="$line"
    #echo "Line - $name"

    if printf -- '%s' "$name" | egrep -q -- "No Sockets found"
    then
        #printf "Found needle in haystack"
        flask_run=true
    fi


done < "$filename"

if [ "$flask_run" = true ];
then
    printf "Flask restarting\n"
    sleep 5
    cd /
    cd /home/pi
    screen -dm -S pistartup ~/Path to file
else
    printf "All Clear\n"
fi