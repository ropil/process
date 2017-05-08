#!/bin/bash
#
# process_file_org.sh - format filepaths as org-entries with file links
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

# Parse settings
indent=$1;
targetlist=${@:$LISTSTART};

# Set default values
if [ -z ${ORG_DIRECTORY} ]; then
  # This requires a separate setq statement to initiate the org-directory variable
  ORG_DIRECTORY=`grep 'setq org-directory "[^"]\+"' -o ${HOME}/.emacs | awk -F \" '{print $2}'`;
fi

# No positionals, so
if [ $# -lt ${NUMREQUIRED} ]; then
  # Loop over STDIN instead
  # based upon: http://www.etalabs.net/sh_tricks.html
  while `IFS= read -r stdin`; do
    echo hej $stdin;
    for target in ${stdin}; do
      # and append the target to targetlist
      echo ${target};
      echo hoj;
      targetlist+=(${target});
    done;
  done;
fi;

# I/O-check and help text
if [ ${#targetlist[@]} -lt 2 ] && [ "x${targetlist}" = "x" ]; then
  # No input from STDIN nor positionals; blurt out error
  echo "USAGE: [ORG_DIRECTORY=value] \\";
  echo "         $0 <indent> <file1> [<file2> [...]]";
  echo "";
  echo " OPTIONS:";
  echo "  indent - org indentation";
  echo "  fileN  - file(s) to import; can come from STDIN instead";
  echo "";
  echo " ENVIRONMENT:";
  echo "  ORG_DIRECTORY - Root where org-files are located, defaults";
  echo "                  to location specified with org-directory in";
  echo "                  ${HOME}/.emacs";
  echo "";
  echo " EXAMPLES:";
  echo "  # Run on three files, with ORG_DIRECTORY=~/org,";
  echo "  # with 2 indentation, redirecting into ~/org/iotray.org";
  echo "  ORG_DIRECTORY=~/org $0 2 file1 file2 file3 \\";
  echo "    >> ~/org/iotray.org";
  echo "";
  echo "process_file_org  Copyright (C) 2017  Robert Pilstål;"
  echo "This program comes with ABSOLUTELY NO WARRANTY.";
  echo "This is free software, and you are welcome to redistribute it";
  echo "under certain conditions; see supplied General Public License.";
  exit 0;
fi;

# Get an array for orgpath
IFS=/ read -a opath <<< `eval readlink -f ${ORG_DIRECTORY}`;
if [ "x${opath[0]}" = "x" ]; then
  read -a opath <<< ${opath[@]:1};
fi;
# Set the indent output format
indentation=""
for ((i=0; i < ${indent}; i++)); do
  indentation="${indentation}*";
done;
# Todays date
today=`date +%Y-%m-%d`;

# Loop over target files
for target in ${targetlist}; do
  # This functionality is for flexibility, so that org local files always
  # get referenced relative to ${ORG_DIRECTORY}, if possible
  dirpath=`readlink -f $(dirname ${target})`;
  IFS=/ read -a tpath <<< ${dirpath};
  if [ "x${tpath[0]}" = "x" ]; then
    read -a tpath <<< ${tpath[@]:1};
  fi;
  # Count how many parts of ${ORG_DIRECTORY} path that are equal
  # to the path of ${dirpath}
  len=1;
  while [ "x${tpath[$len]}" = "x${opath[$len]}" ]; do
    let len=$len+1;
    if [ ${#opath[@]} -eq $len ]; then
      break;
    fi;
  done;

  # if ${ORG_DIRECTORY} is fully part of the path, drop
  # that section of the part and substitute it for
  # the directory referenced by ${ORG_DIRECTORY}
  if [ ${#opath[@]} -eq $len ]; then
    newdirpath="${ORG_DIRECTORY}";
    dlen=${#tpath[@]};
    for ((i=$len;i<$dlen;i++)); do
      newdirpath=$newdirpath/${tpath[$i]};
    done;
    dirpath=$newdirpath;
  fi;

  # The above could be functionalized, and then an array with different known
  # Standard paths for the user can be sourced/specified with each one being
  # checked in succession, thereby providing the first generalized path.
  # Good for semi sandboxed work across multiple devices.
  
  filename=`basename ${target}`;
  echo "${indentation} FILE [${today}]: ${filename}";
  echo "[[file:${dirpath}/${filename}]]";
done;
