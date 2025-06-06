#!/usr/bin/env bash 

apt_install() {
    # Development tools 
    apt-get update && apt-get -y install vim git wget curl tmux nano man

    # eBPF dependencies 
    apt-get update && apt-get -y install build-essential cmake zlib1g-dev libevent-dev libelf-dev llvm clang libc6-dev-i386 pkg-config 

    # Clean up temporary & .deb files 
    rm -rf /tmp/* /var/lib/apt/lists/* 
}

bpf_install() {
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
}

rust_install() {
    RUSTUP_HOME=$HOME/.rustup
    CARGO_HOME=$HOME/.cargo
    curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh -- -y
}

go_install() {
    GO_HOME=$HOME/.go
    mkdir $GO_HOME
    wget -O - https://go.dev/dl/go1.23.4.linux-amd64.tar.gz | tar -xvz -C $GO_HOME
    export PATH=$GO_HOME/go/bin:$PATH
}

sudo apt_install & 
sudo bpf_install &
rust_install &
go_install &
echo export PATH=$GO_HOME/go/bin:$PATH >> $HOME/.bashrc
