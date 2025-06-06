#!/usr/bin/env bash

root_install() {
    apt update 

    # Development tools
    apt -y install vim git wget curl tmux nano man 

    # eBPF dependencies
    apt -y install build-essential cmake zlib1g-dev libevent-dev libelf-dev llvm clang libc6-dev-i386 pkg-config libbpf-dev linux-headers-`uname -r` 

    # Clean up temporary & .deb files
    rm -rf /tmp/* /var/lib/apt/lists/*

    # Make sure headers work
    ln -s /usr/include/x86_64-linux-gnu/asm/ /usr/include/asm
}

go_install() {
    GO_HOME=$HOME/.go
    mkdir -p $GO_HOME
    wget -O - https://go.dev/dl/go1.23.4.linux-amd64.tar.gz | tar -xvz -C $GO_HOME
    echo export PATH=$GO_HOME/go/bin:$PATH >> $HOME/.bashrc
}

rust_install() { 
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > rustup.sh
    sh ./rustup.sh -y
    rm rustup.sh
    source .cargo/env
}

sudo bash -c "$(declare -f root_install); root_install" 
go_install 
rust_install 
