#!/bin/bash
#
# Dump local history of a BASH session; useful for protocol making
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

# Dump history to temporary file
tmpfile=history_`date +%s`.tmp;
history -w $tmpfile;

# Check diff to bash_history
IFS=$'\n'
localhistory=($(diff $tmpfile ${HOME}/.bash_history | grep '^<' | awk '{print substr($0, 3)}'));
unset IFS

# Clean up
rm $tmpfile;

# Echo usage if not sourced, or no history
if [ ${#localhistory[@]} -eq 0  ]; then
  echo "# ERROR: no history found! - Please source; source $0";
  echo "# USAGE: source $0";
  echo "#";
  echo "# EXAMPLES:";
  echo "#  source $0 > protocol.sh";
  echo "#";
  echo "#process_history  Copyright (C) 2017  Robert Pilstål;"
  echo "#This program comes with ABSOLUTELY NO WARRANTY.";
  echo "#This is free software, and you are welcome to redistribute it";
  echo "#under certain conditions; see supplied General Public License.";
fi;

# Print history
printf '%s\n' "${localhistory[@]}"
