#!/bin/bash


function check_gpu {
    if lspci | grep -i 'vga' | grep -i 'nvidia' >/dev/null; then
        echo "gpu present"
        return 0  # GPU present
    elif lspci | grep -i '3d controller' | grep -i 'nvidia' >/dev/null; then
        echo "gpu present"
        return 0  # Some NVIDIA cards show as 3D controllers
    else
        echo "gpu not present"
        return 1  # GPU not present
    fi
}


function check_nvidia_driver {
    if command -v nvidia-smi >/dev/null && nvidia-smi >/dev/null 2>&1; then
        echo "drivers"
        return 0  # Drivers installed
    else
        echo "no drivers"
        return 1  # Drivers not installed
    fi
}


function check_nvidia_runtime {
    if [[ -f "/usr/bin/nvidia-container-runtime" ]] || command -v nvidia-container-runtime >/dev/null 2>&1; then
        return 0  # Runtime exists
    else
        return 1  # Not installed
    fi
}


function create_containerd_cpu_config {
    local tools_root=$1
    sudo cp "${tools_root}/configs/containerd/containerd_cpu.toml" /etc/containerd/config.toml
}


function create_containerd_gpu_config {
    local tools_root=$1
    sudo cp "${tools_root}/configs/containerd/containerd_gpu.toml" /etc/containerd/config.toml
    sudo cp "${tools_root}/configs/containerd/docker_gpu.json" /etc/docker/daemon.json
}


function configure_containerd {
    local tools_root=$1

    echo "configuring containerd..."

    if check_gpu; then
        if check_nvidia_driver; then
            if check_nvidia_runtime; then
                echo "GPU present, drivers installed, and nvidia container runtime present. Using the NVIDIA runtime for containerd."
                create_containerd_gpu_config ${tools_root}
            else
                echo "Error: GPU and drivers detected, but NVIDIA container runtime is not installed. Resorting to CPU installation."
                create_containerd_cpu_config ${tools_root}
            fi
        else
            echo "Error: GPU detected but NVIDIA drivers are not installed. Resorting to CPU installation."
            create_containerd_cpu_config ${tools_root}
        fi
    else
        echo "No GPU detected. Resorting to CPU installation."
        create_containerd_cpu_config ${tools_root}
    fi

    sudo systemctl restart containerd
    sudo systemctl restart docker

    echo "configured containerd!"
}


function install_docker {
    local tools_root=$1


    echo "installing docker..."

    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && \
    sudo usermod -aG docker $USER

    configure_containerd ${tools_root}

    echo "done installing docker!"

}

"$@"