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

# Function to fix nested dist directories
fix_dist_structure() {
  local project=$1
  echo "Checking dist structure for $project..."
  
  # Check if the project has a nested dist structure
  if [ -d "dist/$project" ]; then
    echo "Found nested structure in $project, fixing..."
    
    # Create a temporary directory
    mkdir -p "dist_temp"
    
    # Move all files from nested directory to temp
    mv "dist/$project"/* "dist_temp/"
    
    # Remove the old dist directory
    rm -rf "dist"
    
    # Rename temp to dist
    mv "dist_temp" "dist"
    
    echo "Fixed $project dist structure"
  else
    echo "$project has correct dist structure, skipping"
  fi
}

# Script to build all Angular UI applications for NGINX hosting

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

echo "=== Setting up and building UI applications ==="

# Loop through each UI project and build it
for project in "${UI_PROJECTS[@]}"; do
  echo "Setting up $project..."
  
  cd "UI/$project"
  
  # Check if node_modules exists, if not install dependencies
  if [ ! -d "node_modules" ]; then
    echo "Installing dependencies for $project..."
    npm install
  fi
  
  # Build the project with production configuration
  # Adjust the build command based on your Angular version and requirements
  echo "Building $project..."
  npm run build-ci
  
  # Ensure dist directory exists
  if [ ! -d "dist" ]; then
    echo "Build failed for $project, dist directory not created"
    exit 1
  fi
  
  # Fix nested dist structure if needed
  fix_dist_structure "$project"
  
  echo "$project built successfully"
  cd ../../
done

echo "=== All UI projects built successfully ==="
echo "=== AMRIT setup complete! ==="
echo "Your static UI files are ready to be served by NGINX!"
echo "You can now run 'docker-compose up --build -d' to start the AMRIT services"