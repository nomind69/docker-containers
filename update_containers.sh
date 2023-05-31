#!/bin/bash

# This script assumes that your docker containers are located in ~/docker. Change if necessary.
# It also assumes there is a directory "~/backups" in which back-ups of the previous active container are moved.
# This serves as an example script and contains only a few entries. You'll need to edit the script to suit your needs.
# In this example containers 1 and 2 (bitwarden and home assistent) are backed-up completely as a tar.gz file.
# The third container (Nextcloud) is not being backed-up because of the amount of data in it. 
# For large containers (Nextcloud, Kavita, Wiki, etc) I use alternative methods to back-up the data inside the container.


# Get the username of the user that executed the script with sudo
username=$SUDO_USER
# Get the home directory of that user
home_dir=$(eval echo "~$username")

echo """
Which container do you want to update?
1 Bitwarden
2 Home Assistent
3 Nextcloud
"""

# Ask for directory name
read -p "Enter the containernumber: " containernumber

if [ $containernumber = "1" ]; then
   dir_name=$home_dir/docker/bitwarden
elif [ $containernumber = "2" ]; then
   dir_name=$home_dir/docker/homeassistent
elif [ $containernumber = "3" ]; then
   cd $home_dir/docker/nextcloud
   docker-compose down
   docker-compose pull
   docker-compose up -d --remove-orphans
   echo "The container has been updated"
   sleep 3
   exit
else   
   echo "This is an invalid choice. Program will exit now."
   sleep 3
   exit   
fi   
# Move to directory
cd $dir_name

# Stop running docker containers
docker-compose down

# Create a timestamp for the archive name
timestamp=$(date +%Y-%m-%d_%H-%M-%S)

# Archive directory with timestamp in name
sudo tar -czvf ${dir_name}_${timestamp}.tar.gz $dir_name

# Pull new image if available
sudo -u $username docker-compose pull

# Restart docker container
docker-compose up -d --remove-orphans
echo "Container $containernumber is restarted"

# Move tar.gz file to backup directory
sudo mv $home_dir/docker/*.tar.gz $home_dir/backups
echo "Back-up moved to $home_dir/backups"
sleep 2
