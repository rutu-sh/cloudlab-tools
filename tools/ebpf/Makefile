GO_VERSION?=1.22.3
GO_OS?=linux
GO_ARCH?=amd64

.PHONY: all
all:
	# Setup eBPF on a linux machine
	@echo "Setting up eBPF..."
	$(MAKE) install-ebpf-deps && \
	$(MAKE) install-go && \
	echo "eBPF setup complete!"

install-go:
	@echo "Installing Go..."
	${CURDIR}/../../scripts/install.sh install_go ${GO_VERSION} ${GO_OS} ${GO_ARCH} && \
	echo "Go installed"

install-ebpf-deps:
	# Install eBPF on a linux machine
	@echo "Installing eBPF dependencies..."
	${CURDIR}/../../scripts/install.sh install_ebpf_deps && \
	echo "eBPF dependencies installed!"
