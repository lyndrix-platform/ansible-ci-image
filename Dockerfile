# Using latest-tools as it is a verified existing tag
FROM cytopia/ansible:latest-tools

# Install system and python dependencies once during build
RUN apk add --no-cache rsync && \
    pip install --no-cache-dir passlib

# Pre-install the galaxy requirements
# Ensure requirements.yml is in the same folder as this Dockerfile
COPY requirements.yml /tmp/requirements.yml
RUN ansible-galaxy install -r /tmp/requirements.yml && \
    rm /tmp/requirements.yml

WORKDIR /data