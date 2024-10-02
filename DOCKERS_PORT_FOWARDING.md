# Docker images 

Swicth container to different docker image by changing CONTAINER_IMAGE setting in the .yml configuration file inside the container (i.e., `/home/USER/.containers/<container-name>.yml`).

Docker images are available in hub as `vicoslab/ccc:[TYPE]-v1.09-ubuntu[UBUNTU_VERSION]-cuda[CUDA_VERSION]`. The following container image types are avilable:
* `base` ([Dockerfile](https://github.com/vicoslab/ccc/blob/master/base/Dockerfile))
* `vscode` ([Dockerfile](https://github.com/vicoslab/ccc/blob/master/vscode/Dockerfile))
* `jupyter` ([Dockerfile](https://github.com/vicoslab/ccc/blob/master/jupyter/Dockerfile)) (since v1.09 supported only on Ubuntu 22.04) 
* `x2go` ([Dockerfile](https://github.com/vicoslab/ccc/blob/master/x11/Dockerfile))
* `xpra` ([Dockerfile](https://github.com/vicoslab/ccc/blob/master/x11/Dockerfile)) 
* (deprecated since v1.09) `jetbrains-projector` ([Dockerfile](https://github.com/vicoslab/ccc/blob/master/jetbrains-projector/Dockerfile))

[See ViCoS Docker HUB for more detailed list on available images and versions.](https://hub.docker.com/r/vicoslab/ccc) 

# Port Forwarding

You will need to correctly setup HTTP PORT FORWARDING in the .yml file (`/home/USER/.containers/<container-name>.yml`) to access the services (for VS Code, Jupyter, Xpra) from browser: 

 ```yaml 
my-container-name:
  ...
  FRP_PORTS:
    TCP: [22,] # KEEP PORT 22 FOR SSH !!
    HTTP:         
      - { port: "8080", subdomain: "your_subdomain_a", pass: "your_http_pass", health_check: "false", https_without_pass: False}
      - { port: "6006", subdomain: "your_subdomain_b", pass: "your_http_pass", health_check: "false", https_without_pass: False}
```

This will forward the HTTP ports 8080 and 6006 to the container. You can access the services from the browser by visiting:
  * `http://your_subdomain_a.your_domain.com` for service at HTTP port 8080
  * `http://your_subdomain_b.your_domain.com` for service at HTTP port 6006

**WARNING: Setting `FRP_PORTS` will override any values set as default by admin. You need to include ALL ports you want to forward in the list, including port 22 for SSH.**

## VS Code IDE Web-Server

Access VS Code IDE at `http://user:your_http_pass@your_subdomain_vscode.your_domain.com/?tkn=[TOKEN]` by setting:

 ```yaml 
my-container-name:
  CONTAINER_IMAGE: "vicoslab/ccc:vscode-v1.09-ubuntu22.04-cuda12.6.1"
  ...
  FRP_PORTS:
    TCP: [22,] # KEEP PORT 22 FOR SSH !!
    HTTP:         
      - { port: "9999", subdomain: "your_subdomain_vscode", pass: "your_http_pass", health_check: "false"}
```

Retrieve the `[TOKEN]` from the `~/vscode.token` on server or from the welcome message in SSH.

## Jupyter 

Access Jupyter notebook at `http://user:your_http_pass@your_subdomain_jupyter.your_domain.com` by setting:

 ```yaml 
my-container-name:
  CONTAINER_IMAGE: "vicoslab/ccc:jupyter-v1.09-ubuntu22.04-cuda12.6.1"
  ...
  FRP_PORTS:
    TCP: [22,] # KEEP PORT 22 FOR SSH !!
    HTTP:         
      - { port: "8080", subdomain: "my_subdomain_jupyter", pass: "your_http_pass", health_check: "false"}
```

Retrieve the `[TOKEN]` from the `~/jupyter.token` on server or from the welcome message in SSH.

## Xpra

Access Xpra HTTP service at `http://user:your_http_pass@your_subdomain_xpra.your_domain.com` by setting:

 ```yaml 
my-container-name:
  CONTAINER_IMAGE: "vicoslab/ccc:xpra-v1.09-ubuntu22.04-cuda12.6.1"
  ...
  FRP_PORTS:
    TCP: [22,] # KEEP PORT 22 FOR SSH !!
    HTTP:         
      - { port: "8080", subdomain: "my_subdomain_xpra", pass: "your_http_pass", health_check: "false"}
```

Retrieve the `[TOKEN]` from the `~/jupyter.token` on server or from the welcome message in SSH.

## Tensorboard (recommended to enabled by default)

By default, we would add port forwarding for Tensorboard at HTTP port 6006, which can be accessed at `http://user:your_http_pass@your_subdomain_tensorboard.your_domain.com` by setting:

 ```yaml 
my-container-name:
  CONTAINER_IMAGE: "vicoslab/ccc:base-v1.09-ubuntu22.04-cuda12.6.1"
  ...
  FRP_PORTS:
    TCP: [22,] # KEEP PORT 22 FOR SSH !!
    HTTP:         
      - { port: "6006", subdomain: "your_subdomain_tensorboard", pass: "your_http_pass", health_check: "false"}
```

