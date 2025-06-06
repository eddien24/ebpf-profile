#!/usr/bin/env bash

root_install() {
    # Development tools
    apt-get update && apt-get -y install vim git wget curl tmux nano man &

    # eBPF dependencies
    apt-get update && apt-get -y install build-essential cmake zlib1g-dev libevent-dev libelf-dev llvm clang libc6-dev-i386 pkg-config libbpf-dev linux-headers-`uname -r` &
    wait

    # Clean up temporary & .deb files
    rm -rf /tmp/* /var/lib/apt/lists/*

    # Make sure headers work
    ln -s /usr/include/x86_64-linux-gnu/asm/ /usr/include/asm
}

bpf_install() {
    mkdir /src && pushd /src
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
    popd
}

go_install() {
    GO_HOME=$HOME/.go
    mkdir -p $GO_HOME
    wget -O - https://go.dev/dl/go1.23.4.linux-amd64.tar.gz | tar -xvz -C $GO_HOME
    export PATH=$GO_HOME/go/bin:$PATH
}

sudo bash -c "$(declare -f root_install); root_install" &
go_install &
echo export PATH=$GO_HOME/go/bin:$PATH >> $HOME/.bashrc
wait
