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
    # TODO: Add support for other distros
    local os_name=$(uname -s | tr '[:upper:]' '[:lower:]')
    sudo apt-get update &> /dev/null && \
    sudo apt-get install -y ca-certificates curl &> /dev/null && \
    sudo install -m 0755 -d /etc/apt/keyrings &> /dev/null && \
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc && \
    sudo chmod a+r /etc/apt/keyrings/docker.asc && \
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    sudo apt-get update &> /dev/null && \
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose &> /dev/null

    sudo usermod -aG docker $USER
}

function install_kubernetes {
    install_docker
    sudo swapoff -a
    wget https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.14/cri-dockerd_0.3.14.3-0.ubuntu-jammy_amd64.deb &> /dev/null && \
    sudo dpkg -i cri-dockerd_0.3.14.3-0.ubuntu-jammy_amd64.deb &> /dev/null && \
    sudo systemctl enable cri-docker && \
    sudo systemctl start cri-docker && \
    sudo apt-get update &> /dev/null && \
    sudo apt-get install -y apt-transport-https ca-certificates curl gpg &> /dev/null
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg 
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list 
    sudo apt-get update &> /dev/null 
    sudo apt-get install -y kubelet kubeadm kubectl &> /dev/null
    sudo systemctl enable --now kubelet
    echo "Kubernetes setup complete!"
}

function init_k8s_master_node {
    local node_name=$1
    if [ -z "${node_name}" ]; then
        echo "Node name is required!"
        exit 1
    fi
    install_kubernetes
    sudo kubeadm init --cri-socket=unix:///var/run/cri-dockerd.sock --pod-network-cidr=192.168.0.0/16 --node-name=${node_name}
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
    kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/tigera-operator.yaml
    kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/custom-resources.yaml
}

function init_k8s_worker_node {
    install_kubernetes
}

"$@"