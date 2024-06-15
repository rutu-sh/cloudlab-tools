include cloudlab_config.mk

GO_VERSIN=1.22.3
GO_OS=linux
GO_ARCH=amd64

CLOUDLAB_HOST=$($(NODE))

cl-verify:
	@ # check if the CLOUDLAB_USERNAME is set
	@if [ -z ${CLOUDLAB_USERNAME} ]; then \
		echo "CLOUDLAB_USERNAME is not set"; \
		exit 1; \
	fi
	@ # check if the NODE is set to a valid node
	@if [ -z ${CLOUDLAB_HOST} ]; then \
		echo "NODE is not set to a valid node"; \
		exit 1; \
	fi

cl-sync-code: cl-verify
	@echo "Syncing code to the cloudlab server..."
	rsync -havpP -e "ssh -i '~/gwu/gwu-cloud-lab'" --exclude .git --exclude .venv --exclude .vscode ${CURDIR} ${CLOUDLAB_USERNAME}@${CLOUDLAB_HOST}:~/src
	@echo "Code synced to the cloudlab server"


cl-ssh-host: cl-verify
	@echo "Connecting to the cloudlab host..."
	ssh -i ~/gwu/gwu-cloud-lab ${CLOUDLAB_USERNAME}@${CLOUDLAB_HOST}

install-go:
	# Run this only when you have ssh'd into the cloudlab host
	@echo "Installing Go on the cloudlab server..."
	./scripts/install.sh install_go ${GO_VERSIN} ${GO_OS} ${GO_ARCH}
	@echo "Go installed on the cloudlab server"

install-ebpf-deps:
	# Install eBPF on a linux machine
	@echo "Installing eBPF dependencies..."
	./scripts/install.sh install_ebpf_deps
	@echo "eBPF dependencies installed"