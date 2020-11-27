#!/bin/bash

## Colours variables for the installation script
RED='\033[1;91m' # WARNINGS
YELLOW='\033[1;93m' # HIGHLIGHTS
WHITE='\033[1;97m' # LARGER FONT
LBLUE='\033[1;96m' # HIGHLIGHTS / NUMBERS ...
LGREEN='\033[1;92m' # SUCCESS
NOCOLOR='\033[0m' # DEFAULT FONT
#current_version=$(./nym-mixnode_linux_x86_64 --version | grep Nym | cut -c 13- )
function downloader () {
#set -x
if [ ! -d /home/nym1/.nym/mixnodes ]
then
	echo "Looking for nym config in /home/nym1 but could not find any! Enter the path of the nym-mixnode executable"
	read nym_path
	cd $nym_path
else
	cd /home/nym1
fi

# set vars for version checking and url to download the latest release of nym-mixnode
#current_version=$(./nym-mixnode_linux_x86_64 --version | grep Nym | cut -c 13- )
VERSION=$(curl https://github.com/nymtech/nym/releases/latest --cacert /etc/ssl/certs/ca-certificates.crt 2>/dev/null | egrep -o "[0-9|\.]{5}(-\w+)?")
#VERSION=$(0)
#URL="https://github.com/nymtech/nym/releases/download/v0.9.1/nym-mixnode_linux_x86_64"

# Check if the version is up to date. If not, fetch the latest release.
if [ ! -f nym-mixnode_linux_x86_64 ] || [ "$(./nym-mixnode_linux_x86_64 --version | grep Nym | cut -c 13- )" != "$VERSION" ]
   then
       if systemctl list-units --state=running | grep nym-mixnode1
          then echo "stopping nym-mixnode1.service to update the node ..." && systemctl stop nym-mixnode1
	  	sudo mv nym-mixnode_linux_x86_64 nym-mixnode_linux_x86_64_0.9.1
#	  	sudo rm /home/nym1/nym-mixnode_linux_x86_64
		sudo -u nym wget https://github.com/nymtech/nym/releases/download/v0.9.2/nym-mixnode_linux_x86_64
          else echo " nym-mixnode1.service is inactive or not existing. Downloading new binaries ..."
	  	sudo rm /home/nym1/nym-mixnode_linux_x86_64
		sudo -u nym1 wget https://github.com/nymtech/nym/releases/download/v0.9.2/nym-mixnode_linux_x86_64
	  fi		
 # Make it executable
   sudo -u nym1 chmod +x ./nym-mixnode_linux_x86_64 && chown nym1:nym1 ./nym-mixnode_linux_x86_64
#   chmod +x ./nym-mixnode_linux_x86_64 && chown nym:nym ./nym-mixnode_linux_x86_64   
else
   echo "You have the latest version of nym-mixnode $VERSION"
   exit 1

fi
}
function upgrade_nym () {
     #set -x
     sudo echo -n "" > /etc/systemd/system/nym-mixnode1.service
     directory='NymMixNode'
	
     #id=$(echo "$i" | rev | cut -d/ -f1 | rev)
     printf '%s\n' "[Unit]" > /etc/systemd/system/nym-mixnode1.service
     printf '%s\n' "Description=Nym Mixnode (0.9.2)" >> /etc/systemd/system/nym-mixnode1.service
     printf '%s\n' "" >> /etc/systemd/system/nym-mixnode1.service
     printf '%s\n' "[Service]" >> /etc/systemd/system/nym-mixnode1.service
     printf '%s\n' "User=nym" >> /etc/systemd/system/nym-mixnode1.service
     printf '%s\n' "ExecStart=/home/nym1/nym-mixnode_linux_x86_64 run --id NymMixNode" >> /etc/systemd/system/nym-mixnode1.service
     printf '%s\n' "KillSignal=SIGINT" >> /etc/systemd/system/nym-mixnode1.service				
     printf '%s\n' "Restart=on-failure" >> /etc/systemd/system/nym-mixnode1.service
     printf '%s\n' "RestartSec=30" >> /etc/systemd/system/nym-mixnode1.service
     printf '%s\n' "StartLimitInterval=350" >> /etc/systemd/system/nym-mixnode1.service
     printf '%s\n' "StartLimitBurst=10" >> /etc/systemd/system/nym-mixnode1.service
     printf '%s\n' "LimitNOFILE=65535" >> /etc/systemd/system/nym-mixnode1.service				
     printf '%s\n' "" >> /etc/systemd/system/nym-mixnode1.service
     printf '%s\n' "[Install]" >> /etc/systemd/system/nym-mixnode1.service
     printf '%s\n' "WantedBy=multi-user.target" >> /etc/systemd/system/nym-mixnode1.service
    if
      [ -e /etc/systemd/system/nym-mixnode1.service ]
    then
      printf "%b\n\n\n" "${WHITE} Your systemd script with id $directory was ${LGREEN} successfully update !"
      printf "%b\n\n\n" ""
    else
      printf "%b\n\n\n" "${WHITE} Printing of the systemd script to the current folder ${RED} failed. ${WHITE} Do you have ${YELLOW} permissions ${WHITE} to ${YELLOW} write ${WHITE} in ${pwd} ${YELLOW}  directory ??? "
    fi
    cd /home/nym1/
    sudo -u nym1 -H ./nym-mixnode_linux_x86_64 upgrade --id /home/nym1/.nym/mixnodes/NymMixNode    
}
#set -x
downloader && echo "ok" && sleep 2 || exit 1
upgrade_nym && sleep 5 && systemctl daemon-reload && sleep 5 && systemctl start nym-mixnode1.service
