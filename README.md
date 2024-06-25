# cloudlab-tools

![created with https://socialify.git.ci/](./docs/assets/cloudlab-tools.svg)

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
make cl-sync-code NODE={NODE_ID}
```

This will sync the code to the ~/src directory by default. To specify the destination directory, run the following command: 

```bash
make cl-sync-code NODE={NODE_ID} REMOTE_DIR={DEST_DIR}
```

### SSH into the cloudlab node

To ssh into the cloudlab node, run the following command: 

```bash
make cl-ssh-host NODE={NODE_ID}
```

### SCP files from the cloudlab node

To scp files from the cloudlab node, run the following command: 

```bash
make cl-scp-from-host SCP_SRC=<path-to-remote-source> SCP_DEST=<path-to-local-dest> NODE=<node-id>
```

### Syncing code from the cloudlab node

To rsync from the cloudlab node to the local machine, run the following command: 

```bash
make cl-sync-from-host NODE=NODE_0
```
This copies the code from `~/src/<project>` to the local machine. To specify the source directory, run the following command: 

```bash
make cl-sync-from-host NODE=NODE_0 REMOTE_DIR=<remote-dir> REMOTE_SUBDIR=<remote-subdir>
```

### Running commands on the cloudlab node

To run a command on the cloudlab node, run the following command: 

```bash
make cl-run-cmd NODE=<node-id> COMMAND=<command>
```

## Using this Repository as a Submodule

For building your own projects with the help of CloudLab, it is recommended to add this repository as a submodule to your project. This will allow you to keep the setup tools in sync with the latest changes. Here are the steps to add this repository as a submodule:

1. Create a directory in your project to store this repository as a submodule. For example, create a directory called `setup` in your project. 
```bash
mkdir setup
```
2. In the directory, add this repository as a submodule. 
```bash
cd setup
```

```bash
git submodule add https://github.com/rutu-sh/cloudlab-tools.git
```

3. Initialize the submodule. 
```bash
git submodule update --init --recursive
```

4. In the root Makefile of your project, add the following code to the start of the file. 
```makefile
CL_DIR=${CURDIR}/.cloudlab
TOOLS_SRC_DIR=${CURDIR}/setup/cloudlab-tools


include setup/cloudlab-tools/cloudlab_tools.mk
```
5. In the root of your project, run the following command to setup cloudlab configurations. 
```bash
make cl-setup
```
This will create a `.cloudlab` directory in the root of your project with a `cloudlab_config.mk` file inside the directory. Add this directory to your `.gitignore` file. 

In the `cloudlab_config.mk` add the values for `SSH_KEY_PATH` and `CLOUDLAB_USERNAME`. Then add node-specific configurations as: 
```makefile
NODE_NAME=<public_ip>
```
