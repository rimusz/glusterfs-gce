# Bootstrap HA GlusterFS Cluster in GCE

As you know shared file systems are a tricky problem. One solution to that problem is a distributed file system. Something that your apps can read from and write to. When it comes to distributed file systems, [GlusterFS](https://www.gluster.org) is one of the leading products.

With a few simple scripts on your Mac OS X or Linux machine, you can deploy a multi-zone HA GlusterFS cluster to [Google Compute Engine](https://cloud.google.com/compute/) (GCE) that provides scalable, persistent shared storage for your GCE or [Google Container Engine](https://cloud.google.com/container-engine/) (GKE) [Kubernetes](http://kubernetes.io) clusters.

By default it is set to three GlusterFS servers, one server per Google Cloud zone in the same chosen region.


## Prerequisites

Before continuing, please make sure you have:

* A [Google Cloud](https://cloud.google.com) account
* The [Google Cloud SDK](https://cloud.google.com/sdk/) installed
* Git installed

### Clone this project and set settings:
````
$ git clone https://github.com/rimusz/glusterfs-gce
$ cd glusterfs-gce/cluster
````
* Edit the `cluster/settings` file and set `PROJECT, REGION and ZONES`, the rest of settings in this file are probably fine, but can be adjusted if need be.

### Bootstrap the cluster
```
$ ./create_cluster.sh
```
This command will create three servers.

Each server will have:

* A static IP
* The GlusterFS server package installed
* A Google Cloud persistent disk to be used as a GlusterFS *brick*, that is: storage space made available to the cluster

### Create volumes

A GlusterFS *volume* is a collection of bricks. A volume can store data across the bricks in three basic ways: distributed, striped, or replicated.

With the script below you will be able to create GFS replicated volumes on all three servers automaticly:

```
$ cd ..
$ ./create_volume.sh VOLUME_NAME
```

##### At this point, your GlusterFS cluster should be fully set up and operational

You can check Kubernetes GlusterFS [example](https://github.com/kubernetes/kubernetes/tree/release-1.2/examples/glusterfs/) how to use GlusterFS with Kubernetes.


### Extras

In `cluster` folder there are two more scripts:

* `upgrade_glusterfs.sh	` - allows to upgrade GlusterFS server package on all servers
* `upgrade_servers.sh` - runs `apt-get update && apt-get upgrade` on all servers


### Delete the cluster
```
$ ./delete_cluster.sh
```
This command will deletec all whole cluster.

