.PHONY: all
all:
	# Setup Kubernetes on a linux machine
	@echo "Setting up Kubernetes..."
	$(MAKE) install-kubernetes && \
	echo "Kubernetes setup complete!"


setup-master-node:
	@echo "Installing Kubernetes..."
	${CURDIR}/../../scripts/install.sh init_k8s_master_node && \
	echo "Kubernetes master node initialized!"


setup-worker-node:
	@echo "Installing Kubernetes..."
	${CURDIR}/../../scripts/install.sh init_k8s_worker_node && \
	echo "Kubernetes worker node initialized!"