#!/bin/bash
set -e
echo "Setting active kernel..."
eselect kernel set 1
echo "Cleaning previous build..."
make mrproper
if [[ ! -f ~/config/gentoo/final ]]; then
    echo "Old config file not found!"
    exit 1
fi
echo "copying your old .config to your new config"
cp ~/config/gentoo/final .config
echo "Updating kernel config..."
make oldconfig
make -j$(nproc) && make modules_install -j$(nproc) && make install
read -p "Do you want to reboot now? [y/N]: " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo "Rebooting..."
    loginctl reboot
else
    echo "Skipped reboot."
fi
