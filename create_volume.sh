#!/bin/bash
# Create GlusterFS cluster volume

if [ "$1" = "" ]
then
    echo "Usage: create_volume.sh volume_name"
    exit
fi

VOLUME=$1


# Get settings from the file
source cluster/settings

# Create the folder for the volume
for (( i=1; i<=${COUNT}; i++ ))
do
  echo "Create the folder ${VOLUME} on ${SERVER}-${i} ..."
  gcloud compute ssh --zone ${REGION}-${ZONES[$i-1]} ${SERVER}-${i} --command "sudo mkdir /data/brick1/${VOLUME} && sudo chmod 777 /data/brick1/${VOLUME}"
  # concatenate servers/bricks
  CLUSTER=$CLUSTER${SPACE}${SERVER}-${i}:/data/brick1/${VOLUME}
done
echo " "

# run on server1
# create volume
gcloud compute ssh --zone ${REGION}-${ZONES[0]} ${SERVER}-1 --command "sudo gluster volume create ${VOLUME} replica ${COUNT} ${CLUSTER}"

# start volume
gcloud compute ssh --zone ${REGION}-${ZONES[0]} ${SERVER}-1 --command "sudo gluster volume start ${VOLUME}"

# check volumes
gcloud compute ssh --zone ${REGION}-${ZONES[0]} ${SERVER}-1 --command "sudo gluster volume info"
