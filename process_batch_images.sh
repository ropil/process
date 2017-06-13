#!/bin/bash
#
# Process a batch of image files; scale, rename, move, org and git
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

# Number of settings options
NUMSETTINGS=2;
# If you require a target list, of minimum 1, otherwise NUMSETTINGS
let NUMREQUIRED=${NUMSETTINGS}+1;
# Start of list
let LISTSTART=${NUMSETTINGS}+1;

# I/O-check and help text
if [ $# -lt ${NUMREQUIRED} ]; then
  echo "USAGE: [IOTRAY=iotray.org] [INDENT=2] [SHRT=576] [LONG=768] [ORG_DIRECTORY=] \\";
  echo "       $0 <destination> <name> <target1> [<target2> [...]]";
  echo "";
  echo " OPTIONS:";
  echo "  destination - path of where to put processed files";
  echo "  name        - batch name, used in naming files";
  echo "  targetX     - image files to process";
  echo "";
  echo " ENVIRONMENT:";
  echo "  SHRT - Size of short dimension (default=576, try 384 or 768)";
  echo "  LONG - Size of long dimension (default=768, try 512 or 1024)";
  echo "  ORG_DIRECTORY - Root where org-files are located, defaults";
  echo "                  to location specified with org-directory in";
  echo "                  ${HOME}/.emacs";
  echo "  IOTRAY - file in ORG_DIRECTORY to append results into";
  echo "  INDENT - org indentation to use, default=2";
  echo "";
  echo " EXAMPLES:";
  echo "  # Run on three files, with ENV1=1";
  echo "  ENV1=1 $0 file1 file2 file3 > output.txt";
  echo "";
  echo "process_batch_images  Copyright (C) 2017  Robert Pilstål;"
  echo "This program comes with ABSOLUTELY NO WARRANTY.";
  echo "This is free software, and you are welcome to redistribute it";
  echo "under certain conditions; see supplied General Public License.";
  exit 0;
fi;

# Parse settings
destination=$1;
name=$2;
targetlist=${@:$LISTSTART};

# Set default values
if [ -z ${SHRT} ]; then
  SHRT=576;
fi
if [ -z ${LONG} ]; then
  LONG=768;
fi
if [ -z ${ORG_DIRECTORY} ]; then
  # This requires a separate setq statement to initiate the org-directory variable
  ORG_DIRECTORY=`grep 'setq org-directory "[^"]\+"' -o ${HOME}/.emacs | awk -F \" '{print $2}'`;
fi
# Convert any globs
ORG_DIRECTORY=`eval readlink -f ${ORG_DIRECTORY}`;
if [ -z ${IOTRAY} ]; then
  IOTRAY=iotray.org;
fi
if [ -z ${INDENT} ]; then
  INDENT=2;
fi

# Resize and rename imagefiles
processed=`SHRT=${SHRT} LONG=${LONG} process_image_phone.sh ${name} ${targetlist[@]}`;
# move files, and git them
gitted=();
for target in ${processed}; do
  mv ${target} ${destination};
  targetname=`basename ${target}`;
  git -C ${ORG_DIRECTORY} add ${destination}/${targetname};
  gitted+=(${destination}/${targetname});
done
# Add files to IOTRAY
ORG_DIRECTORY=${ORG_DIRECTORY} process_file_org.sh ${INDENT} ${gitted[@]} >> ${ORG_DIRECTORY}/${IOTRAY};

# Echo processed files
for target in ${gitted[@]}; do
  echo ${target};
done
