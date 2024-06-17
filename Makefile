include cloudlab_config.mk

CLOUDLAB_HOST=$($(NODE))
REMOTE_DIR?=~/src

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
	rsync -havpP -e "ssh -i '${SSH_KEY_PATH}'" --exclude .git --exclude .venv --exclude .vscode ${CURDIR} ${CLOUDLAB_USERNAME}@${CLOUDLAB_HOST}:${REMOTE_DIR}
	@echo "Code synced to the cloudlab server"


cl-ssh-host: cl-verify
	@echo "Connecting to the cloudlab host..."
	ssh -i ${SSH_KEY_PATH} ${CLOUDLAB_USERNAME}@${CLOUDLAB_HOST}


install-docker:
	@echo "Installing Docker..."
	./scripts/install.sh install_docker && \
	echo "Docker installed"

