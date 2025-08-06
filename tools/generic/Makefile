GO_VERSION?=1.22.3
GO_OS?=linux
GO_ARCH?=amd64

install-docker:
	@echo "Installing Docker..."
	${CURDIR}/../../scripts/docker.sh install_docker ${CURDIR}/../../configs && \
	echo "Docker installed"

install-go:
	@echo "Installing Go..."
	${CURDIR}/../../scripts/install.sh install_go ${GO_VERSION} ${GO_OS} ${GO_ARCH} && \
	echo "Go installed"