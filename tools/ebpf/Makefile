GO_VERSIN=1.22.3
GO_OS=linux
GO_ARCH=amd64

install-go:
	# Run this only when you have ssh'd into the cloudlab host
	@echo "Installing Go..."
	../../scripts/install.sh install_go ${GO_VERSIN} ${GO_OS} ${GO_ARCH}
	@echo "Go installed"

install-ebpf-deps:
	# Install eBPF on a linux machine
	@echo "Installing eBPF dependencies..."
	../../scripts/install.sh install_ebpf_deps
	@echo "eBPF dependencies installed!"