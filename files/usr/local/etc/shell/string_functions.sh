# Functions related to string manipulation and text display
# This file should be sourced, not executed
#
# Copyright 2008-2013 Zed Pobre <zed@resonant.org>
# Licensed to the public under the terms of the GNU GPL version 2
#

function echoerr { echo "$@" 1>&2; }

function join {
# Joins a space-separated list together on a specified character
# Can be used for alternate brace expansion formatting
#
# Examples:
#   echo $(join ',' list{01..07})
#   PATH=${PATH}:$(join ':' $(find /usr/local -maxdepth 1 -type d))
#
    local IFS=$1
    shift
    echo "$*"
}

function lc {
# lowercase a string
    echo "$@" | tr "[A-Z]" "[a-z]"
}

function pureascii {
    # Strips any non-ASCII characters from the pipe.
    # Usage: cat weirdfile.txt | pureascii
    tr -cd '\11\12\15\40-\176'
}

function trimline {
    # Strips leading and trailing whitespace even if IFS is set, also
    # removing the final newline on every line of input (i.e. the
    # result of using this on a multi-line string will be a
    # single-line string with no space between the last word on one
    # line and the first word on the next, with no leading or trailing
    # whitespace)
    echo "$@" | perl -p -e 's/^\s+|\s+$//g';
}

