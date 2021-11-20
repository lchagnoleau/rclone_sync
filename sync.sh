#!/bin/bash

SCRIPT=`realpath $0`
SCRIPTPATH=`dirname $SCRIPT`

set -e # Exit immediately if a command exits with a non-zero status.


helpFunction()
{
   echo ""
   echo "Usage: $0 -d path/to/sync -r remote_name"
   echo -e "\t-d path to folder you want to sync"
   echo -e "\t-r remote name"
   echo -e "\t-c launch config editor"
   exit 1 # Exit script after printing help
}

while getopts "d:r:c" opt
do
   case "$opt" in
      d ) PATH_TO_SYNC="$OPTARG" ;;
      r ) REMOTE="$OPTARG" ;;
      c ) config=1 ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

if [ "$config" ]
then
  docker run --rm \
      --interactive --tty \
      -u $( id -u ):$( id -g ) \
      -v ${SCRIPTPATH}:/config/rclone/ \
      rclone/rclone config
  exit
fi

# Print helpFunction in case parameters are empty
if [ -z "$PATH_TO_SYNC" ] || [ -z "$REMOTE" ]
then
  helpFunction
fi

if [ "$(docker image ls rclone/rclone | wc -l)" = "1" ]
then
	docker pull rclone/rclone
fi

docker run --rm \
    --interactive --tty \
    -v ${SCRIPTPATH}:/config/rclone/ \
    -v $(realpath ${PATH_TO_SYNC}):/sync \
    rclone/rclone sync /sync ${REMOTE}:current --backup-dir=${REMOTE}:$(date +%Y%m%d_%H%M%S)
