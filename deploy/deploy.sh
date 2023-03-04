#!/bin/bash

# RUN THIS FILE FROM THE ROOT DIRECTORY OF THIS PROJECT ONLY.

# This file will
# - copy all files to another appropriate location.
# - migrate database changes.
# - point nginx to new location.

if [[ -z "$1" ]]; then
    echo 'You must provide the base directory for application to deploy';
    exit 1;
fi

# Create server file.
if [[ ! -f "$1/inactive.txt" ]]; then
    echo 'green' > "$1/inactive.txt";
    mkdir -p "$1/green"
    mkdir -p "$1/blue"
fi

# Get which conceptual server needs to be activated.
toActive=$(cat "$1/inactive.txt")

# Copy to correct place.
newPath="$1/$toActive"

# Issue, this path is relative to where the script is being executed from. Amend where the script is run from.
cp -R ../ "$newPath"

# Migrate db changes.
# Swap this for a docker-compose run.
php "$newPath/artisan" migrate

# Activate new deployment by symlink.
rm -rf "$1/current"
ln -s "$newPath" "$1/current"

# Store the deactivated conceptual server in file for next time.
echo $(if $toActive == 'green'; then echo 'blue'; else echo 'green';) > "$1/inactive.txt"
