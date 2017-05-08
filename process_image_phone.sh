#!/bin/bash
#
# Stub for processing image files from phone into smaller format
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
NUMSETTINGS=1;
# If you require a target list, of minimum 1, otherwise NUMSETTINGS
let NUMREQUIRED=${NUMSETTINGS}+1;
# Start of list
let LISTSTART=${NUMSETTINGS}+1;

# I/O-check and help text
if [ $# -lt ${NUMREQUIRED} ]; then
  echo "USAGE: [SHRT=576] [LONG=768] $0 <name> <image1> [<image2> [...]]";
  echo "";
  echo " OPTIONS:";
  echo "  name   - basename of process batch (used for output names)";
  echo "  imageN - image targets to process";
  echo "";
  echo " ENVIRONMENT:";
  echo "  SHRT - Size of short dimension (default=576, try 384 or 768)";
  echo "  LONG - Size of long dimension (default=768, try 512 or 1024)";
  echo "";
  echo " EXAMPLES:";
  echo "  # Process two image files";
  echo "  SHRT=576 LONG=768 $0 image_01.png image_02.jpg";
  echo "";
  echo "process_image_phone  Copyright (C) 2017  Robert Pilstål;"
  echo "This program comes with ABSOLUTELY NO WARRANTY.";
  echo "This is free software, and you are welcome to redistribute it";
  echo "under certain conditions; see supplied General Public License.";
  exit 0;
fi;

# Parse settings
name=$1;
targetlist=${@:$LISTSTART};

# Set default values
if [ -z ${SHRT} ]; then
  SHRT=576; #768, 384
fi

if [ -z ${LONG} ]; then
  LONG=768; #1024, 512
fi

today=`date +%Y%m%d`;

# Loop over arguments
num=0;
for target in ${targetlist}; do
  let num=$num+1;
  suf=`basename ${target} | awk -F . '{print $NF}'`;
  dir=`dirname ${target}`;
  out=${dir}/${today}_${name}_`printf %02d ${num}`.${suf};
  read x y <<< `file ${target} |
    awk -F , '{
                for(i=1; i <= NF; i++)
                  print $i
              }' |
    grep "^\s*[[:digit:]]\+x[[:digit:]]\+\s*$" |
    sed 's/x/ /'`;
  size="${SHRT}x${LONG}";
  if [ $x -gt $y ]; then
    size="${LONG}x${SHRT}";
  fi;
  convert ${target} -resize ${size} ${out};
  echo ${out};
done;
