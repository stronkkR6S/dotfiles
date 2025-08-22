#!/bin/bash

read -p "How much RAM do you want to allocate (e.g., 4G)? " RAM
read -p "How many CPU cores do you want to assign? " CPUS
read -p "Do you want to boot from an ISO (y/n)? " BOOT_FROM_ISO

if [[ $BOOT_FROM_ISO =~ ^[Yy]$ ]]; then
    read -p "Path to the ISO file: " ISO_PATH
    BOOT_FLAGS="-cdrom $ISO_PATH -boot order=d,menu=on"
else
    BOOT_FLAGS=""
fi

read -p "Do you want to create a new disk image (y/n)? " CREATE_IMG

if [[ $CREATE_IMG =~ ^[Yy]$ ]]; then
    read -p "New image file name (e.g., void.img): " NEW_IMG
    read -p "Image size (e.g., 20G): " IMG_SIZE
    qemu-img create -f qcow2 "$NEW_IMG" "$IMG_SIZE"
    if [[ $? -ne 0 ]]; then
        echo "Failed to create image."
        exit 1
    fi
    IMG="$NEW_IMG"
else
    read -p "Path to the existing disk image: " IMG
    if [[ ! -f $IMG ]]; then
        echo "Error: Disk image '$IMG' not found."
        exit 1
    fi
fi

read -p "Use BIOS or UEFI firmware? (bios/uefi): " FIRMWARE

if [[ $FIRMWARE == "uefi" ]]; then
    # Ask for VM name to create/use separate OVMF_VARS file
    read -p "Enter a VM name (e.g., void, nixguii): " VM_NAME

    OVMF_CODE="/usr/share/edk2-ovmf/OVMF_CODE.fd"
    OVMF_VARS="/usr/share/edk2-ovmf/OVMF_VARS.fd"

    QEMU_DIR="$HOME/qemu"
    TMP_OVMF_VARS="$QEMU_DIR/OVMF_VARS-${VM_NAME}.fd"

    if [[ ! -r $OVMF_CODE || ! -r $OVMF_VARS ]]; then
        echo "OVMF firmware files not found or not readable!"
        exit 1
    fi

    mkdir -p "$QEMU_DIR"
    if [[ ! -f $TMP_OVMF_VARS ]]; then
        cp "$OVMF_VARS" "$TMP_OVMF_VARS"
    fi

    FIRMWARE_ARGS="-drive if=pflash,format=raw,readonly=on,file=$OVMF_CODE \
               -drive if=pflash,format=raw,file=$TMP_OVMF_VARS"

else
    FIRMWARE_ARGS=""
fi
CMD="qemu-system-x86_64 \
    -enable-kvm \
    -cpu host \
    -m "$RAM" \
    -smp "$CPUS" \
    $BOOT_FLAGS \
    -drive file="$IMG",format=qcow2,if=virtio \
    -vga virtio \
    -display sdl,gl=on \
    -device ac97 \
    $FIRMWARE_ARGS \
    -no-reboot \
    -serial stdio"

echo "Launching QEMU with the following command:"
echo "$CMD"
eval $CMD


