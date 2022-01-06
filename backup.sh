#!/bin/bash

# Exit program immediately if non-zero exit status
set -e

date=$(date '+%H:%M:%S-%m-%d-%Y')
backup=fedora-installed-packages-$date

echo "Linux Package Backup program"

# Check if script was executed as root
if [[ "$EUID" -ne 0 ]]; then
    echo "ERROR: Please run as root"
        exit 1
fi

if [[ "$1" == "-B" || "$1" == "--backup" ]]; then
    echo "Backup Mode"
elif [[ "$1" == "-R" || "$1" == "--restore" ]]; then
    echo "Restore Mode"
else
    echo "Usage: backup.sh -B"      
    printf "\n"
    printf "\t"
    echo "-B, --backup                       Backup all installed packages in the current linux installation"
    printf "\t"
    echo "-R, --restore <backup-directory>   Restore all packages contained in a backup directory made previously with $0 -B"
fi