# Jupyter Notebook for IBM z/OS Platform for Apache Spark

The Jupyter Notebook for IBM z/OS Platform for Apache Spark is based on the [Jupyter Notebook](https://jupyter.org/) server.

This README demonstrates how to build the workbench as a Docker image, and how to run the workbench image as a Docker container on a Docker Machine-controlled host.

>This approach is based on Java RMI and as such depends on a tight coupling between the client and server libraries.

## Prerequisites

* [Docker Engine](https://docs.docker.com/engine/) 1.10.0+
* [Docker Machine](https://docs.docker.com/machine/) 0.6.0+
* [Docker Compose](https://docs.docker.com/compose/) 1.6.0+
* Host running IBM z/OS Platform for Apache Spark obtained through [ShopzSeries](http://www.software.ibm.com/ShopzSeries)

See the [Docker installation instructions](https://docs.docker.com/engine/installation/) for your environment, and see the [zSpark installation instructions](<FIX HERE>) for details on how to setup your Spark environment.



## Getting Started
To run the workbench on your local desktop, follow the steps below.  By doing so, you will:

* Download required JAR files
* Create a new VirtualBox virtual machine on your local desktop
* Build the workbench Docker image on the VM
* Run a workbench Docker container on the VM

### Download JAR files

* **IBM JAVA 8R2 SDK**: Download the IBM JAVA 8R2 sdk for 64-bit AMD/Opteron/EM64T > Installable package (InstallAnywhere as root) from [IBM Developer Works](http://www.ibm.com/developerworks/java/jdk/linux/download.html) and save it in the project home as `ibm-java-x86_64-sdk-8.0-2.10.bin`

	**NOTE: The project is tied to IBM Java 8R2, so you need ibm-java-x86_64-sdk-8.0-2.10.bin**

* **Spark assembly**: Download the `spark-assembly-1.5.2-hadoop2.6.0.jar` file and save it in the project home.  This is part of IBM z/OS Platform for Apache Spark obtained through [ShopzSeries](http://www.software.ibm.com/ShopzSeries).

* **Spark Kernel**: Download the `spark-kernel-0.1.5-SNAPSHOT_zOS.zip` and save it in the project home.  This can be obtained from [IBM Developer Works]().

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

You must set the Spark master for the IBM z/OS Platform for Apache Spark.  You can do this by setting the `SPARK_HOST` environment variable.  For example:

```
export SPARK_HOST=10.0.0.10
```

You can also optionally set the port number of the Spark master (default is 7077):

```
export SPARK_PORT=7077
```

Build the Docker image.

```
sh build.sh
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

To access the workbench, visit `http://<mymachine_ip_address>:8888` in your web browser.

### Managing Containers

To stop and remove the `scala-workbench` container, run

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

#### Passing Environment Variables to the Container

You may wish to make certain environment variables available to your notebooks.  The `docker-compose.yml` passes the following variables, if set: `JDBC_USER`, `JDBC_PASS`, `JDBC_HOST`, `MONGO_USER`, `MONGO_PASS`, and `MONGO_HOST`.

Example:

```
export JDBC_HOST=10.0.0.11
export JDBC_USER=dbuser
export JDBC_PASS=dbpass

sh start.sh
```

## Demo Notebooks
There are a series of demo notebooks located in the demos directory.  To use the demos, simply drag and drop them onto your workbench then run the application.  The demo may need to be modified before use, but each demo will have instructions on what needs to be modified.

The following are examples of files you might wish to download:

*  imsudb.jar -> You can find this IMS™ Universal driver in, for example, ```/usr/lpp/ims/ims13/imsjava/imsudb.jar```
*  db2jcc_license_cisuz.jar -> You can find this IBM® Data Server Driver for JDBC and SQLJ in, for example, ```/usr/lpp/db2b10/classes/db2jcc_license_cisuz.jar```
*  db2jcc4.jar -> You can find this IBM® Data Server Driver for JDBC and SQLJ in, for example, ```/usr/lpp/db2b10/classes/db2jcc4.jar```
*  dv-jdbc-3.1.22510.jar -> The Rocket JDBC driver is supplied as with the IBM z/OS Platform for Apache Spark obtained through [ShopzSeries](http://www.software.ibm.com/ShopzSeries).


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

Yes.  You can customize the workbench image by modifying the files in the `template` directory.  For example, you can install the `pymongo` and `python-twitter` Python libraries by adding the following lines to the bottom of the Dockerfile:

```
RUN pip install \
    pymongo==3.2.1 \
    python-twitter==2.2
```

Once you modify the Dockerfile, you need to rebuild the image and restart the notebook container before the changes will take effect.

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
