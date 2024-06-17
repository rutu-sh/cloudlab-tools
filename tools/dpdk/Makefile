.PHONY: all
all:
	# Setup DPDK on a linux machine
	@echo "Setting up DPDK..."
	$(MAKE) install-dpdk-deps && \
	$(MAKE) allocate-hugepages && \
	$(MAKE) build-dpdk && \
	$(MAKE) load-igb-uio && \
	echo "DPDK setup complete!"

install-dpdk-deps:
	# Install DPDK Dependencies on a linux machine
	@echo "Installing DPDK dependencies..."
	${CURDIR}/../../scripts/install.sh install_dpdk_deps && \
	echo "DPDK dependencies installed!"

allocate-hugepages:
	# Allocate hugepages on a linux machine
	@echo "Allocating hugepages..."
	sudo ${CURDIR}/../../scripts/install.sh allocate_hugepages 1024 && \
	echo "Hugepages allocated!"

build-dpdk:
	# Build DPDK on a linux machine
	@echo "Building DPDK..."
	${CURDIR}/../../scripts/install.sh build_dpdk && \
	echo "DPDK built!"

load-igb-uio:
	# Load igb_uio on a linux machine
	@echo "Loading igb_uio..."
	${CURDIR}/../../scripts/install.sh load_igb_uio_kmod && \
	echo "igb_uio loaded!"

