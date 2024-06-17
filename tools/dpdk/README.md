# DPDK setup tools

This contains the setup tools for DPDK. Use this to speed-up the process of setting up the DPDK environment for various research projects.

## Setup 

To setup the DPDK environment, run the following command:

```bash
make setup
```

Here are other commands that you can use to setup the DPDK environment: 

## Install DPDK dependencies

To install the dependencies for DPDK, run the following command:

```bash
make install-dpdk-deps
```

## Allocate Hugepages 

To allocate hugepages to NUMA nodes, run the following command:

```bash
make allocate-hugepages
```

## Build DPDK

To build DPDK, run the following command:

```bash
make build-dpdk
```

## Load igb_uio module

You will need this module to bind DPDK interfaces. To load the module, run the following command:

```bash
make load-igb_uio
```