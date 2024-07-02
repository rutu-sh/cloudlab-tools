WORKER_NODE_NAME?=$$(echo $$(hostname) | cut -d '.' -f 1 | sed 's/[^a-zA-Z0-9]*//g')

setup-master-node:
	@echo "Installing Kubernetes..." && \
	${CURDIR}/../../scripts/install.sh init_k8s_master_node master && \
	echo "Kubernetes master node initialized!"


setup-worker-node:
	@echo "Installing Kubernetes..." && \
	echo "Initializing Kubernetes worker node... ${WORKER_NODE_NAME}" && \
	${CURDIR}/../../scripts/install.sh init_k8s_worker_node ${WORKER_NODE_NAME} && \
	echo "Kubernetes worker node initialized!" && \
	echo "Join the worker node to the cluster by running the following command on the master node:" && \
	echo "kubeadm token create --print-join-command" && \
	echo "Then run the output command on this worker node"