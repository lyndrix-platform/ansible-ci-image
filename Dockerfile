# Using latest-tools as it is a verified existing tag
FROM cytopia/ansible:latest-tools

# 1. Install system and Python dependencies in a single layer to prevent bloat
# - rsync: Required for artifact copying
# - docker-compose: Required for syntax validation in the CI pipeline
# - passlib: Required for Ansible user/password management
# - zensical: Required for GitLab Pages MkDocs generation
RUN apk add --no-cache rsync docker-compose && \
    pip install --no-cache-dir passlib zensical

# 2. Pre-install the Ansible Galaxy requirements
COPY requirements.yml /tmp/requirements.yml
RUN ansible-galaxy install -r /tmp/requirements.yml && \
    rm /tmp/requirements.yml

WORKDIR /data