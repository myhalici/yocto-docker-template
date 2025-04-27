#!/bin/bash
set -e

echo "Detected OSTYPE: $OSTYPE"

# Workspace directory paths
WORKSPACE_DIR_WIN="C:\\yocto"
WORKSPACE_DIR_UNIX="/c/yocto"

if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    echo "Switching in Git Bash / Windows environment"
    BUILD_DIR="C:\\yocto\\builds"
    DOWNLOAD_DIR="C:\\yocto\\downloads"
    SSTATE_DIR="C:\\yocto\\sstate-cache"

    # STEP 1 - Create directories FIRST
    for dir in "$BUILD_DIR" "$DOWNLOAD_DIR" "$SSTATE_DIR"; do
        if [ ! -d "$dir" ]; then
            echo "Creating directory $dir..."
            mkdir -p "$dir"
        fi
    done

    # STEP 2 - THEN check and enable case sensitivity
    for dir in "$BUILD_DIR" "$DOWNLOAD_DIR" "$SSTATE_DIR"; do
        echo "Checking case sensitivity for $dir..."
        # Check case sensitivity
        output=$(fsutil.exe file queryCaseSensitiveInfo "$dir" 2>&1 || true)
        if [[ "$output" == *"Case sensitive attribute on directory"* && "$output" == *"enabled."* ]]; then
            echo "$dir is already case-sensitive."
        else
            echo "$dir is not case-sensitive. Trying to enable..."
            fsutil.exe file setCaseSensitiveInfo "$dir" enable || {
                echo "Failed to enable case-sensitivity for $dir. Please enable manually!"
                exit 1
            }
        fi
    done

else
    echo "Switching in Linux/WSL environment"
    BUILD_DIR="/c/yocto/builds"
    DOWNLOAD_DIR="/c/yocto/downloads"
    SSTATE_DIR="/c/yocto/sstate-cache"

    mkdir -p "$BUILD_DIR"
    mkdir -p "$DOWNLOAD_DIR"
    mkdir -p "$SSTATE_DIR"
fi

# Build Docker image

echo "Building Docker image..."
docker build -t yocto-docker-template .

# Run Docker container

echo "Running Docker container..."
docker run --rm -it \
  -v "$BUILD_DIR:/home/yocto/builds" \
  -v "$DOWNLOAD_DIR:/home/yocto/downloads" \
  -v "$SSTATE_DIR:/home/yocto/sstate-cache" \
  yocto-docker-template
