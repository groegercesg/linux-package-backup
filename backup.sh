#!/bin/bash

# Exit program immediately if non-zero exit status
set -e

date=$(date '+%H:%M:%S-%m-%d-%Y')
backup=package-backup-$date

echo "Linux Package Backup program"

# Check if script was executed as root
if [[ "$EUID" -ne 0 ]]; then
    echo "ERROR: Please run as root"
        exit 1
fi

# Sub-functions for backup
snaps() {
    cd $backup
    input=$(snap list | cut -f -1 -d ' ')
    echo "$input" | sed 1d > snaps.list
    cd ..
    echo "Snaps list saved"
}

apt_packages() {
    cd $backup
    sudo apt list --manual-installed | grep "\[installed\]" | cut -f -1 -d '/' > apt_package.list
    cd ..
    echo "Apt Packages list saved"
}

flatpaks() {
    cd $backup
    # For this, we are simply saving names of packages, on restore Flatpak will then go and install the most recent version.
    flatpak list | cut -f -1 | uniq -u > flatpak.list
    cd ..
    echo "Flatpak list saved"
}

dnf_packages() {
    cd $backup
    dnf list installed | grep -v "Installed" | tr -s \  \\t | cut -f 1 > dnf_packages.list
    cd ..
    echo "Dnf Packages list saved"
}

yum_packages() {
    cd $backup
    yum list installed | grep -v "Installed" | tr -s \  \\t | cut -f 1 > yum_packages.list
    cd ..
    echo "Yum Packages list saved"
}

rpm_packages() {
    cd $backup
    rpm -qa > rpm_packages.list
    cd ..
    echo "RPM Packages list saved"
}

# Functions for backup and restore
backup() {
    echo "Backup Mode"
    rm -rf $backup
    mkdir $backup
    snaps
    apt_packages
    flatpaks
    dnf_packages
    yum_packages
    rpm_packages
}

restore() {
    echo "Restore Mode"
}

# Program flow
if [[ "$1" == "-B" || "$1" == "--backup" ]]; then
    backup
elif [[ "$1" == "-R" || "$1" == "--restore" ]]; then
    restore
else
    echo "Usage: backup.sh -B"      
    printf "\n"
    printf "\t"
    echo "-B, --backup                       Backup all installed packages in the current linux installation"
    printf "\t"
    echo "-R, --restore <backup-directory>   Restore all packages contained in a backup directory made previously with $0 -B"
fi