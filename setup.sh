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

# Install nvm (Node Version Manager)
echo "Installing NVM and Node.js..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

# Source nvm script to make it available in the current session
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# Install the specific version of Node.js
nvm install 16.13.0 # Replace with any version you need
nvm use 16.13.0

# Verify installation
node -v
npm -v

# Install kubectl
echo "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
kubectl version --client

printf "Installing monolith dependencies...\n"
cd ./monolith
npm install
printf "Completed.\n\n"

printf "Installing microservices dependencies...\n"
cd ../microservices
npm install
printf "Completed.\n\n"

printf "Installing React app dependencies...\n"
cd ../react-app
npm install
printf "Completed.\n\n"

printf "Building React app and placing into sub projects...\n"
npm run build
printf "Completed.\n\n"

# Back to the root directory
cd ..

printf "Setup completed successfully!\n"
