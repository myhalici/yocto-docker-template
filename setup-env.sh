#!/bin/bash
set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

function info() { echo -e "${GREEN}[INFO]${NC} $1"; }
function warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
function error() { echo -e "${RED}[ERROR]${NC} $1"; }

info "Detected OSTYPE: $OSTYPE"

# Workspace directory paths
WORKSPACE_DIR_WIN="C:\\yocto"
WORKSPACE_DIR_UNIX="/c/yocto"

CONTAINER_NAME="yocto-container"
IMAGE_NAME="yocto-docker-template"

if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    info "Switching in Git Bash / Windows environment"

    BUILD_DIR="C:\\yocto\\builds"
    DOWNLOAD_DIR="C:\\yocto\\downloads"
    SSTATE_DIR="C:\\yocto\\sstate-cache"

    # STEP 1 - Create directories
    for dir in "$BUILD_DIR" "$DOWNLOAD_DIR" "$SSTATE_DIR"; do
        if [ ! -d "$dir" ]; then
            info "Creating directory $dir..."
            mkdir -p "$dir"
        fi
    done

    # STEP 2 - Enable case sensitivity (Windows only)
    for dir in "$BUILD_DIR" "$DOWNLOAD_DIR" "$SSTATE_DIR"; do
        info "Checking case sensitivity for $dir..."
        output=$(fsutil.exe file queryCaseSensitiveInfo "$dir" 2>&1 || true)
        if [[ "$output" == *"enabled."* ]]; then
            warn "$dir is already case-sensitive."
        else
            warn "$dir is not case-sensitive. Trying to enable..."
            fsutil.exe file setCaseSensitiveInfo "$dir" enable || {
                error "Failed to enable case-sensitivity for $dir. Please enable manually!"
                exit 1
            }
        fi
    done

else
    info "Switching in Linux/WSL environment"
    BUILD_DIR="/c/yocto/builds"
    DOWNLOAD_DIR="/c/yocto/downloads"
    SSTATE_DIR="/c/yocto/sstate-cache"

    mkdir -p "$BUILD_DIR" "$DOWNLOAD_DIR" "$SSTATE_DIR"
fi

# Step 3 - Clean broken tmp dir if detected
if [ -d "$BUILD_DIR/tmp" ]; then
    if [ ! -r "$BUILD_DIR/tmp/log" ]; then
        warn "Yocto build/tmp folder exists but seems corrupted (log unreadable)."
        warn "Cleaning tmp folder to recover..."
        rm -rf "$BUILD_DIR/tmp"
        info "Cleaned: $BUILD_DIR/tmp"
    fi
fi

# Step 4 - Build Docker image if not already present
info "Checking if Docker image '$IMAGE_NAME' exists..."
if [[ "$(docker images -q $IMAGE_NAME 2> /dev/null)" == "" ]]; then
    error "Docker image not found. Building Docker image..."
    docker build -t $IMAGE_NAME .
else
    warn "Docker image '$IMAGE_NAME' already exists. Skipping build."
fi

# Step 5 - Check if container is running
if docker ps --filter "name=$CONTAINER_NAME" --filter "status=running" --format '{{.Names}}' | grep -qw $CONTAINER_NAME; then
    info "Container '$CONTAINER_NAME' is already running."

    # --- Health Check: Are Mounts Healthy? ---
    info "Checking mounts inside the container..."
    MOUNT_HEALTHY=true

    for path in "/home/yocto/builds" "/home/yocto/downloads" "/home/yocto/sstate-cache"; do
        if ! docker exec "$CONTAINER_NAME" test -d "$path"; then
            error "Mount point $path is missing or inaccessible!"
            MOUNT_HEALTHY=false
        fi
    done

    if [ "$MOUNT_HEALTHY" = true ]; then
        info "All mounts are healthy. Attaching to container..."
        docker exec -it "$CONTAINER_NAME" bash
    else
        error "Mounts are broken! Stopping zombie container..."
        docker rm -f "$CONTAINER_NAME" 2>/dev/null || true
        info "Starting new container..."
        docker run --rm --name "$CONTAINER_NAME" -it \
            -v "$BUILD_DIR:/home/yocto/builds" \
            -v "$DOWNLOAD_DIR:/home/yocto/downloads" \
            -v "$SSTATE_DIR:/home/yocto/sstate-cache" \
            -v "$(pwd)/poky-setup.sh:/home/yocto/poky-setup.sh:ro" \
            $IMAGE_NAME
    fi

else
    info "Container '$CONTAINER_NAME' not running. Starting new one..."
    docker rm -f $CONTAINER_NAME 2>/dev/null || true
    docker run --rm --name $CONTAINER_NAME -it \
        -v "$BUILD_DIR:/home/yocto/builds" \
        -v "$DOWNLOAD_DIR:/home/yocto/downloads" \
        -v "$SSTATE_DIR:/home/yocto/sstate-cache" \
        -v "$(pwd)/poky-setup.sh:/home/yocto/poky-setup.sh:ro" \
        $IMAGE_NAME
fi
