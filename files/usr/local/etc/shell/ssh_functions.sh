# Functions related to SSH and SSH key management
# This file should be sourced, not executed
#
# Copyright 2008-2013 Zed Pobre <zed@resonant.org>
# Licensed to the public under the terms of the GNU GPL version 2
#

function sadhour {
    # Add a key to an SSH agent for a limited number of hours
    #
    # Arguments:
    #   $1: The path to the key to add (default: ~/.ssh/id_rsa)
    #   $2: The number of hours (default: 1)

    if [ X"${1}" = "X" ] ; then
        KEYFILE="${HOME}/.ssh/id_rsa"
    else
        KEYFILE=${1}
    fi
    if [ X"${2}" = "X" ] ; then
        HOURS=1
    else
        HOURS=${2}
    fi

    ssh-add -t $[${HOURS} * 3600] ${KEYFILE}
}

function sshagent_findpids {
    pgrep -u $(id -u) ssh-agent
}

function sshagent_findsockets {
    find /tmp -uid $(id -u) -type s -name agent.\* 2>/dev/null
}

function sshagent_testsocket {
    if [ ! -x "$(which ssh-add)" ] ; then
        echo "ssh-add is not available; agent testing aborted"
        return 1
    fi

    if [ X"$1" != X ] ; then
        export SSH_AUTH_SOCK=$1
    fi

    if [ X"$SSH_AUTH_SOCK" = X ] ; then
        return 2
    fi

    if [ -S $SSH_AUTH_SOCK ] ; then
        ssh-add -l > /dev/null
        if [ $? = 2 ] ; then
            echo "Socket $SSH_AUTH_SOCK is dead!  Deleting!"
            rm -f $SSH_AUTH_SOCK
            return 4
        else
            echo "Found ssh-agent $SSH_AUTH_SOCK"
            return 0
        fi
    else
        echo "$SSH_AUTH_SOCK is not a socket!"
        return 3
    fi
}

function sshagent_init {
    # ssh agent sockets can be attached to a ssh daemon process or an
    # ssh-agent process.

    AGENTFOUND=0

    # Attempt to find and use the ssh-agent in the current environment
    if sshagent_testsocket ; then AGENTFOUND=1 ; fi

    # If there is no agent in the environment, search /tmp for
    # possible agents to reuse before starting a fresh ssh-agent
    # process.
    if [ $AGENTFOUND = 0 ] ; then
        for agentsocket in $(sshagent_findsockets) ; do
            if [ $AGENTFOUND != 0 ] ; then break ; fi
            if sshagent_testsocket $agentsocket ; then AGENTFOUND=1 ; fi
        done
    fi

    # If at this point we still haven't located an agent, it's time to
    # start a new one
    if [ $AGENTFOUND = 0 ] ; then
        eval `ssh-agent`
    fi

    # Clean up
    unset AGENTFOUND
    unset agentsocket

    # Finally, show what keys are currently in the agent
    ssh-add -l
}

function sshtunnel {
    # Sets up a background ssh to a specified host with a looping
    # sleep command to prevent disconnect.
    #
    # Actual LocalForward setup must be handled from .ssh/config
    #
    # Additional options can be specified as arguments, but the
    # hostname should be last.

    ssh -A -X -T -f $@ \
        "while [ 1 ] ; do sleep 300 ; done"
}

function sshtunnel_hosts {
    # List the names of all hosts to which the current user has an
    # open sshtunnel connection
    # If ${1} is specified, it is used as an additional grep filter
    if [ X"${1}" = "X" ] ; then
        sshtunnel_ps | grep "^${USER}" | awk '{ print $8 }'
    else
        sshtunnel_ps | grep "^${USER}" | awk '{ print $8 }' | grep "${1}"
    fi
}

function sshtunnel_pids {
    # List all pids set up by sshtunnel alone (for bulk killing of tunnels)
    pgrep -f "ssh -A -X -T -f"
}

function sshtunnel_ps {
    # List all processes set up by sshtunnel with username, pid, and full command
    ps -C "ssh" -o user= -o pid= -o command=  | grep "ssh -A -X -T -f"
}
