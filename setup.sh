#!/usr/bin/env bash

root_install() {
    apt update

    # Development tools
    apt -y install vim git wget curl tmux nano man

    # eBPF dependencies
    apt -y install build-essential cmake zlib1g-dev libevent-dev libelf-dev llvm clang libc6-dev-i386 pkg-config libbpf-dev linux-headers-`uname -r`

    # neovim dependencies
    apt -y install ninja-build gettext cmake unzip curl

    # Clean up temporary & .deb files
    rm -rf /tmp/* /var/lib/apt/lists/*

    # Make sure headers work
    ln -s /usr/include/x86_64-linux-gnu/asm/ /usr/include/asm
}

go_install() {
    GO_HOME=$HOME/.go
    GO=$GO_HOME/bin/go
    mkdir -p $GO_HOME
    wget -O - https://go.dev/dl/go1.23.4.linux-amd64.tar.gz | tar -xvz -C $GO_HOME
    echo export PATH=$GO_HOME/go/bin:$PATH >> $HOME/.bashrc

    # Tools
    $GO install mvdan.cc/gofumpt@latest
    $GO install golang.org/x/tools/gopls@latest
    $GO install github.com/koron/iferr@latest
}

rust_install() {
    CARGO_HOME=$HOME/.cargo
    RUSTUP_HOME=$HOME/.rustup
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > rustup.sh
    sh ./rustup.sh -y
    rm rustup.sh
    source $CARGO_HOME/env
    rustup component add rust-analyzer
    cargo install ripgrep
}

nvim_install() {
    git clone https://github.com/neovim/neovim
    pushd neovim
    git checkout stable
    make CMAKE_BUILD_TYPE=RelWithDebInfo
    sudo make install
    popd
    rm -rf neovim
}

sudo bash -c "$(declare -f root_install); root_install"
go_install
rust_install
nvim_install
