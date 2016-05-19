# Bootstrap GlusterFS Cluster in GCE

With a few simple scripts on your Mac OS X or Linux computer, you can deploy [GlusterFS](https://www.gluster.org) cluster to [GCE](https://cloud.google.com/compute/) and use for [GCP](https://cloud.google.com) [GKE](https://cloud.google.com/container-engine/)/[Kubernetes](http://kubernetes.io) clusters as a persistent scalable storage.

By default it is set to three GlusterFS servers.



### Install dependencies if you do not have them on your OS X/Linux:

* You need Google Cloud account and [GC SDK](https://cloud.google.com/sdk/) installed
* git


### Clone this project and set settings:
````
$ git clone https://github.com/rimusz/glusterfs-gce
$ cd glusterfs-gce/cluster
````
* Edit `settings` and set `project, region and zones`, the rest of settings you can adjust by your requirements if you need to.

### Bootstrap cluster
```
$ ./create_cluster.sh
```
* That will create for you three servers, each of them will have GC persistent disk to be used as a brick.
* GlusterFS server package will be installed
* Each server will get the static IP set

### Create volumes
With the script below you will be able to create GFS volumes on all three servers automaticly:

```
$ cd ..
$ ./create_volume.sh your_volume_name
```

##### At this point you should have your GlusterFS cluster fully set
You can check Kubernetes GlusterFS [example](https://github.com/kubernetes/kubernetes/tree/release-1.2/examples/glusterfs/) how to use GlusterFS with Kubernetes.


### Extras

In `cluster` folder there are two more scripts:

* `upgrade_glusterfs.sh	` - allows to upgrade GlusterFS server package on all servers
* `upgrade_servers.sh` - runs `apt-get update && apt-get upgrade` on all servers
