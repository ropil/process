#!/bin/bash
#
# Simply rename files with todays date, an identifier and serial
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
  echo "USAGE: $0 <name> <file1> [<file2> [...]]";
  echo "";
  echo " OPTIONS:";
  echo "  name   - basename of process batch (used for output names)";
  echo "  fileN - file targets to process";
  echo "";
  echo " EXAMPLES:";
  echo "  # Process and move two files into ~/org/results";
  echo "  $0 name file_01.png file_02.jpg | xargs mv -t ~/org/results";
  echo "";
  echo "process_file_name  Copyright (C) 2017  Robert Pilstål;"
  echo "This program comes with ABSOLUTELY NO WARRANTY.";
  echo "This is free software, and you are welcome to redistribute it";
  echo "under certain conditions; see supplied General Public License.";
  exit 0;
fi;

# Parse settings
name=$1;
targetlist=${@:$LISTSTART};

today=`date +%Y%m%d`;

# Loop over arguments
num=0;
for target in ${targetlist}; do
  let num=$num+1;
  suf=`basename ${target} | awk -F . '{print $NF}'`;
  dir=`dirname ${target}`;
  out=${dir}/${today}_${name}_`printf %02d ${num}`.${suf};
  cp ${target} ${out};
  echo ${out};
done;
