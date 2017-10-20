#!/bin/bash
#
# Script that copies todays photos from nexus 5X mounted with FUSE-mtp
# Copyright (C) 2017  Robert Pilstål
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program. If not, see <http://www.gnu.org/licenses/>.
set -e;

# Set default values
if [ -z ${TODAY} ]; then
  TODAY=`date +%Y%m%d`;
fi
if [ -z ${IMAGE_PREFIX} ]; then
  IMAGE_PREFIX="IMG_";
fi
if [ -z ${CAMERA_DIR} ]; then
  CAMERA_DIR="Internal shared storage/DCIM/Camera";
fi
if [ -z ${FUSE_DIR} ]; then
  FUSE_DIR="`mount |grep ${UID}|grep fuse|cut -d ' ' -f 3`";
fi
if [ -z ${NEXUS_DIR} ]; then
  NEXUS_DIR="`find ${FUSE_DIR}/ -mindepth 1 -maxdepth 1 -type d|awk -F / '{print $NF}'`";
fi

# I/O-check and help text
if [ $# -gt 0 ]; then
  echo "USAGE: [TODAY=value ...] $0 [help]";
  echo "";
  echo " OPTIONS:";
  echo "  <anything> - Triggers this help text and exits.";
  echo "";
  echo " ENVIRONMENT:";
  echo "  TODAY        - Date regex,";
  echo "                 default: ${TODAY}";
  echo "  IMAGE_PREFIX - Image prefix regex,";
  echo "                 default: ${IMAGE_PREFIX}";
  echo "  CAMERA_DIR   - Local directory for camera photos in phone";
  echo "                 default: ${CAMERA_DIR}";
  echo "  FUSE_DIR     - Where to find FUSE mounts for user";
  echo "                 default: ${FUSE_DIR}";
  echo "  NEXUS_DIR    - Mountpoint under FUSE dir for phone";
  echo "                 default: ${NEXUS_DIR}";
  echo "";
  echo " EXAMPLES:";
  echo "  # Get todays files to ${HOME}/Pictures";
  echo "  $0";
  echo "";
  echo "process_get_nexus_today  Copyright (C) 2017  Robert Pilstål;"
  echo "This program comes with ABSOLUTELY NO WARRANTY.";
  echo "This is free software, and you are welcome to redistribute it";
  echo "under certain conditions; see supplied General Public License.";
  exit 0;
fi;


# Create and move to new directory in Pictures
cd ${HOME}/Pictures;
new_dir=`util_expdir.sh process_nexus | tail -n 1 | awk -F ';' '{print $1}'`;
echo ${new_dir};
${new_dir};

# Copy files from nexus phone
echo find "${FUSE_DIR}/${NEXUS_DIR}/${CAMERA_DIR}" -mindepth 1 -maxdepth 1 -regex ".*${IMAGE_PREFIX}${TODAY}.*"
find "${FUSE_DIR}/${NEXUS_DIR}/${CAMERA_DIR}" -mindepth 1 -maxdepth 1 -regex ".*${IMAGE_PREFIX}${TODAY}.*" | while read image; do
  echo cp "${image}" .;
  cp "${image}" .;
done
