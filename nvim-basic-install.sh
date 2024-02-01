#!/bin/bash

set -eo pipefail

success_via_appimage(){
    echo "Neovim successfully installed via appimage."
}

success_via_package(){
    echo "Neovim successfully installed via package."
}

install_failed(){
    echo "Neovim failed to install!"
    exit 1
}

command_exists() {
    command -v "$@" &> /dev/null
}

install_neovim(){

    # Try installing via AppImage first
    if command_exists curl; then
        curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
        chmod u+x nvim.appimage
        ./nvim.appimage --appimage-extract &> /dev/null
        sudo mv squashfs-root / &> /dev/null
        sudo ln -s /squashfs-root/AppRun /usr/bin/nvim &> /dev/null
        if command_exists nvim; then
            success_via_appimage
            return 0
        else
            echo "AppImage installation failed, attempting package manager installation."
        fi
    else
        echo "Curl is not installed, cannot proceed with AppImage installation."
    fi


    # On fail resort to package manager

    if command_exists apt-get; then
        sudo apt-get update && sudo apt-get install -y neovim
    elif command_exists yum; then
        sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
        sudo yum install -y neovim python3-neovim
    elif command -v pacman &> /dev/null; then
        sudo pacman -Syu --noconfirm neovim
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y neovim python3-neovim
    else
        install_failed
        return 1
    fi

    if command_exists nvim; then
        success_via_package
        return 0
    else
        install_failed
        return 1
    fi
}

if ! install_neovim; then
    echo "Neovim installation failed!"
    exit 1
fi

mkdir -p ~/.config/nvim
if cp ~/nvim-basic-install/.config/nvim/init.lua ~/.config/nvim/init.lua; then
    remap_lines=$(wc -l < ~/.config/nvim/init.lua)
    echo "Moved $remap_lines config lines into init.lua"
else
    echo "Failed to copy init.lua configuration"
    exit 1
fi

exit 0
