# XDP Packet Counter 

Taken from [bpf2go getting started](https://ebpf-go.dev/guides/getting-started/). 

This is a simple eBPF program that creates two resources: 
1. `pkt_count` map to store the packet count
2. `count_packets` eBPF program to set the packet count in the map

The eBPF program is loaded by the Go program and the packet count is printed every second.

## Usage

Build using 

```bash
go build
```

Run using 

```bash
sudo ./xdp-packet-counter <interface>
```

