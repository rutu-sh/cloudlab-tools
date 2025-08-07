#!/bin/bash


function configure_kubelet {

    echo "configuring kubelet..."

    local node_ip=$(hostname -I | awk '{print $2}') # i.e. the local ip of the node
    echo "KUBELET_EXTRA_ARGS=--node-ip=${node_ip}" > ${HOME}/kubelet
    sudo cp ${HOME}/kubelet /etc/default/kubelet
    sudo systemctl restart kubelet


    echo "kubelet configured!"
}

function install_kubernetes {

    echo "installing kubernetes..."

    sudo swapoff -a && sudo sed -i '/ swap / s/^/#/' /etc/fstab    
    sudo apt-get install -y apt-transport-https ca-certificates curl gpg
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list 
    sudo apt-get update && sudo apt-get install -y kubelet kubeadm kubectl
    sudo systemctl enable --now kubelet

    configure_kubelet


    echo "kubernetes installed!"
}


function install_cilium {

    echo "installing cilium cli..."

    CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
    CLI_ARCH=amd64
    if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
    curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
    sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
    sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
    rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}


    echo "cilium cli installed"
}


function install_helm {
    echo "installing helm..."

    curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
    sudo apt-get install apt-transport-https --yes
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
    sudo apt-get update
    sudo apt-get install helm

    echo "helm installed!"
}


function init_k8s_master_node {
    #  only run inside master node | assumes docker with containerd is already installed 

    echo "initializing master node..."

    local localip=$(hostname -I | awk '{print $2}')
    local publicip=$(hostname -I | awk '{print $1}')

    install_cilium
    install_helm 
    install_kubernetes


    echo "performing kubeadm init"
    sudo kubeadm init \
        --cri-socket=unix:///run/containerd/containerd.sock \
        --pod-network-cidr=192.168.0.0/16 \
        --node-name=master \
        --apiserver-advertise-address=${localip} \
        --apiserver-cert-extra-sans=${publicip} 


    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

    helm repo add cilium https://helm.cilium.io/

    helm install cilium cilium/cilium --version 1.18.0 \
        --namespace kube-system \
        --set socketLB.hostNamespaceOnly=true \
        --set cni.exclusive=false

    sudo cp ${HOME}/.kube/config ${HOME}/.kubeconfig
    sudo chown "$(id -u):$(id -g)" "$HOME/.kubeconfig"
    sed -i -e "s/$(hostname -I | awk '{print $2}')/$(hostname -I | awk '{print $1}')/g" $HOME/.kubeconfig 

    echo "master node initialized!"

}


function init_k8s_worker_node {
    echo "initializing worker node"

    install_kubernetes

    echo "worker node initialized!"
}



"$@"