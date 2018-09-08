echo "installing shutdown service..."

touch /etc/systemd/system/shutdown.service
cat > /etc/systemd/system/shutdown.service <<EOL

[Unit]
Description=Service to Monitor for Shutdown
After=multi-user.target

[Service]
Type=idle
ExecStart=/usr/bin/python /etc/shutdown/shutdown.py

[Install]
WantedBy=multi-user.target

EOL

chmod +x /etc/systemd/system/shutdown.service

sudo systemctl enable shutdown.service

echo "installing shutdown Script..."

mkdir /etc/shutdown/
touch /etc/shutdown/shutdown.py
cat > /etc/shutdown/shutdown.py <<EOL

#Shutdown Service for Raspberry PI
#Monitors GPIO4, if its high, system stays up, if its low, it shuts down

import RPi.GPIO as GPIO
import logging
from time import sleep
from subprocess import check_call
GPIO.setmode(GPIO.BCM)
GPIO.setup(3, GPIO.IN)

#Logging
logger = logging.getLogger('shutdown.servie')
hdlr = logging.FileHandler('/var/log/shutdown.log')
formatter = logging.Formatter('%(asctime)s %(levelname)s %(message)s')
hdlr.setFormatter(formatter)
logger.addHandler(hdlr)
logger.setLevel(logging.WARNING)

#When this is first called, if GPIO is not already high, then it
#must assume the shutdown button has been disconnected
#and exit this script

if not GPIO.input(3):
        logger.error('GPIO3 was not high on boot, script exit')
        GPIO.cleanup()
        exit()


##This will run as a loop, providing that GPIO3 was high when system booted

try:
    while True:            # this will carry on until you hit CTRL+C
        if not GPIO.input(3): # if port 4 == 1
            logger.info('System shutdown requested by service GPIO3')
            check_call(['/sbin/halt'])
        sleep(0.1)         # wait 0.1 seconds

finally:                   # this block will run no matter how the try block exits
GPIO.cleanup()

EOL
echo "Service not started automaticly but will on boot"
echo "Done, ensure you have your switch pulling GPIO low when pressed and high when not..."

