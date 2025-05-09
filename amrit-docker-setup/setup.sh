#!/bin/bash

# Script to set up AMRIT development environment
# This script clones API and UI repositories and builds UI applications

set -e  # Exit on any error

# Create base directories if they don't exist
mkdir -p API
mkdir -p UI

echo "=== Setting up AMRIT Development Environment ==="

# API repositories to clone
API_REPOS=(
  "https://github.com/PSMRI/FLW-API"
  "https://github.com/PSMRI/Admin-API"
  "https://github.com/PSMRI/Common-API"
  "https://github.com/PSMRI/ECD-API"
  "https://github.com/PSMRI/HWC-API"
  "https://github.com/PSMRI/Inventory-API"
  "https://github.com/PSMRI/MMU-API"
  "https://github.com/PSMRI/Scheduler-API"
  "https://github.com/PSMRI/TM-API"
  "https://github.com/PSMRI/Helpline1097-API"
  "https://github.com/PSMRI/Helpline104-API"
  "https://github.com/PSMRI/BeneficiaryID-Generation-API"
  "https://github.com/PSMRI/FHIR-API"
  "https://github.com/PSMRI/Identity-API"
)

# UI repositories to clone
UI_REPOS=(
  "https://github.com/PSMRI/Inventory-UI"
  "https://github.com/PSMRI/Common-UI"
  "https://github.com/PSMRI/MMU-UI"
  "https://github.com/PSMRI/TM-UI"
  "https://github.com/PSMRI/HWC-UI"
  "https://github.com/PSMRI/ADMIN-UI"
  "https://github.com/PSMRI/HWC-Scheduler-UI"
  "https://github.com/PSMRI/HWC-Inventory-UI"
  "https://github.com/PSMRI/Scheduler-UI"
  "https://github.com/PSMRI/ECD-UI"
  "https://github.com/PSMRI/Helpline1097-UI"
  "https://github.com/PSMRI/Helpline104-UI"
)

# Clone API repositories
echo "=== Cloning API repositories ==="
for repo in "${API_REPOS[@]}"; do
  repo_name=$(basename "$repo")
  if [ -d "API/$repo_name" ]; then
    echo "Directory API/$repo_name already exists, skipping..."
  else
    echo "Cloning $repo_name..."
    git clone "$repo" "API/$repo_name"
    echo "$repo_name cloned successfully"
  fi
done

# Clone UI repositories and initialize submodules
echo "=== Cloning UI repositories and initializing submodules ==="
for repo in "${UI_REPOS[@]}"; do
  repo_name=$(basename "$repo")
  if [ -d "UI/$repo_name" ]; then
    echo "Directory UI/$repo_name already exists, updating submodules..."
    cd "UI/$repo_name"
    git submodule update --init --recursive
    cd ../../
  else
    echo "Cloning $repo_name..."
    git clone "$repo" "UI/$repo_name"
    cd "UI/$repo_name"
    git submodule update --init --recursive
    cd ../../
    echo "$repo_name cloned successfully with submodules"
  fi
done

echo "=== All repositories cloned successfully ==="

# Setup and build UI applications
echo "=== Setting up and building UI applications ==="

UI_PROJECTS=(
  "ADMIN-UI"
  "HWC-UI"
  "Inventory-UI"
  "TM-UI"
  "MMU-UI"
  "Scheduler-UI"
  "HWC-Scheduler-UI"
  "HWC-Inventory-UI"
  "ECD-UI"
  "Helpline1097-UI"
  "Helpline104-UI"
)

# Function to setup environment files
setup_environment() {
  local project=$1
  echo "Setting up environment for $project..."
  
  # Ensure environment.ts exists (create if it doesn't)
  touch src/environments/environment.ts
  
  # Check if environment.local.ts exists and copy it to environment.ts
  if [ -f "src/environments/environment.local.ts" ]; then
    cp src/environments/environment.local.ts src/environments/environment.ts
    echo "Copied environment.local.ts to environment.ts for $project"
  elif [ -f "src/environments/environment.ts.template" ]; then
    cp src/environments/environment.ts.template src/environments/environment.ts
    echo "Copied environment.ts.template to environment.ts for $project"
  else
    echo "Warning: No environment template found for $project, using default empty environment.ts"
  fi
}

# Function to prepare scripts directory
prepare_scripts() {
  local project=$1
  echo "Preparing scripts for $project..."
  
  # Make scripts executable if they exist
  if [ -d "scripts" ]; then
    chmod +x ./scripts/*.js 2>/dev/null || true
    echo "Made scripts executable for $project"
  fi
}

# Loop through each UI project and build it
for project in "${UI_PROJECTS[@]}"; do
  echo "Setting up $project..."
  
  cd "UI/$project"
  
  # Ensure submodules are initialized (run again to be safe)
  echo "Updating submodules for $project..."
  git submodule update --init --recursive
  
  # Setup environment files
  setup_environment "$project"
  
  # Prepare scripts directory
  prepare_scripts "$project"
  
  # Install dependencies with legacy peer deps to avoid Angular version conflicts
  echo "Installing dependencies for $project..."
  npm install --legacy-peer-deps
  
  # Build the project with production configuration
  echo "Building $project..."
  
  # Try the build-ci command with increased memory allocation
  echo "Executing build-ci command for $project..."
  if [ -f "scripts/ci-prebuild.js" ]; then
    # If project has ci-prebuild script, use the full build-ci process
    chmod +x ./scripts/*.js 2>/dev/null || true
    ./scripts/ci-prebuild.js
    node --max_old_space_size=5048 ./node_modules/@angular/cli/bin/ng build --configuration=ci --aot
  elif npm run build-ci 2>/dev/null; then
    echo "Build completed using build-ci command"
  elif npm run build 2>/dev/null; then
    echo "Build completed using build command"
  else
    echo "Attempting to build with custom configuration..."
    # Try with ng build for projects that might not have specific build scripts
    if [ -f "node_modules/.bin/ng" ]; then
      node --max_old_space_size=5048 ./node_modules/@angular/cli/bin/ng build --configuration=production --aot
    else
      echo "Build failed for $project, could not find build method"
      exit 1
    fi
  fi
  
  # Ensure dist directory exists
  if [ ! -d "dist" ]; then
    echo "Build failed for $project, dist directory not created"
    exit 1
  fi
  
  echo "$project built successfully"
  cd ../../
done

echo "=== All UI projects built successfully ==="
echo "=== AMRIT setup complete! ==="
echo "Your static UI files are ready to be served by NGINX!"
echo "You can now run 'docker-compose up --build -d' to start the AMRIT services"