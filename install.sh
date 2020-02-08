#!/bin/bash
function jumpto
{
    label=$1
    cmd=$(sed -n "/#$label:/{:a;n;p;ba};" $0 | grep -v ':$')
    eval "$cmd"
    exit
}

echo "Checking if Bmap Tool & Gzip is installed"
pkgs='bmap-tools gzip dosfstools'
if ! dpkg -s $pkgs >/dev/null 2>&1; then
  sudo apt-get install $pkgs
else
    echo "Packages found"
    echo ""
fi

IMAGE_URL=https://ci.ubports.com/job/rootfs/job/rootfs-pinephone/lastSuccessfulBuild/artifact/ubuntu-touch-pinephone.img.gz

wget -N https://ci.ubports.com/job/rootfs/job/rootfs-pinephone/lastSuccessfulBuild/artifact/ubuntu-touch-pinephone.img.bmap

# if they don't have bmap tool we could do a block level checksum foreach with this?
# CHECKSUM_TYPE=($(grep -oP '(?<=ChecksumType>)[^<]+' "ubuntu-touch-pinephone.img.bmap"))
# CHECKSUM=($(grep -oP '(?<=BmapFileChecksum>)[^<]+' "ubuntu-touch-pinephone.img.bmap"))
# echo "Checksum found : $CHECKSUM"
# echo "Checksum type : $CHECKSUM_TYPE"
# TODO : test with dd? this needs work
# for i in ${!BlockMap[*]}
# do
#   echo "$i" "${BlockMap[$i]}"
# done
FILE="ubuntu-touch-pinephone.img.gz"
IMGFILE="ubuntu-touch-pinephone.img"

#start:
if test -f "$FILE"; then
    echo "Phone Image : $FILE exist"
    #imagetest:
    if test -f "$IMGFILE"; then
        echo "Phone Image is ungzipped, running mkfs/Bmap Tool"
        echo ""
        echo "Please enter your drive path(example:: /dev/sdd ) : "
        echo " -- MAKE SURE THIS IS THE CORRECT ROOT DEVICE PATH TO YOUR SDCARD --"
        echo " -- !! IT WILL DESTROY ALL DATA ON THE DEVICE !! --"
        read DEVICE_PATH
        echo "Formatting Device"
        # TODO : check if device is mounted and fix
        # ls -hl $DEVICE_PATH"*"
        # echo "Does this look correct? (yes/no)"
        # echo "If the device cannot be found then it may already be unmounted. Which is fine."
        # read ANSWER
        # if [[ $ANSWER="yes" ]]; then
            # umount $DEVICE_PATH"*"
            sudo mkfs -t fat $DEVICE_PATH
            sudo bmaptool copy ubuntu-touch-pinephone.img $DEVICE_PATH
        # fi
        # TODO : add checking for dd and bmap?
        # CHECKSUM_RESULT=$($CHECKSUM_TYPE"sum" $IMGFILE)
        # if [[ $CHECKSUM_RESULT = $CHECKSUM ]]; then
        #     echo "Checksum is a match, not re-downloading."
        #     jumpto end
        # else
        #     echo "Checksum doesn't match, re-downloading."
        #     wget -N $IMAGE_URL
        #     jumpto start
        # fi
    else
        echo "Phone Image not present ungzipping now...may take awhile depending on your system speed."
        gzip -d $FILE
        jumpto imagetest
    fi
else
    echo "Downloading image"
    wget -N $IMAGE_URL
    jumpto imagetest
fi

#end:
echo "Finished"