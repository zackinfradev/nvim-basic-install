#!/bin/bash

set -e

success_via_appimage(){
    echo "Neovim successfully installed via appimage."
}

success_via_package(){
    echo "Neovim successfully installed via package."
}

install_failed(){
    echo "Neovim failed to install!"
}

install_neovim(){
    # Try installing via AppImage first
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
    chmod u+x nvim.appimage
    ./nvim.appimage --appimage-extract &> /dev/null
    sudo mv squashfs-root / &> /dev/null
    sudo ln -s /squashfs-root/AppRun /usr/bin/nvim &> /dev/null

    if command -v nvim &> /dev/null; then
        success_via_appimage
        return
    else
        echo "AppImage installation failed, attempting package manager installation."
    fi

    # On fail resort to package manager

    if command -v apt-get &> /dev/null; then
        sudo apt-get install neovim
    elif command -v yum &> /dev/null; then
        sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
        sudo yum install -y neovim python3-neovim
    elif command -v pacman &> /dev/null; then
        sudo pacman -S neovim
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y neovim python3-neovim
    else
        install_failed
        return
    fi

    if command -v nvim &> /dev/null; then
        success_via_package
    else
        install_failed
    fi
}

install_neovim

mkdir -p ~/.config/nvim
cp ~/neovim-basic-install/.config/nvim/init.lua ~/.config/nvim/init.lua

remap_lines=$(wc -l < ~/.config/nvim/init.lua)
echo "Moved $remap_lines config lines into init.lua"

exit 0
