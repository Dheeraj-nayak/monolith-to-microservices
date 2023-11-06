#!/usr/bin/env bash

# Exit on error or uninitialized variable
set -euo pipefail

# Check if NVM needs to be set up. Azure Cloud Shell might not persist across sessions.
if ! command -v nvm &> /dev/null; then
  echo "Setting up NVM..."
  export NVM_DIR="$HOME/.nvm"
  mkdir -p "$NVM_DIR"
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
  # shellcheck source=/dev/null
  . "$NVM_DIR/nvm.sh"  # This loads nvm
fi

echo "Installing monolith dependencies..."
cd monolith
npm install
echo "Monolith dependencies installed."

echo "Installing microservices dependencies..."
cd ../microservices
npm install
echo "Microservices dependencies installed."

echo "Installing React app dependencies..."
cd ../react-app
npm install
echo "React app dependencies installed."

echo "Building React app and placing into sub projects..."
npm run build
echo "React app built and set up."

echo "Setup completed successfully!"

# Print reminder if nvm is not found in the path.
if ! command -v nvm &> /dev/null; then
  echo "###############################################################################"
  echo "#                                   NOTICE                                    #"
  echo "#                                                                             #"
  echo "# Make sure you have a compatible nodeJS version with the following command:  #"
  echo "#                                                                             #"
  echo "# nvm install --lts                                                           #"
  echo "# nvm use --lts                                                               #"
  echo "#                                                                             #"
  echo "###############################################################################"
fi
