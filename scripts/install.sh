#!/bin/bash

function install_go {
    local version=$1
    local os=$2
    local arch=$3
    local go_tarball="go${version}.${os}-${arch}.tar.gz"
    local go_url="https://golang.org/dl/${go_tarball}"
    local go_dir="/usr/local/go"
    local go_bin_dir="${go_dir}/bin"
    local go_profile="/etc/profile.d/go.sh"
    
    if [ -d "${go_dir}" ]; then
        echo "Go is already installed! To start using Go, run: source ${HOME}/.profile"
        return
    fi
    
    echo "Downloading Go ${version} for ${os}-${arch}" 
    curl -sSL "${go_url}" -o "${go_tarball}" && \
    sudo tar -C /usr/local -xzf "${go_tarball}" && \
    rm "${go_tarball}" && \ 
    echo "Setting up Go environment" && \
    echo "export PATH=\$PATH:${go_bin_dir}" | sudo tee -a "${go_profile}" > /dev/null && \
    echo "export PATH=\$PATH:${go_bin_dir}" | sudo tee -a "${HOME}/.profile" > /dev/null && \
    source "${go_profile}" && \
    echo "Go ${version} has been installed! To start using Go, run: source ${HOME}/.profile"
}

function install_ebpf_deps {

    # check if the env is codespaces
    local exec_env=$(uname -a)
    local ver=$(uname -r)
    if [[ $exec_env == *"codespaces"* ]]; then
        # set ver to azure
        ver="azure"
    fi

    echo "Setting up eBPF dependencies on the machine"
    sudo apt-get update && \
    sudo apt install -y clang llvm libelf-dev libpcap-dev build-essential libc6-dev-i386 linux-tools-${ver} \
        linux-headers-${ver} linux-tools-common linux-tools-generic tcpdump m4 libbpf-dev && \
    echo "eBPF dependencies have been installed!"
}

function install_dpdk_deps {
    echo "Setting up DPDK dependencies on the machine"
    sudo apt-get update && \
    sudo apt-get install -y python3-pip build-essential libnuma-dev \
            pkgconf meson ninja-build python3-pyelftools && \
    echo "DPDK dependencies have been installed!"
}

function allocate_hugepages {
    local nodes=$(lscpu | grep "NUMA node" | awk '{print $2}' | sed '1d' | tr '\n' ' ')
    local hugepage_size=$1
    for node in $nodes; do
        echo "Allocate hugepages for node $node?"
        # read y/n
        read -r -p "Enter y/n: " response
        if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
            echo "Allocating hugepages for node $node" 
            sudo echo ${hugepage_size} > /sys/devices/system/node/${node}/hugepages/hugepages-2048kB/nr_hugepages && \
            echo "Hugepages have been allocated for node $node"
        fi
    done
}

function build_dpdk {
    git clone https://github.com/DPDK/dpdk.git && \
    cd dpdk && \
    meson setup build && \
    cd build && \
    ninja && \
    sudo meson install && \
    sudo ldconfig 
}

function load_igb_uio_kmod {
    git clone http://dpdk.org/git/dpdk-kmods && \
    cd dpdk-kmods/linux/igb_uio && \
    make && \
    sudo modprobe uio && \
    sudo insmod igb_uio.ko
}

function install_docker {
    local tools_root=$1

    ${tools_root}/scripts/docker.sh install_docker ${tools_root}

}

function install_kubernetes {
    local tools_root=$1

    install_docker ${tools_root}
    ${tools_root}/scripts/kubernetes.sh install_kubernetes

}

function init_k8s_master_node {
    local tools_root=$1

    install_docker ${tools_root}
    ${tools_root}/scripts/kubernetes.sh init_k8s_master_node
}

function init_k8s_worker_node {
    local tools_root=$1

    install_docker ${tools_root}
    ${tools_root}/scripts/kubernetes.sh init_k8s_worker_node
}

function install_k6 {
    sudo gpg -k
    sudo gpg --no-default-keyring --keyring /usr/share/keyrings/k6-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
    echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
    sudo apt-get update
    sudo apt-get install k6
}


function install_wrk {
    sudo apt-get update
    sudo apt-get install -y wrk
}



"$@"