#!/bin/bash
# Delete GlusterFS cluster

# Get settings from the file
source settings

#
gcloud config set project ${PROJECT}


# Delete Routes ( visible in gCloud Networking Section )
for (( i=1; i<=${COUNT}; i++ ))
do
     # Delete the route for VM's static IP
     echo "Deleting the route for ${SERVER}-${i} static IP ${STATIC_IP[$i-1]} ..."
     gcloud compute routes delete ip-${SERVER}-${i} 
     echo " "

     # Delete the compute instances
    gcloud compute instances delete ${SERVER}-${i} --zone ${REGION}-${ZONES[$i-1]}    
    
done


# delete persistent disks
for (( i=1; i<=${COUNT}; i++ ))
do
  gcloud compute disks delete ${DISK}1-${i} --zone ${REGION}-${ZONES[$i-1]}
done

echo " "
echo "The end ..."
