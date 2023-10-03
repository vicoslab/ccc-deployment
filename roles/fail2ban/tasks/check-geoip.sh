#!/bin/bash

# Get the IP address and region from the command line argument
IP="$1"
REGION="$2"

# Check the geolocation of the IP address using geoiplookup
GEO="$(geoiplookup "$IP" | awk -F ', ' '{print $1}' | awk -F ': ' '{print $2}')"

# Check if the geolocation matches the region to ignore
if [ "$GEO" = "$REGION" ]; then
  exit 0
else
  exit 1
fi