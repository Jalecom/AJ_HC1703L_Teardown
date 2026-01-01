#!/bin/sh
# wdk.sh watchdog_kicker.sh
# Ping watchdog every 25 secondi
echo "Kill start.sh and p2pcam..."
kill -9 `ps | grep "start.sh" | grep -v grep | awk '{printf $1}'`
kill -9 `ps | grep "p2pcam" | grep -v grep | awk '{printf $1}'`
echo "Waiting 3s ..."
sleep 3
echo "Starting watchdog kicker..."
# Try to open the watchdog device
exec 3>/dev/watchdog
# Loop forever to "kick" the watchdog
#while true
#do
#    echo "Ping watchdog..." >&2
#    echo "V" >&3
#    sleep 25
#done
while true; do echo "Ping watchdog..." >&2; echo "V" >&3; sleep 25; done &
echo "Loop in esecuzione..."

