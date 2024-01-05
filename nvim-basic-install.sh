#!/bin/bash

success_via_package(){
    echo "Neovim successfully installed via package manager."
}

success_via_appimage(){
    echo "Neovim successfully installed via appimage."
}

install_failed(){
    echo "Neovim light install failed!"
    exit 1
}

install_neovim(){
    if command -v apt-get &> /dev/null; then
        sudo apt-get install neovim
        if [ $? -eq 0 ]; then
            success_via_package
        else
            install_failed
        fi
    elif command -v yum &> /dev/null; then
        sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
        sudo yum install -y neovim python3-neovim
        if [ $? -eq 0 ]; then
            success_via_package
        else
            install_failed
        fi
    elif command -v pacman &> /dev/null; then
        sudo pacman -S neovim
        if [ $? -eq 0 ]; then
            success_via_package
        else
            install_failed
        fi
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y neovim python3-neovim
        if [ $? -eq 0 ]; then
            success_via_package
        else
            install_failed
        fi
    else
        curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
        chmod u+x nvim.appimage
        if ! command -v ./nvim.appimage; then
            ./nvim.appimage --appimage-extract
            if ! command -v ./squashfs-root/AppRun --version; then
                # Optional: exposing nvim globally.
                sudo mv squashfs-root /
                sudo ln -s /squashfs-root/AppRun /usr/bin/nvim
                command -v /usr/bin/nvim &> /dev/null
                if [ $? -eq 0 ]; then
                    success_via_appimage
                else
                    install_failed
                fi
            else
                success_via_appimage
            fi
        else
            success_via_appimage
        fi
    fi
}

move_items(){
    mv ./nvim-basic-installer/nvim-basic-install.sh ~/nvim-basic-install.sh
    if [ $? -ne 0 ]; then
        exit $?
    fi
    mv ./nvim-basic-installer/.config ~/.config
    if [ $? -ne 0 ]; then
        exit $?
    fi
}

rm_repo(){
    rm -rf ./nvim-basic-installer
    if [ $? -ne 0 ]; then
        exit $?
    fi
}

find_init_lua(){
    remap_lines=$(wc -l < ~/.config/nvim/init.lua)
    echo "Moved $remap_lines config lines into init.lua"
}

install_neovim

move_items

rm_repo

find_init_lua

exit 0
