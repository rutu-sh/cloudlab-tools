# eBPF setup tools

This repository uses the [bpf2go](https://pkg.go.dev/github.com/cilium/ebpf/cmd/bpf2go) tool to compile and load eBPF programs. The `bpf2go` library generates the skeletal code in Go by compiling the C program and then building skeletal functions around. This means, even to write eBPF programs, you need to have access to a Linux machine. Once the skeletal code is generated, you can write the rest of the Go program in your Mac. 

## Setting up the Development evnironment locally (linux)

Here are the instructions for setting up the development environment on your local linux machine. 

1. Install the dependencies for eBPF. 
```bash
make install-ebpf-deps
```
2. Install Go
```bash
make install-go
```
3. Source the Go environment
```bash
source /etc/profile.d/go.sh
```


## Setting up the Development environment in GitHub Codespaces (Mac + GitHub Pro)

Here are the instructions for using `vscode` and `codespaces` to write eBPF programs. As a student, you'll most likely have the access to GitHub Pro, which allows you to use Codespaces.

1. Fork this repository
2. Create a new codespace for the forked repository
3. Open vscode and load the codespace
4. If you want to run the program in the codespace, you'll first have to install the dependencies for eBPF. Run the following commands in the **codespace** terminal before you run `go generate` or `go build`. 

```bash
make install-ebpf-deps
```

To contribute to this repository, create a pull request with your changes. 


## Setting up the execution environment in CloudLab

1. Instantiate a CloudLab profile having linux machines (I've only tested with Ubuntu 22.04). 
2. `ssh` into the CloudLab Node
3. Clone this repository
4. Install dependencies

```bash
cd ebpf-cloudlab/tools/ebpf
```
```bash
make install-ebpf-deps
```
```bash
make install-go
```
```bash
source /etc/profile.d/go.sh
```

Then you can go ahead, build, and run your eBPF code. 

