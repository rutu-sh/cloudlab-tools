# ebpf-cloudlab

This repository contains the code and instructions to run the eBPF experiments on CloudLab. 

The idea is to create a method/framework for running eBPF experiments on CloudLab. The framework should be able to run different eBPF programs on different network topologies and collect the results.

## System Requirements

- Go >= 1.22.0
- Access to a Ubuntu >= 22.04 machine. I have used GitHub codespaces for this. If you have access to a local dev environment or a VM, that should work too. ( Any other linux machine should work too, most likely. )

## Setting up the Development environment in GitHub Codespaces

This repository uses the [bpf2go](https://pkg.go.dev/github.com/cilium/ebpf/cmd/bpf2go) tool to compile and load eBPF programs. The `bpf2go` library generates the skeletal code for the eBPF program in Go. This means, even to write eBPF programs, you need to have access to a Linux machine. Here are the instructions for using `vscode` and `codespaces` to write eBPF programs.

1. Fork this repository
2. Create a new codespace for the forked repository
3. Open vscode and load the codespace
4. If you want to run the program in the codespace, you'll first have to install the dependencies for eBPF. Run the following commands in the terminal before you run `go generate` or `go build`. 

```bash
make install-ebpf-deps
```

To contribute to this repository, create a pull request with your changes. 


## Setting up the development environment in CloudLab

1. Instantiate a CloudLab profile having linux machines (I've only tested with Ubuntu 22.04). 
2. `ssh` into the CloudLab Node
3. Clone this repository
4. Install dependencies
```
cd ebpf-cloudlab
```
```
make install-ebpf-deps
```
```
make install-go
```
```
source /etc/profile.d/go.sh
```

Then you can go ahead, build, and run your eBPF code. 