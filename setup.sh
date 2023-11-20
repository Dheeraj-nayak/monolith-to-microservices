#!/usr/bin/env bash

# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


set -eEo pipefail

# Function to check if a command exists
command_exists() {
    type "$1" &> /dev/null
}

# Install nvm (Node Version Manager) if it's not already installed
if ! command_exists nvm; then
    echo "Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

    # Source nvm script to make it available in the current session
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
else
    echo "NVM already installed."
fi

# Node.js version to install/use
NODE_VERSION="16.13.0"

# Install or use the specific version of Node.js if it's not already at the desired version
if [[ $(node -v) != "v$NODE_VERSION" ]]; then
    echo "Installing Node.js version $NODE_VERSION..."
    nvm install $NODE_VERSION
    nvm use $NODE_VERSION
else
    echo "Desired version of Node.js is already installed."
fi

# Verify Node.js and npm installations
node -v
npm -v

# Install kubectl if it's not already installed
if ! command_exists kubectl; then
    echo "Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin/kubectl
else
    echo "kubectl already installed."
fi

# Verify kubectl installation
kubectl version --client

# Install dependencies for each project
for dir in monolith microservices react-app; do
    printf "Installing dependencies in $dir...\n"
    cd "$dir"
    npm install
    cd - # Return to the root directory
    printf "Completed $dir.\n\n"
done

printf "Building React app and placing into sub-projects...\n"
cd react-app
npm run build
cd - # Back to the root directory
printf "Completed.\n\n"

printf "Setup completed successfully!\n"

