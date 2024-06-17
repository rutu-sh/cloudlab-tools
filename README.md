# cloudlab-tools

This repository contains the necessary setup tools for working in CloudLab. The intention is to standardize and speed-up the process of setting up the cloudlab environment for various research projects. Though it is extensively used on cloudlab, it can be used to setup any linux machine. 

This repository contains the setup scripts for the following tools: 
1. [eBPF](tools/ebpf/README.md)
2. [DPDK](tools/dpdk/README.md)
3. [OpenNetVM](tools/onvm/README.md)


## Cloudlab Tools

### Configuration

To access cloudlab easily, modify the `cloudlab_config.mk` as follows: 

```Makefile
SSH_KEY_PATH = /path/to/your/ssh/key
CLOUDLAB_USERNAME = your_cloudlab_username

{NODE_ID_1}=your_cloudlab_node_host
{NODE_ID_2}=your_cloudlab_node_host
{NODE_ID_3}=your_cloudlab_node_host
```

### Usage 

To rsync the repository code to the cloudlab node, run the following command: 

```bash
make cl-sync-code {NODE_ID}
```

This will sync the code to the ~/src directory by default. To specify the destination directory, run the following command: 

```bash
make cl-sync-code {NODE_ID} REMOTE_DIR={DEST_DIR}
```

To ssh into the cloudlab node, run the following command: 

```bash
make cl-ssh-node {NODE_ID}
```

To install docker, run the following command: 

```bash
make install-docker
```