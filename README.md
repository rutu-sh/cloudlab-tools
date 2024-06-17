# cloudlab-tools

This repository contains the necessary setup tools for working in CloudLab. The intention is to standardize and speed-up the process of setting up the cloudlab environment for various research projects. Though it is extensively used on cloudlab, it can be used to setup any linux machine. Use it as a standalone setup tool for your experiments or import it as a submodule in your repository.

This repository contains the setup scripts for the following tools: 
1. [Generic](tools/generic/README.md) - contains generic setup tools like Go, docker, etc. 
2. [eBPF](tools/ebpf/README.md) - contains setup tools for eBPF.
3. [DPDK](tools/dpdk/README.md) - contains setup tools for DPDK.
4. [OpenNetVM](tools/onvm/README.md) - contains setup tools for OpenNetVM.

## Setting up CloudLab 

1. Create an account on [CloudLab](https://www.cloudlab.us/).
2. Create an experiment using a profile of your choice. This repository is tested with Ubuntu 22.04 nodes, so make sure to select the appropriate profile. If you don't know which profile to select use the following: 
    - Profile: [small-lan](https://www.cloudlab.us/p/PortalProfiles/small-lan)
    - Physical Node Type: c220g2/c220g5 
    - OS Image: Ubuntu 22.04
3. Wait for the experiment to be ready. Once the experiment is ready, cloudlab will show the status as "ready". 
4. Copy the public IP address of the node (ex: `c220g2-010606.wisc.cloudlab.us`, `c220g2-010608.wisc.cloudlab.us`, etc) and paste it to the `.cloudlab/cloudlab_config.mk` in the format `NODE_NAME=<public_ip>`. Example: 
```makefile
# Node 1
NODE_0=c220g2-010606.wisc.cloudlab.us

# Node 1
NODE_1=c220g2-010608.wisc.cloudlab.us

# Node 2
NODE_2=c220g2-010604.wisc.cloudlab.us
```
5. Update the `CLOUDLAB_USERNAME` in the `.cloudlab/cloudlab_config.mk` file with your CloudLab username.
6. Update the `SSH_KEY_PATH` in the `.cloudlab/cloudlab_config.mk` file with the path to your SSH private key.


### Syncing code to the cloudlab node 

To rsync the repository code to the cloudlab node, run the following command: 

```bash
make cl-sync-code {NODE_ID}
```

This will sync the code to the ~/src directory by default. To specify the destination directory, run the following command: 

```bash
make cl-sync-code {NODE_ID} REMOTE_DIR={DEST_DIR}
```

### SSH into the cloudlab node

To ssh into the cloudlab node, run the following command: 

```bash
make cl-ssh-node {NODE_ID}
```
