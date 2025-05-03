# Using base image as Ubuntu 22.04 
FROM ubuntu:22.04

# Locale and basic package installations
RUN apt update && apt install -y \
    locales \
    gawk wget git-core diffstat unzip texinfo gcc build-essential chrpath socat \
    cpio python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping \
    file lz4 zstd sudo vim

# Set UTF-8 locale
RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Create a new user for Yocto
RUN useradd -m yocto && echo "yocto:yocto" | chpasswd && adduser yocto sudo

# Working directory
WORKDIR /home/yocto

# Change user
USER yocto

# To see the command line in the container
CMD ["/home/yocto/poky-setup.sh"]

