FROM public.ecr.aws/amazonlinux/amazonlinux:2023

ARG EFA_INSTALLER_VERSION='1.29.0'

ENV PATH="$PATH:/opt/aws/neuron/bin/:/opt/amazon/efa/bin:/opt/amazon/openmpi/bin/"
ENV LD_LIBRARY_PATH="/opt/aws/neuron/lib/:/opt/amazon/efa/lib64/:/opt/amazon/openmpi/lib64/"

COPY neuron.repo /etc/yum.repos.d/neuron.repo

RUN rpm --import https://yum.repos.neuron.amazonaws.com/GPG-PUB-KEY-AMAZON-AWS-NEURON.PUB \
  && dnf install -y \
    aws-neuronx-collectives-2.* \
    aws-neuronx-runtime-lib-2.* \
    aws-neuronx-tools-2.* \
  && dnf clean all \
  && rm -rf /var/cache/dnf/* /var/cache/yum/*

RUN dnf install -y \
    tar \
    gzip \
    findutils \
    util-linux \
  && curl -sL https://efa-installer.amazonaws.com/aws-efa-installer-${EFA_INSTALLER_VERSION}.tar.gz | tar xvz \
  && pushd aws-efa-installer \
    && ./efa_installer.sh --skip-kmod --skip-limit-conf --no-verify --yes \
  && popd \
  && rm -rf aws-efa-installer-* \
  && dnf remove -y --skip-broken \
      tar \
      util-linux \
    # To avoid removing systemd and openmpi (for some reason)
    && rpm -e --nodeps findutils gzip \
    && dnf clean all \
    && rm -rf /var/cache/dnf/* /var/cache/yum/*

# Allow OpenSSH to talk to containers without asking for confirmation
# by disabling StrictHostKeyChecking.
# mpi-operator mounts the .ssh folder from a Secret. For that to work, we need
# to disable UserKnownHostsFile to avoid write permissions.
# Disabling StrictModes avoids directory and files read permission checks.
RUN dnf install -y \
    openssh-clients \
    openssh-server \
  && dnf clean all \
  && mkdir -p /var/run/sshd \
  && ssh-keygen -A \
  && sed -i "s/[ #]\(.*StrictHostKeyChecking \).*/ \1no/g" /etc/ssh/ssh_config \
  && echo "        UserKnownHostsFile /dev/null" >> /etc/ssh/ssh_config \
  && sed -i "s/#\(StrictModes \).*/\1no/g" /etc/ssh/sshd_config \
  && dnf clean all \
  && rm -rf /var/cache/dnf/* /var/cache/yum/*
