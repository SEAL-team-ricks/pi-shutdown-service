# pi-shutdown-service

A quick script i wrote as i wanted a single button on my project which would switch on the PI from a complete power off, then halt when pressed again, and finally resume again when pressed a third time. 

The actual wiring uses 2 relays, with the switch which connects to ground on the input supply. Hitting the momentary switch grounds the relay input. Which in turn grounds the PI. The PI then grounds the second relay which now has a line from the momentary switch from the first relay (but no longer ground) This feed pulls (when pushed again) a 3.5v feed low when pushed. 

Finally when it pulls low, this script detects the pull and calls halt. 

As we know, GPIO3 will wake the PI when its pulled low. Which just so happens to be what happens when we push our switch again. 

This script should either be run as a service or via rc.local on boot. 

The script will check if GPIO3 is high on boot. if not, it will assume that you didnt connect your switch and this will cause it to quit.
