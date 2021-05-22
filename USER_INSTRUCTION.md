# User instruction for using Conda Compute Containers

## Container image

Each container is based on [`vicoslab/ccc:base`](https://github.com/vicoslab/ccc/blob/master/base/Dockerfile) image that provides:
 * Miniconda (at `/home/USER/conda`) and python 3
 * SSH access
 * Optional installation of apt packages during startup ([see below](#container-customization))

Several existing images can be used with specific pre-installed software. For list of available docker images see [vicoslab docker hub](https://hub.docker.com/r/vicoslab/ccc). User can also customize the contianer by creating its own docker image based on `vicoslab/ccc:base` with any pre-installed software ([see instructions below](#custom-docker-image)).

## Access to contianers

Default access to the contianer is through **SSH with the private/public key**. The list of access points and ports is automatically sent to the user via email when container is created or updated. 

### Container data and mount-points

By default container is in read-only mode and only `/home/USER` is accessible to the user. Additional mountpoints are also provided with various types of storage:
 * shared group storage
 * user specific storage
 * local machine HDD and/or SSD storage (NOTE: must be considerd as volatile storage that can disappear)
 
Mountpoint locations to specific storages are displayed at the SSH login wellcome message.

### Storage accessible from multiple nodes/machines

The following storage runs on NFS and is accessible from all containers running on different nodes/machines:
 * `/home/USER`
 * shared group storage
 * user specific storage

### Container packages and software

New packages can only be installed using Conda and/or pip to local home folder. Due to shared home folder this enables software installed on one node to be immediately available on other nodes where containers are running. 

**Privilaged access and `sudo` are disabled.** Additional apt-get packages can be installed through container customization or through custom docker images.

## Container customization

Several container setttings can be controlled from within container by updating `/home/USER/.container/<container-name>.yml` file. The following settings can be specificed in YAML dictionary:
 * CONTAINER_IMAGE: docker image to deploy (must be parent of [`vicoslab/ccc:base`](https://github.com/vicoslab/ccc/blob/master/base/Dockerfile))
 * DEPLOYMENT_NODES: list of nodes/machines where container is deployed (e.g., ['node1', 'node2', 'node3'])
 * USER_PUBKEY: linux SSH public key
 * USER_PUBKEY_FROM_GITHUB: github user account name with valid SSH pubkey that will be installed
 * USER_NAME: linux account username
 * INSTALL_PACKAGES: list of APT packages to install at stratup time (e.g., 'nano htop tmux screen')
 * INSTALL_REPOSITORY_KEYS: comma separated list of URLs to GPG keys that will be installed at startup-time using `wget -qO - "<KEY>" | apt-key add -` before package instalation
 * INSTALL_REPOSITORY_SOURCES: comma separated list of sources that will be installed at startup-time using `add-apt-repository -y "<SOURCE>"` before package instalation
 * SHM_SIZE: docker shared memory (defaults to '2gb')
 
**NOTE: Changes will take affect in 10-20 seconds after .yml file is updated. During the update process container is restarted and will not be accessible for 30-40 seconds. Do NOT forget to save any changes in files and processes before updating .yml file.**
 
 Example of YAML configuration file for contianer named `my-container-name`:
 
 ```yaml 
my-container-name:
  CONTAINER_IMAGE: "vicoslab/ccc:x2go-v1.01-ubuntu18.04-cuda11.0"
  DEPLOYMENT_NODES: ['node1','node2']
  INSTALL_PACKAGES: "rsync nano htop build-essential cmake cmake-curses-gui"
  SHM_SIZE: 4GB
 ```
 

### Custom docker image

For any changes to container that cannot be implemented in above .yml file, you can provide your own custom built docker image by setting CONTAINER_IMAGE in the .yml configuration file. 

Custom docker image MUST be based on [`vicoslab/ccc:base`](https://github.com/vicoslab/ccc/blob/master/base/Dockerfile). Base image provides `runit` scripts for services and startup initialization. For more information see [CCC github page](https://github.com/vicoslab/ccc).
