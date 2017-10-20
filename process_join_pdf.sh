#!/bin/bash
#
# Wrapper joining pdf's using pdftk and setting resolution with gs
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
  echo "USAGE: [RESOLUTION=/ebook] $0 <output> <file1> [<file2> [...]]";
  echo "";
  echo " OPTIONS:";
  echo "  output - output pdf name";
  echo "  fileX - pdf-files to join, in order";
  echo "";
  echo " ENVIRONMENT:";
  echo "  RESOLUTION - gs conversion resolution;";
  echo "                 /screen";
  echo "                 /ebook    (default)";
  echo "                 /printer";
  echo "                 /prepress";
  echo "";
  echo " EXAMPLES:";
  echo "  # Run on three files, with medium resolution";
  echo "  RESOLUTION=/ebook $0 output.pdf page1.pdf page2.pdf page3.pdf;";
  echo "";
  echo "process_join_pdf  Copyright (C) 2017  Robert Pilstål;"
  echo "This program comes with ABSOLUTELY NO WARRANTY.";
  echo "This is free software, and you are welcome to redistribute it";
  echo "under certain conditions; see supplied General Public License.";
  exit 0;
fi;

# Parse settings
output=$1;
targetlist=${@:$LISTSTART};

# Set default values
if [ -z ${RESOLUTION} ]; then
  RESOLUTION="/ebook";
fi

tmppdf="tmp_`date +%s`.pdf";

# Join pdf's
pdftk ${targetlist[@]} cat output ${tmppdf};

# Lower resolution
gs -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=${RESOLUTION} -sOutputFile=${output} ${tmppdf};
