TOOLS_SRC_DIR?=${CURDIR}
CL_DIR?=${CURDIR}/.cloudlab
CL_CONFIG_PATH=${CL_DIR}/cloudlab_config.mk
CL_EXISTS=$(shell test -f $(CL_CONFIG_PATH) && echo 1 || echo 0)
SCP_DEST?=${CURDIR}

# Include the cloudlab configuration file
ifeq ($(CL_EXISTS), 1)
    include $(CL_CONFIG_PATH)
else
    $(shell mkdir -p $(CL_DIR))
    $(shell cp ${TOOLS_SRC_DIR}/scripts/cloudlab_config_template.mk $(CL_CONFIG_PATH))
    include $(CL_CONFIG_PATH)
endif

CLOUDLAB_HOST=$($(NODE))
REMOTE_DIR?=~/src
SCP_SRC?=${REMOTE_DIR}

# get project name - last part of the current directory
REMOTE_SUBDIR?=$(shell basename ${CURDIR})

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

cl-sync-from-host: cl-verify
	@echo "Syncing code from the cloudlab server..."
	rsync -havpP -e "ssh -i '${SSH_KEY_PATH}'" --exclude .git --exclude .venv --exclude .cloudlab \
		--exclude .vscode ${CLOUDLAB_USERNAME}@${CLOUDLAB_HOST}:${REMOTE_DIR}/${REMOTE_SUBDIR} ${CURDIR} && \
	echo "Code synced from the cloudlab server"

cl-run-cmd: cl-verify
	@echo "Running command on the cloudlab host..."
	ssh -i ${SSH_KEY_PATH} ${CLOUDLAB_USERNAME}@${CLOUDLAB_HOST} "${COMMAND}"

cl-ssh-host: cl-verify
	@echo "Connecting to the cloudlab host..."
	ssh -i ${SSH_KEY_PATH} ${CLOUDLAB_USERNAME}@${CLOUDLAB_HOST}


cl-scp-from-host: cl-verify
	@echo "Copying files from the cloudlab host..."
	scp -i ${SSH_KEY_PATH} -r ${CLOUDLAB_USERNAME}@${CLOUDLAB_HOST}:${SCP_SRC} ${SCP_DEST} && \
	echo "Files copied from the cloudlab host"

cl-setup:
	@echo "setting up cloudlab configurations..."