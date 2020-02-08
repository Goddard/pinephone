#!/bin/bash
# include this boilerplate
function jumpto
{
    label=$1
    cmd=$(sed -n "/#$label:/{:a;n;p;ba};" $0 | grep -v ':$')
    eval "$cmd"
    exit
}

echo "Checking if Bmap Tool is installed"
if [ test -x $(which bmaptool) ]; then
    echo "Bamp Tool is installed"
else
    echo "Installing bmap-tools from repositories"
    sudo apt install bmap-tools
fi

IMAGE_URL=https://ci.ubports.com/job/rootfs/job/rootfs-pinephone/lastSuccessfulBuild/artifact/ubuntu-touch-pinephone.img.gz

wget -N https://ci.ubports.com/job/rootfs/job/rootfs-pinephone/lastSuccessfulBuild/artifact/ubuntu-touch-pinephone.img.bmap

CHECKSUM_TYPE=($(grep -oP '(?<=ChecksumType>)[^<]+' "ubuntu-touch-pinephone.img.bmap"))
CHECKSUM=($(grep -oP '(?<=BmapFileChecksum>)[^<]+' "ubuntu-touch-pinephone.img.bmap"))

echo "Checksum found : $CHECKSUM"
echo "Checksum type : $CHECKSUM_TYPE"

FILE=ubuntu-touch-pinephone.img.gz
IMGFILE=ubuntu-touch-pinephone.img

start=${1:-"start"}

#start:
if test -f "$FILE"; then
    echo "Phone Image : $FILE exist"
    #imagetest:
    if test -f "$IMGFILE"; then
        echo "Phone Image is ungzipped, running checksum"
        CHECKSUM_RESULT=$($CHECKSUM_TYPE"sum" $IMGFILE)
        if [[ $CHECKSUM_RESULT = $CHECKSUM ]]; then
            echo "Checksum is a match, not re-downloading."
            jumpto end
        else
            echo "Checksum doesn't match, re-downloading."
            wget -N $IMAGE_URL
            jumpto start
        fi
    else
        echo "Phone Image not present ungzipping now."
        gzip -d $FILE
        jumpto imagetest
    fi
else
    echo "Downloading image"
    wget -N $IMAGE_URL
    jumpto $imagetest
fi

#end:
echo "this is the end"