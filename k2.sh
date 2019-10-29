#!/bin/bash


#list system log into temp file 
  dmesg > /tmp/logk

#add numbers to log file
  grep -inr "." /tmp/logk > /tmp/logk1

#list all plugged and unplugged usb devices on port 3
  grep -i "1-1.3:" /tmp/logk1 | grep -i "detected" > /tmp/plugin
  grep -i "1-1.3:" /tmp/logk1 | grep -i "connect" > /tmp/plugout

#reverse list, extract first line only, cut numeric values only for last plugged in device and unplugged device
  tac /tmp/plugin |sed -n 1p | cut -d : -f 1 > /tmp/plugin1
  tac /tmp/plugout |sed -n 1p | cut -d : -f 1 > /tmp/plugout1

#add var values for comparison to check if currently plugged in or not.
  inicio=`sed -n 1p /tmp/plugin1`
  fim=`sed -n 1p /tmp/plugout1`

#Set variables with values for limits for plugged in list
  if [ -s /tmp/plugin1 ];then
    inicio=`sed -n 1p /tmp/plugin1`
  else
    inicio=1
  fi

#Set variables with values for limits for unplugged list
  if [ -s /tmp/plugout1 ];then
    fim=`sed -n 1p /tmp/plugout1`
  else
    fim=1
  fi

# If the beginning value is greater than the end it means there is currently plugged a device in usb port #3 
  if (( $inicio > $fim ));then

#list all entrys front the end value to the last entry on the file to find out the device location name
    cat /tmp/logk1 | sed -n -e $fim,999999p > /tmp/logk2

#assuming its a standart storage device its either sda sdb and so on list those values only
    egrep -o "sd[a-z][0-9]" /tmp/logk2 > /tmp/logk3

#finding the device location find its mounting point to access data
    local=`cat /tmp/logk3 |sed -n 1p`
    mntpnt=`findmnt -l |grep $local | cut -d " " -f 1` 
  else

#default mount location in case no default storage device associated on port 3
    mntpnt='/home/pi/Videos'
  fi


#list all video files in location and tree recursively currently only finding mp4 files, could change to an ini file with valid .ext list
  grep -rl mp4 $mntpnt > /tmp/vidlist

#build playlist
  echo "#EXTM3U" > /tmp/plist.m3u8
  for entry in $(cat /tmp/vidlist)
  do
    echo "file://"$entry >> /tmp/plist.m3u8
  done

#Play the playlist with vlc command line program
  cvlc --no-video-title --fullscreen /tmp/plist.m3u8