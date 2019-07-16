# Functions created to assist in software development and debugging
# This file should be sourced, not executed
#
# Copyright 2008-2013 Zed Pobre <zed@resonant.org>
# Licensed to the public under the terms of the GNU GPL version 2
#

function erbcheck {
    # Basic syntax check on all erb files specified
    for erbfile in $@ ; do
        echo -n "${erbfile}: " && erb -x -T '-' -P $erbfile | ruby -c
    done
}

function jc {
# Java-Compile

    JC_BASE=`basename $1 .java`
    JC_BASE=`basename $1 .`

    if [ ! -f "$JC_BASE.java" ] ; then
        echo "$JC_BASE.java not found!"
        return 1
    fi

    javac "$JC_BASE.java"
}

function jr {
# Java-Run
#
# Compiles and runs java code, automatically finding .java and .class
# extensions as necessary.  It will also shave off a trailing '.', so
# you can tab-expand into 'MyCode.' when both MyCode.java and
# MyCode.class exist.

    JR_BASE=`basename $1 .java`
    JR_BASE=`basename $JR_BASE .`
    shift

    if [ ! -f "$JR_BASE.class" ] ; then
        if [ -f "$JR_BASE.java" ] ; then
            jc "$JR_BASE"
        else
            echo "No class or java file found for '${JR_BASE}'"
            return 1
        fi
    else
        # We have a class file, but check if it's out of date
        if [ -f "$JR_BASE.java" ] ; then
            if [ "$JR_BASE.class" -ot "$JR_BASE.java" ] ; then
                # Class is older than source, so recompile it
                jc "$JR_BASE"
            fi
        fi
    fi

    java "$JR_BASE" "$@"
    return
}

function manpod {
# View the POD-format documentation of a Perl file in man format,
# which is usually better than plain-text formatting.
    pod2man "$@" | nroff -man | eval ${PAGER}
}

function puptest {
    # runs Puppet parser validation and then Puppet lint
    if [ -z $1 ] ; then
        echo "You must specify files to validate!" 1>&2
        return 1
    fi

    for file in "$@" ; do
        if [ -f $file ] ; then
            puppet parser validate $file
            puppet-lint \
                --error-level all \
                --no-2sp_soft_tabs-check \
                --no-arrow_alignment-check \
                --no-double_quoted_strings-check \
                --no-selector_inside_resource-check \
                --with-filename \
                $file
        else
            echo "Skipping ${file} (not a file)"
        fi
    done
}

function version_atleast {
    # Takes the following arguments:
    #   $1: the minimum acceptable version
    #   $2: a string containing the version to test
    #
    # Returns 0 if the second version number is greater than or equal
    # to the first and 1 otherwise.
    #
    # Returns 255 if called with less than two arguments.

    if [[ -z $1 || -z $2 ]] ; then
        echo "CRITICAL FAILURE: check_version_atleast called with insufficient arguments" >&2
        echo "  (\$1='$1'  \$2='$2')" >&2
        return 255
    fi

    if [ "$(version_cmp ${2} ${1})" -ge 0 ] ; then return 0 ; fi
    return 1;
}

function version_between {
    # Takes the following arguments:
    #   $1: the minimum acceptable version
    #   $2: the maximum acceptable version
    #   $3: a string containing the version to test
    #
    # Returns 0 if the tested version is in the acceptable range
    # (greater than or equal to the first argument, and less than or
    # equal to the second), and 1 otherwise.
    #
    # Returns 255 if called with less than three arguments.

    if [[ -z $1 || -z $2 || -z $3 ]] ; then
        echo "CRITICAL FAILURE: version_between called with insufficient arguments" >&2
        echo "  (\$1='$1'  \$2='$2'  \$3='$3')" >&2
        return 255
    fi

    if [ "$(version_cmp ${3} ${1})" -ge 0 ] \
        && [ "$(version_cmp ${3} ${2})" -le 0 ] ; then
        return 0 ;
    fi
    return 1;
}

function version_cmp {
    # Takes two strings, splits them into epoch (before the last ':'),
    # version (between the last ':' and the first '-'), and release
    # (after the first '-'), and then calls version_segment_cmp on
    # each part until a difference is found.
    #
    # Empty segments are replaced with "-1" so that an empty segment
    # can precede a non-empty segment when being passed to
    # version_segment_cmp.  As with version_segment_cmp, leading
    # zeroes will likely confuse comparison as this is still
    # fundamentally a string sort to allow strings like "3.0alpha1".
    #
    # If $1 > $2, prints 1.  If $1 < $2, prints -1.  If $1 = $2, prints 0.
    # Usage example:
    #   if [ "$(version_cmp $MYVERSION 1:2.3.4-5)" -lt 0 ] ; then ...

    EPOCHA=(`echo $1 | perl -ne 'my ($part)=/(.*):.*/;print "$part\n"'`)
    EPOCHB=(`echo $2 | perl -ne 'my ($part)=/(.*):.*/;print "$part\n"'`)
    EPOCHA=${EPOCHA:-"-1"}
    EPOCHB=${EPOCHB:-"-1"}

    NONEPOCHA=(`echo $1 | perl -ne 'my ($part)=/(?:.*:)?(.*)/;print "$part\n"'`)
    NONEPOCHB=(`echo $2 | perl -ne 'my ($part)=/(?:.*:)?(.*)/;print "$part\n"'`)

    VERSIONA=(`echo $NONEPOCHA | perl -ne 'my ($part)=/([^-]*)/;print "$part\n"'`)
    VERSIONB=(`echo $NONEPOCHB | perl -ne 'my ($part)=/([^-]*)/;print "$part\n"'`)
    VERSIONA=${VERSIONA:-"-1"}
    VERSIONB=${VERSIONB:-"-1"}

    RELEASEA=(`echo $NONEPOCHA | perl -ne 'my ($part)=/[^-]*-(.*)/;print "$part\n"'`)
    RELEASEB=(`echo $NONEPOCHB | perl -ne 'my ($part)=/[^-]*-(.*)/;print "$part\n"'`)
    RELEASEA=${RELEASEA:-"-1"}
    RELEASEB=${RELEASEB:-"-1"}

    EPOCHCMP=$(version_segment_cmp ${EPOCHA} ${EPOCHB})
    if [ ${EPOCHCMP} -ne 0 ] ; then
        echo ${EPOCHCMP}
    else
        VERSIONCMP=$(version_segment_cmp ${VERSIONA} ${VERSIONB})
        if [ ${VERSIONCMP} -ne 0 ] ; then
            echo ${VERSIONCMP}
        else
            RELEASECMP=$(version_segment_cmp ${RELEASEA} ${RELEASEB})
            if [ ${RELEASECMP} -ne 0 ] ; then
                echo ${RELEASECMP}
            else
                echo "0"
            fi
        fi
    fi
}

function version_segment_cmp {
    # Takes two strings, splits them on each '.' into arrays, compares
    # array elements until a difference is found.
    #
    # If a third argument is specified, it will override the separator
    # '.' with whatever characters were specified.
    #
    # This doesn't take into account epoch or release strings (":" or
    # "-" segments).  If you want to compare versions in the format of
    # "1:2.3-4", use version_cmp(), which calls this function.
    #
    # If the values for both array elements are purely numeric, a
    # numeric compare is done (to handle problems such as 9 > 10 or
    # 02 < 1 in a string compare), but if either value contains a
    # non-numeric value or is null a string compare is done.  Null
    # values are considered less than zero.
    #
    # If $1 > $2, prints 1.  If $1 < $2, prints -1.  If $1 = $2, prints 0.
    #
    # Usage example:
    #   if [ "$(version_segment_cmp $MYVERSION 1.2.3)" -lt 0 ] ; then ...

    SEP=${3:-"."}

    VERSIONA=(`echo $1 | perl -pe "s/[$SEP]/ /g"`)
    VERSIONB=(`echo $2 | perl -pe "s/[$SEP]/ /g"`)

    if [ ${#VERSIONA[*]} -gt ${#VERSIONB[*]} ] ; then
        VERSIONLENGTH=${#VERSIONA[*]}
    else
        VERSIONLENGTH=${#VERSIONB[*]}
    fi

    for index in `seq 1 $VERSIONLENGTH` ; do
        if ( [ -z ${VERSIONA[$index]##*[!0-9]*} ] ||
             [ -z ${VERSIONB[$index]##*[!0-9]*} ] ) ; then
            # Non-numeric comparison
            if [[ ${VERSIONA[$index]} > ${VERSIONB[$index]} ]] ; then
                echo "1"
                return
            elif [[ ${VERSIONA[$index]} < ${VERSIONB[$index]} ]] ; then
                echo "-1"
                return
            fi
        else
            # Purely numeric comparison
            if (( ${VERSIONA[$index]:-0} > ${VERSIONB[$index]:-0} )) ; then
                echo "1"
                return
            elif (( ${VERSIONA[$index]:-0} < ${VERSIONB[$index]:-0} )) ; then
                echo "-1"
                return
            fi
        fi
    done
    echo "0"
}
