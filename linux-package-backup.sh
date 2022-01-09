#!/bin/bash

# Exit program immediately if non-zero exit status
set -e

date=$(date '+%H:%M:%S-%m-%d-%Y')
backup=package-backup-$date

echo "Linux Package Backup"

# Check if script was executed as root
if [[ "$EUID" -ne 0 ]]; then
    echo "ERROR: Please run as root"
        exit 1
fi

while test $# -gt 0; do
    case "$1" in
        -R)
            shift
            FILE=$1
            shift
            ;;
        --restore)
            shift
            FILE=$1
            shift
            ;;
        -B)
            shift
            shift
            ;;
        --backup)
            shift
            shift
            ;;
        *)
            echo "$1 is not a recognized flag!"
            return 1
            ;;
    esac
done

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
    # we need to copy our .lpb file into here
    cp .lpb $backup/.lpb
    
    # Run all of the backup functions requested by the .lpb file
    while read p; do
        $p
    done < .lpb
}

restore() {
    echo "Restore Mode"
    if [[ "$2" == "" ]]; then
        echo "No backup directory supplied: $2"
        echo "$0"
        echo "$1"
        echo "$2"
        echo "$3"
            exit 1
    elif [ -d "$2" ]; then
        # We have found the directory for backups
        cd $2

        # Check lpb
        if [[ ! -f .lpb ]]; then
            # .lpb does not exist
            echo "We couldn't find an .lpb for the associated backup file"
                exit 1
        fi

        # Run all of the restore functions requested by the .lpb file
        while read p; do
            echo "restore_" + $p
        done < .lpb
    else
        # The specified directory for backups doesn't exist
        echo "Cannot find the backup directory: $2"
            exit 1
    fi
}

create_lpb() {
    # Function to create a new .lpb default file
    rm -f .lpb
    touch .lpb
    read -p "Would you like to backup Snap Packages? ([yes]/no): " choice
    if [ "$choice" == "n" ] || [ "$choice" == "no" ] || [ "$choice" == "N" ] || [ "$choice" == "No" ] || [ "$choice" == "NO" ] || [ "$choice" == "nO" ]; then
        echo "Ignoring Snap Packages"
    else
        echo "Adding Snap Packages to the .lpb"
        echo "snaps" >> .lpb
    fi

    read -p "Would you like to backup Apt packages? ([yes]/no): " choice
    if [ "$choice" == "n" ] || [ "$choice" == "no" ] || [ "$choice" == "N" ] || [ "$choice" == "No" ] || [ "$choice" == "NO" ] || [ "$choice" == "nO" ]; then
        echo "Ignoring Apt Packages"
    else
        echo "Adding Apt Packages to the .lpb"
        echo "apt_packages" >> .lpb
    fi

    read -p "Would you like to backup Flatpaks? ([yes]/no): " choice
    if [ "$choice" == "n" ] || [ "$choice" == "no" ] || [ "$choice" == "N" ] || [ "$choice" == "No" ] || [ "$choice" == "NO" ] || [ "$choice" == "nO" ]; then
        echo "Ignoring Flatpaks"
    else
        echo "Adding Flatpaks to the .lpb"
        echo "flatpaks" >> .lpb
    fi

    read -p "Would you like to backup DNF packages? ([yes]/no): " choice
    if [ "$choice" == "n" ] || [ "$choice" == "no" ] || [ "$choice" == "N" ] || [ "$choice" == "No" ] || [ "$choice" == "NO" ] || [ "$choice" == "nO" ]; then
        echo "Ignoring DNF Packages"
    else
        echo "Adding DNF Packages to the .lpb"
        echo "dnf_packages" >> .lpb
    fi

    read -p "Would you like to backup Yum packages? ([yes]/no): " choice
    if [ "$choice" == "n" ] || [ "$choice" == "no" ] || [ "$choice" == "N" ] || [ "$choice" == "No" ] || [ "$choice" == "NO" ] || [ "$choice" == "nO" ]; then
        echo "Ignoring Yum Packages"
    else
        echo "Adding Yum Packages to the .lpb"
        echo "yum_packages" >> .lpb
    fi

    read -p "Would you like to backup Rpm packages? ([yes]/no): " choice
    if [ "$choice" == "n" ] || [ "$choice" == "no" ] || [ "$choice" == "N" ] || [ "$choice" == "No" ] || [ "$choice" == "NO" ] || [ "$choice" == "nO" ]; then
        echo "Ignoring Rpm Packages"
    else
        echo "Adding Rpm Packages to the .lpb"
        echo "rpm_packages" >> .lpb
    fi

    echo "You have successfully created a .lpb file"
}

check_lpb() {
    # Function for checking if the init file .lpb exists
    if [[ ! -f .lpb ]]; then
        # Does not exist
        read -p "You do not have a .lpb file, this file stores the default backup behaviour, would you like to create one? ([yes]/no): " choice
        if [ "$choice" == "n" ] || [ "$choice" == "no" ] || [ "$choice" == "N" ] || [ "$choice" == "No" ] || [ "$choice" == "NO" ] || [ "$choice" == "nO" ]; then
            exit 1
        fi

        # Initialise a new .lpb file
        create_lpb
    fi
}

# Program flow
if [[ "$1" == "-B" || "$1" == "--backup" ]]; then
    check_lpb
    backup
elif [[ "$1" == "-R" || "$1" == "--restore" ]]; then
    check_lpb
    restore
elif [[ "$1" == "-L" || "$1" == "--make-lpb" ]]; then
    create_lpb
else
    echo "Usage: backup.sh [<options>]"      
    printf "\n"
    printf "\t"
    echo "-B, --backup                       Backup all installed packages in the current linux installation"
    printf "\t"
    echo "-R, --restore <backup-directory>   Restore all packages contained in a backup directory made previously with $0 -B"
    printf "\t"
    echo "-L, --make-lpb                     Remakes your local .lpb file so that you can change or alter what packages you want to backup"
fi