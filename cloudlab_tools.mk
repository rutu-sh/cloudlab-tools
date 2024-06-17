CL_DIR?=${CURDIR}/.cloudlab
CL_CONFIG_PATH=${CL_DIR}/cloudlab_config.mk
CL_EXISTS=$(shell test -f $(CL_CONFIG_PATH) && echo 1 || echo 0)

# Include the cloudlab configuration file
ifeq ($(CL_EXISTS), 1)
    include $(CL_CONFIG_PATH)
else
    $(shell mkdir -p $(CL_DIR))
    $(shell cp scripts/cloudlab_config_template.mk $(CL_CONFIG_PATH))
    include $(CL_CONFIG_PATH)
endif

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
	rsync -havpP -e "ssh -i '${SSH_KEY_PATH}'" --exclude .git --exclude .venv \
		--exclude .vscode ${CURDIR} ${CLOUDLAB_USERNAME}@${CLOUDLAB_HOST}:${REMOTE_DIR} && \
	echo "Code synced to the cloudlab server"


cl-ssh-host: cl-verify
	@echo "Connecting to the cloudlab host..."
	ssh -i ${SSH_KEY_PATH} ${CLOUDLAB_USERNAME}@${CLOUDLAB_HOST}
