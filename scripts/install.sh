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
        echo "Go is already installed!"
        return
    fi
    
    echo "Downloading Go ${version} for ${os}-${arch}"
    curl -sSL "${go_url}" -o "${go_tarball}"
    sudo tar -C /usr/local -xzf "${go_tarball}"
    rm "${go_tarball}"
    
    echo "Setting up Go environment"
    echo "export PATH=\$PATH:${go_bin_dir}" | sudo tee -a "${go_profile}" > /dev/null
    source "${go_profile}"
    echo "Go ${version} has been installed!"
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
    sudo apt-get update 
    sudo apt install -y clang llvm libelf-dev libpcap-dev build-essential libc6-dev-i386 linux-tools-$(ver) \
        linux-headers-$(ver) linux-tools-common linux-tools-generic tcpdump m4 libbpf-dev
    echo "eBPF dependencies have been installed!"
}

"$@"