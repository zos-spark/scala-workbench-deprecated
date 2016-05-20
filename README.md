# Scala Workbench for IBM z/OS Platform for Apache Spark

The Scala Workbench for IBM z/OS Platform for Apache Spark is based on [Project Jupyter](https://jupyter.org/).

This README demonstrates how to build the workbench as a Docker image, and how to run the workbench image as a Docker container on a Docker Machine-controlled host.

>This approach is based on Java RMI and as such depends on a tight coupling between the client and server libraries.

## Prerequisites

As per the [Reference Architecture Diagram](https://ibm.box.com/shared/static/xm05xl372hkbmmj4eu9fhoq0kplytzp3.png), the following components of a deployment topology are required:

* IBM z/OS Platform for Apache Spark
  * [ShopZ - Product Ordering Details](https://www-304.ibm.com/software/shopzseries/ShopzSeries_public.wss)
  * [Installation Instructions](http://www-03.ibm.com/support/techdocs/atsmastr.nsf/WebIndex/WP102609) for details on how to setup your Spark environment.
* Docker Environment for Scala Workbench
  * As per the [Apache Spark component architecture requirements](https://spark.apache.org/docs/0.8.0/cluster-overview.html), a *driver program* should be run close to the worker nodes, preferably on the same local area network. The *driver program* must be network addressable to all nodes in the Spark cluster. **This implies that the target physical or virtual machine for the Scala Workbench must be located within the same network addressable enironment as the hosted instance of IBM z/OS Platform for Apache Spark**.
  * See the [Docker installation instructions](https://docs.docker.com/engine/installation/) for your target docker environment. **Note: Testing has been done using Docker on Ubuntu (baremetal and VM)**.
    * [Docker Engine](https://docs.docker.com/engine/) 1.10.0+
    * [Docker Machine](https://docs.docker.com/machine/) 0.6.0+
    * [Docker Compose](https://docs.docker.com/compose/) 1.6.0+

## Getting Started
This project uses [Docker Machine](https://docs.docker.com/machine/overview/) as a tool on your local desktop to provision and manage your target docker environment for the Scala Workbench. Your target docker environment needs to be a physical or virtual machine located within the same network addressable enironment as the hosted instance of IBM z/OS Platform for Apache Spark.

![docker machine](https://docs.docker.com/machine/img/machine.png)

To prepare your local desktop, follow the steps below:

* Download required JAR files
* Create a new VirtualBox virtual machine on your local desktop
* Build the workbench Docker image on the VM
* Run a workbench Docker container on the VM

### Download Dependency files

* **IBM JAVA 8R2 SDK**: Download the IBM JAVA 8R2 sdk for 64-bit AMD/Opteron/EM64T > Installable package (InstallAnywhere as root) from [IBM Developer Works](http://www.ibm.com/developerworks/java/jdk/linux/download.html) and save it in the project home as `ibm-java-x86_64-sdk-8.0-2.10.bin`

	**NOTE: The project is tied to IBM Java 8R2, so you need ibm-java-x86_64-sdk-8.0-2.10.bin**

* **Spark assembly**: Download the `spark-assembly-1.5.2-hadoop2.6.0.jar` file and save it in the project home.  This is part of IBM z/OS Platform for Apache Spark obtained through [ShopzSeries](https://www-304.ibm.com/software/shopzseries/ShopzSeries_public.wss).


### Create or connect to a Docker host (optional)

This step is optional if you are already on a host that supports the Docker Engine.  

```
# Optional step to create a New Docker Machine
# create a Docker Machine-controlled VirtualBox VM
docker-machine create --driver virtualbox --virtualbox-memory "4096" --virtualbox-cpu-count "4" mymachine

# activate the docker machine
eval "$(docker-machine env mymachine)"

#You can retrieve the IP address using:
docker-machine ip mymachine
```

### Build the Workbench Docker Image

Build the workbench Docker image.  The image will include a Jupyter Notebook server, Spark binaries, and other packages and libraries that allow you to connect to IBM z/OS Platform for Apache Spark.

You must set the Spark master for the IBM z/OS Platform for Apache Spark.  You can do this by setting the `SPARK_HOST` environment variable.  An example build would be:

```
SPARK_HOST=10.0.0.10 sh build.sh
```

The image will show up as `zos-spark/scala-notebook`.

```
docker images

REPOSITORY                   TAG         IMAGE ID            CREATED             SIZE
zos-spark/scala-notebook     latest      bbde4459bd98        10 seconds ago      5.244 GB
```

### Run the Workbench Container

To create and start a workbench container, run the `start.sh` script.

```
sh start.sh
```

This will create a container called `scala-workbench`.

```
docker ps 

CONTAINER ID        IMAGE                        NAMES
a72b4589135a        zos-spark/scala-notebook     scala-workbench
```

To access the workbench, point your web browser to

```
http://<mymachine_ip_address>:8888
```

### Manage Containers

To create and start a workbench container:

```
sh start.sh
```

To stop and remove the workbench container:

```
sh stop.sh
```

You can specify the container name and the port that the container binds to on the host by setting the `WORKBOOK_NAME` and `WORKBOOK_PORT` environment variables, respectively.  For example, to start the workbench container with the name `my-workbench` on port 8889, run:

```
WORKBENCH_NAME=my-workbench WORKBENCH_PORT=8889 sh start.sh
```

To stop the `my-workbench` container:

```
WORKBOOK_NAME=my-workbench sh stop.sh
```

## Demo Notebooks
The ```demos``` directory contains sample Scala notebooks.  To use these notebooks, simply drag and drop them onto your workbench then run each notebook. The notebooks may need to be modified before use, but each notebook will have instructions on what needs to be modified.

Depending on the data sources that your Scala notebook will access, you may need to load specifc drivers into your notebook. The following are examples of files you might wish to download and load in your notebook using the ```%addjar``` directive:


*  JDBC driver for Mainframe Data Service for IBM z/OS Platform for Apache Spark: . This driver is part IBM z/OS Platform for Apache Spark release, delivered here for your convenience. Mainframe Data Service component of IBM z/OS Platform for Apache Spark provides optimized access to a wide range of data sources for example VSAM, SMF, Adabas, Physical Sequential files, IMS.
	* [Learn more...](http://www.rocketsoftware.com/solutions/data-virtualization) 
  	* [Download](https://download.rocketsoftware.com/ro/d/290841BC62A7437A8E08F6C2778E3DF1) directly from Rocket Support
  
## Troubleshooting

### Upgade the Docker Machine
When encountering a message similar to "ERROR: Service 'notebook' failed to build: Network timed out while trying to connect to https://index.docker.io/v1/repositories/jupyter/minimal-notebook/images. You may want to check your internet connection or if you are behind a proxy."

 ```
 # Upgrade the Docker Machine (example machine name: mymachine)
 docker-machine upgrade mymachine
 ```


## FAQ

### Can I deploy to any host?

You can build and run the Docker images in this repo on any host that supports a recent version of [Docker Engine](https://docs.docker.com/engine/).  

This repo assumes that you are using [Docker Machine](https://docs.docker.com/machine/) to provision and manage multiple remote Docker hosts.

To make it easier to get up and running, this repo includes scripts that use Docker Machine to provision new virtual machines on both VirtualBox and IBM SoftLayer.

To create a Docker Machine on a new VirtualBox VM on your local desktop:

```
bin/vbox.sh mymachine
```

To create a Docker Machine on a new virtual device on IBM SoftLayer:

```
# Set SoftLayer credential as environment variables to be
# passed to Docker Machine
export SOFTLAYER_USER=my_softlayer_username
export SOFTLAYER_API_KEY=my_softlayer_api_key
export SOFTLAYER_DOMAIN=my.domain

# Create virtual device
bin/softlayer.sh myhost

# Add DNS entry (SoftLayer DNS zone must exist for SOFTLAYER_DOMAIN)
bin/sl-dns.sh myhost
```

In addition, you can use the scripts in this repo to build and run the workbench image on any other Docker Machine-controlled host.

### How do I deploy to an existing host?

To build and run the Docker images in this repo on an existing host, you simply need to add the host as a Docker machine.   All you need is the server's IP address, and the ability to login to the server using an SSH keypair.

Here's an example of creating a Docker Machine on your local desktop that points to the remote server at `10.0.0.10` using Docker Machine's `generic` driver.  

Be aware: this command will attempt to install Docker Engine on the host if it is not already present.

```
docker-machine create --driver generic \
  --generic-ip-address 10.0.0.10 \
  --generic-ssh-key /path/to/my/ssh/private/key \
  mymachine
```

You should see output similar to this:

```
Running pre-create checks...
Creating machine...
(mymachine) Importing SSH key...
Waiting for machine to be running, this may take a few minutes...
Detecting operating system of created instance...
Waiting for SSH to be available...
Detecting the provisioner...
Provisioning with ubuntu(upstart)...
Installing Docker...
Copying certs to the local machine directory...
Copying certs to the remote machine...
Setting Docker configuration on the remote daemon...
Checking connection to Docker...
Docker is up and running!
To see how to connect your Docker Client to the Docker Engine running on this
  virtual machine, run: docker-machine env mymachine
```

To view the machine details:

```
docker-machine ls

NAME               ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER    ERRORS
softlayer          -        generic      Running   tcp://10.0.0.10:2376               v1.10.1    
```

To run Docker commands on `mymachine`, activate it by running:

```
eval "$(docker-machine env mymachine)"
```

### Can I customize the workbench image?

Yes.  You can customize the workbench image by modifying the `Dockerfile` and rebuilding the image.  

For example, you can install the `pymongo` and `python-twitter` Python libraries by adding the following lines:

```
RUN pip install \
    pymongo==3.2.1 \
    python-twitter==2.2
```

Once you modify the `Dockerfile`, you must rebuild the workbench image and restart the notebook container before the changes will take effect.

```
# rebuild the notebook image
sh build.sh

# restart the notebook container
sh stop.sh
sh start.sh
```


## Troubleshooting

### Unable to connect to VirtualBox VM on Mac OS X when using Cisco VPN client.

The Cisco VPN client blocks access to IP addresses that it does not know about, and may block access to a new VM if it is created while the Cisco VPN client is running.

1. Stop Cisco VPN client. (It does not allow modifications to route table).
2. Run `ifconfig` to list `vboxnet` virtual network devices.
3. Run `sudo route -nv add -net 192.168.99 -interface vboxnetX`, where X is the number of the virtual device assigned to the VirtualBox VM.
4. Start Cisco VPN client.
