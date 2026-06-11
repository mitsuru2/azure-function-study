# syntax=docker/dockerfile:1

# Use latest LTS version of Node.js on Debian.
# You can check the latest versions on the following links:
# - Docker Hub (Node.js): https://hub.docker.com/_/node
# - Node.js: https://nodejs.org/ja/about/previous-releases
# - Debian: https://wiki.debian.org/DebianReleases#Current_Debian_Releases_and_repositories
FROM node:24-bookworm

# Install OS-level dependencies.
# - Git: It should be installed to use git commands in container or via VSCode remote 
#        development extension.
# Note: After installing packages, we clean up the apt cache to reduce the image size.
RUN apt-get update && apt-get install -y \
    git \
    sudo \
    python3 \
    python3-pip \
    python3-venv \
    python-is-python3 \
    && rm -rf /var/lib/apt/lists/*

# Enable sudo command to user 'node' w/o password.
# mkdir -p: Create all intermediate directories at once.
# /etc/sudoers.d: Directory to store configurations for each super user.
# 0440: The 'sudo' command ignores files with permissions other than 0440.
RUN echo "node ALL=(ALL) NOPASSWD:ALL" >> /etc/passwd-sudo-rules \
    && mkdir -p /etc/sudoers.d \
    && echo "node ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/node \
    && chmod 0440 /etc/sudoers.d/node

# Install Azure CLI to enable Azure management in the container.
# https://learn.microsoft.com/ja-jp/cli/azure/install-azure-cli-linux?view=azure-cli-latest&pivots=apt
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install Azure Functions Core Tools to enable local development of Azure Functions in the container.
RUN curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg \
    && mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg \
    && . /etc/os-release && sudo echo "deb [arch=amd64] https://packages.microsoft.com/debian/$VERSION_ID/prod $VERSION_CODENAME main" > /etc/apt/sources.list.d/dotnetdev.list \
    && apt-get update \
    && apt-get install -y azure-functions-core-tools-4

# Working directory in the container. This is where your application code will be located.
# '/homde/<usr>/app' is a common convention, but you can choose any directory name you prefer.
WORKDIR /home/node/app

# Change owner of the workspace to enable processing at Dev Container.
# --> Refer to .devcontainer/devcontainer.json.
RUN chown -R node:node /home/node/app

# DON'T copy the source code to the image because Dev Container will mount the source code from your host machine to the container at runtime, which allows you to edit the code on your host machine and see the changes reflected in the container without rebuilding the image.
# COPY . .

# Mark that the container listen on following ports.
# DON'T FORGET to specify -p options when running the container to map these ports to your host machine.
# 7071: Azure Functions host port.
# EXPOSE 7071 7071
# EXPOSE 9229 9229

# Build the application. 
# CMD ["npm", "run", "build"]
CMD ["sleep", "infinity"]
