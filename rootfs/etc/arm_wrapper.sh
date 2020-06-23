#!/usr/bin/with-contenv sh

DEVNAME=$1

echo "Starting ARM on ${DEVNAME}" | logger -t ARM
python3 /opt/arm/arm/ripper/main.py -d ${DEVNAME}
