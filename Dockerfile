# Using a modern base (Ansible 2.16+)
FROM cytopia/ansible:latest-tools

RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh

# 1. System Dependencies
RUN apk add --no-cache rsync docker-compose git openssh-client wget curl age py3-pip jq

# 2. Python Dependencies
RUN pip install --no-cache-dir passlib zensical docker cryptography ansible-lint

# 3. Mitogen
RUN wget https://github.com/mitogen-hq/mitogen/archive/refs/tags/v0.3.7.tar.gz && \
    mkdir -p /plugins/mitogen && \
    tar -xf v0.3.7.tar.gz -C /plugins/mitogen --strip-components=1 && \
    rm v0.3.7.tar.gz

# 4. SOPS
ENV SOPS_VERSION=v3.9.0
RUN curl -LO "https://github.com/getsops/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux.amd64" && \
    mv "sops-${SOPS_VERSION}.linux.amd64" /usr/local/bin/sops && \
    chmod +x /usr/local/bin/sops

# 5. Galaxy Requirements
COPY requirements.yml /tmp/requirements.yml
RUN ansible-galaxy role install -r /tmp/requirements.yml -p /usr/share/ansible/roles && \
    ansible-galaxy collection install -r /tmp/requirements.yml && \
    rm /tmp/requirements.yml

WORKDIR /data

# STOP HERE. Do not add the template engine COPY commands.