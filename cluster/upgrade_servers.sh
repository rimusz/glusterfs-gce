#!/bin/bash
# Upgrade Ubuntu 

# Get settings from the file
source settings

# 
for (( i=1; i<=${COUNT}; i++ ))
do
  echo "Run upgrade of packages on ${SERVER}-${i} server ..."
  gcloud compute ssh --zone ${REGION}-${ZONES[$i-1]} ${SERVER}-${i} --command "sudo apt-get update && yes | sudo apt-get upgrade"
  echo " "
done
echo " "
