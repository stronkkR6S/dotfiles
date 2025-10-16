#!/bin/bash
# run inside /usr/src
set -e
echo "Setting active kernel..."
eselect kernel set 1
echo "Cleaning previous build..."
cd linux
make mrproper
if [[ ! -f /home/ravish/config/gentoo/final ]]; then
    echo "Old config file not found!"
    exit 1
fi
echo "copying your old .config to your new config"
cp /home/ravish/config/gentoo/final .config
echo "Updating kernel config..."
make oldconfig
make -j$(nproc) && make modules_install -j$(nproc) && make install
echo " updating uefi config"
uefi-mkconfig
read -p "Do you want to reboot now? [y/N]: " answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo "Rebooting..."
    loginctl reboot
else
    echo "Skipped reboot."
fi
