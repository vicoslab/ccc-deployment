# Ansible deployment for Conda Compute Cluster

Ansible based playbooks for the deployment and orchestration of the Conda Compute Cluster. Two playbooks are available:

* `cluster-deploy.yml`: deployment of cluster infrastructure (network, docker, FRP client, ZFS, NFS, FS-Cache, HW monitoring, GPU fan controlers, etc.)
* `containers-deploy.yml`: depyloment of compute containers based on Conda Compute Container (CCC) images

## Deploy cluster infrastructure:

Run the following command to deploy the infrastructure:
```bash
ansible-playbook cluster-deploy.yml -i <path-to-invenotry> \
                 --vault-password-file <path-to-secret> -e vars_file=<path-to-secret-vars-dir> \
                 -e machines=<node-or-group-pattern> \
                 -e only_roles=<list of roles> 
```

#### Inventory/nodes:
You can specifcy the cluster definition in the supplied inventory folder. See `sample-invenotry` for example. Tasks are deployed on the nodes defined by the `-e machines=<node-or-group-pattern>`. 

#### Roles:
By default all roles are executed in the order as specifid below. Deployment can be limited to only specific roles by supplying `-e only_roles=<list of roles>`. List of roles can be comma seperated list of role names:
* `netplan`: network intrface definition using [netplan](roles/netplan/tasks/main.yml)
* `docker`: [docker](roles/docker/tasks/docker.yml) with pre-defined [docker neworks](roles/docker/tasks/deploy-networks.yml), [repository logins](roles/docker/tasks/login-repository.yml) and [portrainer agent](roles/docker/tasks/deploy-portrainer-agent.yml) for GUI management
* `frp-client`: [FRP client](roles/frp-client/tasks/main.yml) for access to containers through the proxy server
* `zfs`: [ZFS pools](roles/zfs/tasks/main.yml) for local storage
* `cachefilesd`: [FS-Cache](roles/cachefilesd/tasks/main.yml) for caching of the NFS storage into local scratch disks
* `nfs-storage`: [NFS storage](roles/nfs-storage/tasks/main.yml) for shared storage (needed for shared `/home/user` over all compute nodes)
* `superfan-gpu`: [superfans GPU controller](roles/superfan-gpu/tasks/main.yml) for regulating SYSTEM FANs based on GPU temperature
* `monitoring-agent`: [HW monitoring](roles/monitoring-agent/tasks/main.yml) for providing Prometheus metrics of CPU and GPUs
* `compute-container-nightwatch`: [CCC nightwatch](roles/compute-container-nightwatch/tasks/main.yml) for providing automatic updated of the compute container upon changes to to the Ansible config or user-supplied config
* `patroller`: [GPU Patroler](roles/patroller/tasks/main.yml) for automatic GPU reservation system based on (https://github.com/vicoslab/patroller)[https://github.com/vicoslab/patroller]
* `sshd-hostkey`: not an actual role but a minor task to deploy ssh-daemon keys for CCC containers

#### Example of the cluster-wide config organization:

Example of how to provide cluster configurations is in the `sample-inventory` folder that includes:

* hosts definitions: [`your-cluster.yml`](sample-inventory/your-cluster.yml) with `ccc-cluster` as main group of your cluster nodes
* cluster settings: [`group_vars/ccc-cluster/cluster-vars.yml`](sample-inventory//group_vars/ccc-cluster/cluster-vars.yml)
* cluster secrets: [`vault_vars/cluster-secrets.yml`](sample-inventory/vault-vars/cluster-secrets.yml) (requires --vault-password-file to unlock)
* host-specific settings: [`sample-inventory/host_vars`](sample-inventory/host_vars)

Cluster-wide settings contain principal configuration of the whole cluster and are sectioned into settings for individual roles. Settings are used both by the `cluster-deploy.yml` and `containers-deploy.yml` playbooks. 

##### Cluster secrets 
Cluster secrets are stored in seperate `vault_vars` folder and should not be in present in `group_vars` to allow running `containers-deploy.yml` without needing vault secret. Secrets can be instead loaded for cluster deployment using `-e vars_file=<path-to-secret-vars-dir>` which will load vars only for `cluster-deploy.yml` playbook.

## Deploy compute containers

Run the following command to deploy compute containers:
```bash
ansible-playbook containers-deploy.yml -i <path-to-invenotry> \
                 -e machines=<node-or-group-pattern> \
                 -e containers=<list of STACK_NAME> \
                 -e users=<list of USER_EMAIL>
```

#### Containers filtering

By default all containers are deployed!! 

To limit the deployment of only specific containers two additional filters can be used. For both filters, the provided values must be a comma separated list in a string format: 

* `-e containers=<list of STACK_NAME>`: filters based on containers` STACK_NAME value
* `-e users=<list of USER_EMAIL>`: filters based on containers` USER_EMAIL value

#### Container deployment config:

List of containers for deployment and list of users are stored need to be set in the invenotry configuration:

* yaml variable `deployment_containers`: list of containers for deployment (e.g., see [`group_vars/ccc-cluster/user-containers.yml`](sample-inventory/group_vars/ccc-cluster/user-containers.yml))
* yaml variable `deployment_users`: list of users for deployment (e.g., see [`group_vars/ccc-cluster/user-list.yml`](sample-inventory/group_vars/ccc-cluster/user-list.yml))
* yaml variable `deployment_types`: list of users types (e.g., see [`group_vars/ccc-cluster/user-list.yml`](sample-inventory/group_vars/ccc-cluster/user-list.yml))

##### Example of the container config organization :

Example of how to provide cluster configurations is in the `sample-inventory` folder that includes:

* list of containers for deployment as `deployment_containers` var in [`group_vars/ccc-cluster/user-containers.yml`](sample-inventory/group_vars/ccc-cluster/user-containers.yml)
* list of users for deployment as `deployment_users` var in [`group_vars/ccc-cluster/user-list.yml`](sample-inventory/group_vars/ccc-cluster/user-list.yml)
* list of users types as `deployment_types` var in [`group_vars/ccc-cluster/user-list.yml`](sample-inventory/group_vars/ccc-cluster/user-list.yml)

##### User containers for deployment

Each container for depoyment must be provided in `deployment_containers` variable as an array/list of dictionary with the following keys for each container:
* `STACK_NAME`: name of the compute containers
* `CONTAINER_IMAGE`: container image that will be deployed (e.g., "registry.vicos.si/ccc-juypter:ubuntu18.04-cuda10.1")
* `USER_EMAIL`: user's email
* `INSTALL_PACKAGES`: additional apt packages that are installed at startup (registry.vicos.si/ccc-base:<...> images do not provide sudo access by default !!)
* `INSTALL_REPOSITORY_KEYS`: comma separated list of links to fingerprint keys for installed repositoriy sources (added using `apt-key add`)
* `INSTALL_REPOSITORY_SOURCES`: comma separated list repositoriy sources (`deb ...` sources or `ppa` links that can be added using `add-apt-repository`)
* `SHM_SIZE`: shared memory settings
* `FRP_PORTS`: `dict()` with TCP and HTTP keys with info of the forwarded ports to the FRP server
  * `TCP`: a list of tcp ports as string values
  * `HTTP`: a list of http ports as `dict()` objects with `port`, `subdomain`, `pass` (optional), `health_check` (optional) and `subdomain_hostname_prefix` (optional - bool) keys

##### Centralized user information 

User informations can be centralized in separate file for quick reuse. Containers and users are matched based on emails. The following user information must be present within the `deployment_containers[<USER_EMAIL>]` dictionary:

* `USER_FULLNAME`: user's first and last name (from 
* `USER_MENTOR`: user's mentor (optional)
* `USER_NAME`: username for the OS
* `USER_PUBKEY`: SSH public key for access to the compute containre
* `USER_ACCESS`: either 'unlimited' or 'restricted' (relates to LAN access, which should be restricted for outside users)

## Feature list

- [x] setting docker repository login from config
- [x] encrypted data for authentication settings
- [x] can deploy compute-container only to specific group nodes (student or lab nodes) or specific node 
- [x] can control deploying compute-container through config
- [x] support for NVIDIA GPU driver installation
- [x] performance tunded NFS mount settings with FS-cache
- [x] custom ZFS storage mounting
- [x] IPMI FAN controler using NVIDIA GPU temperatures (designed for supermicro server)
- [x] centralized storage of users (with thier names, email and PUBKEY) in a single file
- [x] loading of SSH pubkey from GITHUB
- [x] prometheus export for monitoring of the HW (for CPU and GPU - GPU utilization, temperature, etc) 
- [x] users can provide custom settings inside of the containers by editing ~/.containers/<STACK_NAME>.yml file
- [x] compute-container-nightwatch that monitors ~/.containers/<STACK_NAME>.yml files and redeploys them using ansible-pull

## TODO list:

- [ ] enable of redirection of container loging output to the user 
