#Before running the script change to root user and execute this script.
#installing SSH, LightDM, and configuring LightDM settings to disallow guest login and show manual login options.
#Additionally, it downloads and executes the BeyondTrust PBIS Open script to integrate the system with Active Directory by joining the specified domain.

#!/bin/bash

#Install ssh
sudo apt-get install ssh -y

# Install LightDM
sudo apt-get install lightdm -y

# Adding the lines to the LightDM configuration
echo "allow-guest=false" | sudo tee -a /usr/share/lightdm/lightdm.conf.d/50-unity-greeter.conf
echo "greeter-show-manual-login=true" | sudo tee -a /usr/share/lightdm/lightdm.conf.d/50-unity-greeter.conf


#to get pbis file from github
wget https://github.com/BeyondTrust/pbis-open/releases/download/9.1.0/pbis-open-9.1.0.551.linux.x86_64.deb.sh 

#Allow to execute as a program
chmod +x pbis-open-9.1.0.551.linux.x86_64.deb.sh

#Running the script
sudo ./pbis-open-9.1.0.551.linux.x86_64.deb.sh

#changing the folder to pbis
cd /opt/pbis/bin/

#command to join the Domain
sudo ./domainjoin-cli join example.com user@example.com
