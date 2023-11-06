#!/usr/bin/env bash

# Copyright 2019 Google LLC
# Copyright updated for adaptation to Azure by [Your Name/Entity] in 2023
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

# Exit on error, error on undefined variable, and error on failure of a pipe's first command
set -eEo pipefail

# Check for Node.js and install if not present
if ! command -v node &> /dev/null; then
    echo "Node.js is not installed. Setting up Node.js"

    # Install NVM to manage Node.js versions
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

    # Source NVM scripts to load it into the current session
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

    # Install the latest LTS version of Node.js using NVM
    nvm install --lts
fi

# Ensure npm is at the latest version
npm install -g npm

# Install dependencies for monolith application
echo "Installing monolith dependencies..."
cd monolith
npm install

# Install dependencies for microservices
echo "Installing microservices dependencies..."
cd ../microservices
npm install

# Install dependencies for React app
echo "Installing React app dependencies..."
cd ../react-app
npm install

# Build the React app
echo "Building React app and placing into subprojects..."
npm run build

echo "Setup completed successfully!"
