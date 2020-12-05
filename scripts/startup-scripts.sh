#!/bin/bash

# The absolute path to the folder whjch contains all the scripts.
# Unless you are working with symlinks, leave the following line untouched.
PATHDATA="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

###########################################################
# Read global configuration file (and create is not exists) 
# create the global configuration file from single files - if it does not exist
if [ ! -f $PATHDATA/../settings/global.conf ]; then
    . /home/phonie/phoniebox/scripts/inc.writeGlobalConfig.sh
fi
. $PATHDATA/../settings/global.conf
###########################################################

cat $PATHDATA/../settings/global.conf

echo
echo "${AUDIOVOLSTARTUP} is the mpd startup volume"

####################################
# make playists, files and folders 
# and shortcuts 
# readable and writable to all
sudo chmod -R 777 ${AUDIOFOLDERSPATH}
sudo chmod -R 777 ${PLAYLISTSFOLDERPATH}
sudo chmod -R 777 $PATHDATA/../shared/shortcuts

#########################################
# wait until mopidy/MPD server is running
STATUS=0
while [ "$STATUS" != "ACTIVE" ]; do STATUS=$(echo -e status\\nclose | nc -w 1 localhost 6600 | grep 'OK MPD'| sed 's/^.*$/ACTIVE/'); done

####################################
# check if and set volume on startup
/home/phonie/phoniebox/scripts/playout_controls.sh -c=setvolumetostartup

####################
# play startup sound
mpgvolume=$((32768*${AUDIOVOLSTARTUP}/100))
echo "${mpgvolume} is the mpg123 startup volume"
/usr/bin/mpg123 -f -${mpgvolume} /home/phonie/phoniebox/shared/startupsound.mp3

#######################
# re-scan music library
mpc rescan 

#######################
# read out wifi config?
if [ "${READWLANIPYN}" == "ON" ]; then
    /home/phonie/phoniebox/scripts/playout_controls.sh -c=readwifiipoverspeaker
fi
