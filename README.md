# Yocto Docker Template  * experimental

This project provides a ready-to-use Docker environment for Yocto Project builds.

## Features
- Based on Ubuntu 22.04
- Non-root user (`yocto`) with password (`yocto`) inside the container
- UTF-8 locale properly set
- Workspace mounted to host machine to preserve build artifacts
- Full automation with `run.ps1` (for Windows users), `setup-env.sh` (for other users)
- Uses external mount drive for `build`, `downloads`, `state-cache`

## Prerequisites
### To run with Windows
- Docker Desktop with WSL2 backend (recommended)
- Bash available (`bash` command from WSL or Git Bash)

### To run with other
- Docker

## Usage

1. Clone this repository:

    ```bash
    git clone https://github.com/myhalici/yocto-docker-template.git
    cd yocto-docker-template
    ```

2. Run the prepare environment script;

    * for Windows 11 Powershell [ **Run as administrator** ] 
    *(you may need to set PATH for ```bash.exe``` if you get error for ```bash```)*
        ```bash
        .\run.ps1
        ```

    * for others
        ``` bash
        ./setup.env.sh
        ```

3. Docker container will be up, running and ```poky``` will be downloaded as ```scarthgap``` branch, sourced environment.

#
###### experimental