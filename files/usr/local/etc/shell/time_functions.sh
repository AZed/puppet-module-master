# Functions related to timekeeping
# This file should be sourced, not executed
#
# Copyright 2008-2013 Zed Pobre <zed@resonant.org>
# Licensed to the public under the terms of the GNU GPL version 2
# (Though they are simple enough that they are probably not protected)
#

function daysold {
    # Prints the number of days old a file is (modified time), with
    # any fractional part zeroed
    echo $(( (`date +%s` - `stat --format=%Y ${1}`) / 60 / 60 / 24 ))
}

function hour {
    date +'%H'
}

function hoursold {
    # Prints the number of hours old a file is (modified-time), with
    # any fractional part zeroed
    echo $(( (`date +%s` - `stat --format=%Y ${1}`) / 60 / 60 ))
}

function minutesold {
    # Prints the number of minutes old a file is (modified time), with
    # any fractional part zeroed
    echo $(( (`date +%s` - `stat --format=%Y ${1}`) / 60 ))
}

function unepoch {
    # Converts an epoch date string to standard form
    awk "BEGIN{print strftime(\"%F %T\",$1)}"
}

function ymd {
    date +'%Y%m%d'
}

function ymdh {
    date +'%Y%m%d.%H'
}
