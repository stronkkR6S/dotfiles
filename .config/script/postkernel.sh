#!/bin/bash
 set -e
echo "cleaning old config,systemap,vmlinuz,modules,sources"
eclean-kernel -n 1
echo " updatig uefi config"
uefi-mkconfig 
cd /efi/EFI/gentoo
echo " showing efi bootmgr for confirmation"
efibootmgr
