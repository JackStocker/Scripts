#!/bin/sh
#shutdown script

# Check whether I should shutdown
SHUTDOWN=`cat /etc/cron.d/ShouldShutdown.txt`
MEDIA_HDD_AWAKE=`hdparm -C /dev/sdc1`

if [[ $MEDIA_HDD_AWAKE == *"active"* ]]; then
	echo "Media HDD still active, cancelling shutdown."
	exit 1
fi

# Tomorrows shutdown is always true
echo "1" > /etc/cron.d/ShouldShutdown.txt

if [ "$SHUTDOWN" -eq 1 ]; then
	echo "Evening shutting commencing."

	shutdown -h now
fi

exit 0
