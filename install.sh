#!/bin/bash

function checkRequirementsFunction() {
	echo "Checking if requirements are installed"
	pkgs='bmap-tools gzip dosfstools util-linux'
	
	if ! dpkg -s $pkgs >/dev/null 2>&1; then
  		sudo apt-get install $pkgs
	else
    		echo "Packages found"
    		echo ""
	fi
}

checkRequirementsFunction

# bmap file
# phone image
function downloadFunction() {
	echo "Attempting to downloading bmap file if newer."
	if $1 != false; then
		wget -c -N $1
	fi

	echo "Attempting to download image file if newer."
	wget -c -N $2
}

#file system creator
#bmap writer
function formatDeviceFunction() {
	lsblk
	echo ""
        echo "Please enter your drive path ( example:: /dev/sdd ), read above for a complete list : "
        echo " -- MAKE SURE THIS IS THE CORRECT ROOT DEVICE PATH TO YOUR SDCARD --"
        echo " -- !! IT WILL DESTROY ALL DATA ON THE DEVICE !! --"
        read DEVICE_PATH
        echo "Attempting to write file system"
	sudo mkfs -t fat $DEVICE_PATH
	echo "Attempting to write image to destinate"
	if $2 == true; then
        	sudo bmaptool copy --nobmap $1 $DEVICE_PATH
	else
		sudo bmaptool copy $1 $DEVICE_PATH
	fi
}

function getPlasmaImageURLFunction() {
	return wget -qO- https://images.plasma-mobile.org/pinephone/ | grep -Po '(?<=href=")[^"]*(?=")' | tail -1
}

PS3='Which Image would you like to install? '
options=("UBPorts" "PostmarketOS" "Plasma" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "UBPorts")
            echo "UBPorts / Ubuntu Selected"
	    BMAP_URL=https://ci.ubports.com/job/rootfs/job/rootfs-pinephone/lastSuccessfulBuild/artifact/ubuntu-touch-pinephone.img.bmap
	    IMAGE_URL=https://ci.ubports.com/job/rootfs/job/rootfs-pinephone/lastSuccessfulBuild/artifact/ubuntu-touch-pinephone.img.xz
		downloadFunction $BMAP_URL $IMAGE_URL
		formatDeviceFunction "ubuntu-touch-pinephone.img.xz"
            ;;
        "PostmarketOS")
            echo "This doesn't work yet."
            ;;
        "Plasma")
		echo "$REPLY / $opt Selected"
		echo "Looking for images"
		FILE_NAME=$(wget -qO- https://images.plasma-mobile.org/pinephone/ | grep -Po '(?<=href=")[^"]*(?=")' | tail -1)
		IMAGE_URL="https://images.plasma-mobile.org/pinephone/"$FILE_NAME
		echo "Found Image : "$IMAGE_URL
		wget -c -N $IMAGE_URL
		formatDeviceFunction $FILE_NAME true
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done

echo "Finished"
