#!/usr/bin/env bash 

# Development tools 
sudo apt-get update && sudo apt-get -y install vim git wget curl tmux nano man

# eBPF dependencies 
sudo apt-get update && sudo apt-get -y install build-essential cmake zlib1g-dev libevent-dev libelf-dev llvm clang libc6-dev-i386 pkg-config 

# Clean up temporary & .deb files 
rm -rf /tmp/* /var/lib/apt/lists/* 

# libbpf install 
mkdir /src && pushd /src 
ln -s /usr/include/x86_64-linux-gnu/asm/ /usr/include/asm
wget https://github.com/bpftrace/bpftrace/releases/download/v0.20.4/bpftrace
chmod +x bpftrace
git clone https://github.com/libbpf/libbpf-bootstrap.git && \
    cd libbpf-bootstrap && \
    git submodule update --init --recursive
cd libbpf-bootstrap/libbpf/src && \
    make BUILD_STATIC_ONLY=y && \
    make install BUILD_STATIC_ONLY=y LIBDIR=/usr/lib/x86_64-linux-gnu/
git clone --recurse-submodules https://github.com/libbpf/bpftool.git && \
    cd bpftool/src && \
    make -j$(nproc) && \
    make install
git clone --depth 1 git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git && \
    cp linux/include/uapi/linux/bpf* /usr/include/linux/
popd

# rust install 
RUSTUP_HOME=/usr/local/rustup
CARGO_HOME=/usr/local/cargo
curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh

# go install 
mkdir /usr/local/go 
wget -O - https://go.dev/dl/go1.23.4.linux-amd64.tar.gz | tar -xvz -C /usr/local

echo export PATH=/usr/local/go/bin:/usr/local/cargo/bin:$PATH >> ~/.bashrc
