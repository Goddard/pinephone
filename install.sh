#!/bin/bash

function checkRequirementsFunction() {
	printf "Checking if requirements are installed\n"
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
	printf "Attempting to downloading bmap file if newer.\n"
	if $1 != false; then
		wget -c -N $1
	fi

	printf "Attempting to download image file if newer.\n"
	wget -c -N $2
}

#file system creator
#bmap writer
function formatDeviceFunction() {
	lsblk
        printf "
Please enter your drive path ( example:: /dev/sdd ), read above for a complete list : 
 -- MAKE SURE THIS IS THE CORRECT ROOT DEVICE PATH TO YOUR SDCARD --
 -- !! IT WILL DESTROY ALL DATA ON THE DEVICE !! --\n"
        read DEVICE_PATH
        printf "Attempting to write file system\n"
	sudo mkfs -t fat $DEVICE_PATH
	printf "Attempting to write image to destinate\n"
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
            printf "UBPorts / Ubuntu Selected\n"
	    BMAP_URL=https://ci.ubports.com/job/rootfs/job/rootfs-pinephone/lastSuccessfulBuild/artifact/ubuntu-touch-pinephone.img.bmap
	    IMAGE_URL=https://ci.ubports.com/job/rootfs/job/rootfs-pinephone/lastSuccessfulBuild/artifact/ubuntu-touch-pinephone.img.xz
		downloadFunction $BMAP_URL $IMAGE_URL
		formatDeviceFunction "ubuntu-touch-pinephone.img.xz"
            ;;
        "PostmarketOS")
            printf "This doesn't work yet.\n"
            ;;
        "Plasma")
		printf "%b / %b Selected\n" "$REPLY" "$opt"
		printf "Looking for images\n"
		FILE_NAME=$(wget -qO- https://images.plasma-mobile.org/pinephone/ | grep -Po '(?<=href=")[^"]*(?=")' | tail -1)
		IMAGE_URL="https://images.plasma-mobile.org/pinephone/"$FILE_NAME
		printf "Found Image : %b\n" "$IMAGE_URL"
		wget -c -N $IMAGE_URL
		formatDeviceFunction $FILE_NAME true
            ;;
        "Quit")
            break
            ;;
        *) printf "invalid option %b\n" "$REPLY";;
    esac
done

printf "Finished\n"
