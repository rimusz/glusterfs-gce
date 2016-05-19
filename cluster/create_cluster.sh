#!/bin/bash
# Create GlusterFS cluster

# Get settings from the file
source settings

#
gcloud config set project ${PROJECT}

# create persistent disks
for (( i=1; i<=${COUNT}; i++ ))
do
  gcloud compute disks create ${DISK}1-${i} --size ${SIZE} --type pd-ssd --zone ${REGION}-${ZONES[$i-1]}
done

# create servers
for (( i=1; i<=${COUNT}; i++ ))
do
    gcloud compute instances create ${SERVER}-${i} --image=$IMAGE --image-project=ubuntu-os-cloud \
     --boot-disk-type pd-standard --boot-disk-size 200 --zone ${REGION}-${ZONES[$i-1]} \
     --machine-type=${MACHINE_TYPE} \
     --can-ip-forward --tags ${SERVER},${SERVER}-${i} \
     --disk name=${DISK}1-${i} \
     --scopes compute-rw,logging-write,monitoring-write,sql,storage-full,useraccounts-rw

     echo "Waiting for VM ${SERVER}-${i} to be ready..."
     spin='-\|/'
     a=1
     until gcloud compute instances describe --zone ${REGION}-${ZONES[$i-1]} ${SERVER}-${i} | grep "RUNNING" >/dev/null 2>&1; do a=$(( (a+1) %4 )); printf "\r${spin:$a:1}"; sleep .1; done
     sleep 15
     VM_EXT_IP=$(gcloud compute instances list | grep -v grep | grep ${SERVER}-${i}| awk {'print $5'})
     ssh -q $VM_EXT_IP exit
     echo " "

     # add network ens4:0 with the static IP
     echo "Updating /etc/network/interfaces file on  ${SERVER}-${i} ..."
     gcloud compute ssh --zone ${REGION}-${ZONES[$i-1]} ${SERVER}-${i} --command \
     'echo -e "# static IP
     auto ens4:0
     iface ens4:0 inet static
       address '${STATIC_IP[$i-1]}'
       netmask 255.255.255.0" | sudo tee -a /etc/network/interfaces'
     echo " "
     echo "Enabling ens4:0 network interface on ${SERVER}-${i} ..."
     gcloud compute ssh --zone ${REGION}-${ZONES[$i-1]} ${SERVER}-${i} --command "sudo ifup ens4:0"
     echo " "
     #

     # format disk1
     echo "Formating the disk if not formated already ..."
     gcloud compute ssh --zone ${REGION}-${ZONES[$i-1]} ${SERVER}-${i} --command "sudo file -sL /dev/sdb | grep XFS || sudo mkfs.xfs -i size=512 /dev/sdb"
     echo " "
     echo "Mount the brick1"
     gcloud compute ssh --zone ${REGION}-${ZONES[$i-1]} ${SERVER}-${i} --command "sudo mkdir -p /data/brick1 && echo '/dev/sdb /data/brick1 xfs defaults 1 2' | sudo tee -a /etc/fstab && sudo mount -a && mount"
     echo " "

     # Install GlusterFS server
     echo "Install GlusterFS server"
     gcloud compute ssh --zone ${REGION}-${ZONES[$i-1]} ${SERVER}-${i} --command "yes | sudo apt-get install glusterfs-server"
     echo " "

     # Set internal static IP route
     # Create the route for VM's static IP
     echo "Creating the route for ${SERVER}-${i} static IP ${STATIC_IP[$i-1]} ..."
     gcloud compute routes create ip-${SERVER}-${i} \
         --next-hop-instance ${SERVER}-${i} \
            --next-hop-instance-zone ${REGION}-${ZONES[$i-1]} \
                --destination-range ${STATIC_IP[$i-1]}/32
    echo " "
done

echo " "
echo "Configure the trusted pool ..."
for (( i=2; i<=${COUNT}; i++ ))
do
  echo "Configure the trusted pool for ${SERVER}-${i} ..."
  gcloud compute ssh --zone ${REGION}-${ZONES[0]} ${SERVER}-1 --command "sudo gluster peer probe ${SERVER}-${i}"
done

echo " "
echo "The end ..."
