ARG UBUNTU_VERSION

FROM docker.io/library/ubuntu:${UBUNTU_VERSION}

ARG DEBIAN_FRONTEND=noninteractive
ARG RUNNER_VERSION

LABEL github_runner.version=${RUNNER_VERSION}

RUN ln --symbolic --force $(which bash) /bin/sh

RUN apt-get update --assume-yes && apt-get upgrade --assume-yes

RUN apt-get install --assume-yes --no-install-recommends \
	build-essential curl jq libffi-dev libssl-dev python3 python3-dev python3-pip python3-venv

RUN useradd --create-home docker

WORKDIR /home/docker
RUN mkdir actions-runner

WORKDIR /home/docker/actions-runner
RUN curl --remote-name --location \
	"https://github.com/actions/runner/releases/download/${RUNNER_VERSION}/actions-runner-linux-arm64-${RUNNER_VERSION//v}.tar.gz" && \
	tar --extract --gzip --file=./actions-runner-linux-arm64-${RUNNER_VERSION//v}.tar.gz && \
	rm ./actions-runner-linux-arm64-${RUNNER_VERSION//v}.tar.gz && \
	chown --recursive docker ~docker && \
	./bin/installdependencies.sh

# Workaround for missing libicu
RUN apt-get install --assume-yes --no-install-recommends libicu74

RUN apt-get install --assume-yes --no-install-recommends docker.io docker-buildx

RUN apt-get install --assume-yes --no-install-recommends sudo
COPY config/sudoers /etc/sudoers.d/docker
RUN chmod 0440 /etc/sudoers.d/docker

COPY --chown=docker:docker start.sh start
RUN chmod +x start

USER docker
ENTRYPOINT ["./start"]
