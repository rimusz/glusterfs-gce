#!/bin/bash
# Upgrade GlusterFS server package

# Get settings from the file
source settings

# 
for (( i=1; i<=${COUNT}; i++ ))
do
  echo "Upgrade GlusterFS server package on ${SERVER}-${i} server ..."
  gcloud compute ssh --zone ${REGION}-${ZONES[$i-1]} ${SERVER}-${i} --command "yes | sudo apt-get install --only-upgrade glusterfs-server"
  echo " "
done
echo " "
