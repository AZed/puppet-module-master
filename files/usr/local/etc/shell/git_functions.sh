# Functions to simplify Git usage
# This file should be sourced, not executed
#
# Copyright 2008-2013 Zed Pobre <zed@resonant.org>
# Licensed to the public under the terms of the GNU GPL version 2
#
# git-fake-parent function derived from code by Grawity at
# https://github.com/grawity/code/blob/master/devel/git-fake-parent
# No license information available for this function
#

function git_current_branch {
    git rev-parse --symbolic-full-name HEAD 2>/dev/null | sed -e "s/.*\/\(\.*\)/\1/"
}

function git_current_changeset {
    git rev-parse --short=5 HEAD
}

function git_default_remote {
    git config branch.$(git_current_branch).remote
}

function git_prompt_string {
    # This always prints a fully updated git prompt string -- but
    # since it forces a recalculation every time, you should only use
    # it when precmd/chpwd updates are not available.
    git_prompt_update
    printf "${GITPROMPTSTRING}"
}

function git_prompt_update {
    GITBRANCH=$(git_current_branch)
    if [ X"$GITPROMPT" = "X" ] ; then
        # If $GITPROMPT isn't set, we always blank the string and
        # return immediately
        export GITPROMPTSTRING=""
        return
    fi
    if [ X"$GITBRANCH" != "X" ] ; then
        export GITPROMPTSTRING="[git:${GITBRANCH}$(git_status_chars):$(git_current_changeset)]"
    else
        export GITPROMPTSTRING=""
    fi
}

function git_status_chars {
    GITSTATUSCHARS=''
    case ${PWD} in
    */.git*)
        GITSTATUS=""
        ;;
    *)
        if [ $(version_cmp ${GITVERSION} 1.7) -lt 0 ] ; then
            GITSTATUS=""
        else
            GITSTATUS=$(git status --porcelain)
        fi
        ;;
    esac
    GITSTATUSPART=$(echo "${GITSTATUS}" | grep -E '^[A-Z]')
    if [ X"$GITSTATUSPART" != "X" ] ; then
        GITSTATUSCHARS="${GITSTATUSCHARS}+"
    fi
    GITSTATUSPART=$(echo "${GITSTATUS}" | grep -E '^.[A-Z]')
    if [ X"$GITSTATUSPART" != "X" ] ; then
        GITSTATUSCHARS="${GITSTATUSCHARS}*"
    fi
    GITSTATUSPART=$(echo "${GITSTATUS}" | grep -E '^.[\?]')
    if [ X"$GITSTATUSPART" != "X" ] ; then
        GITSTATUSCHARS="${GITSTATUSCHARS}?"
    fi
    printf "${GITSTATUSCHARS}"
}

function git-addmod {
# Git add modified
# Stages all changes to modified or deleted files, but NOT new ones
    git ls-files --deleted | xargs --no-run-if-empty git rm
    git ls-files --modified | xargs --no-run-if-empty git add -f
}

function git-addremove {
# Git equivalent to 'hg addremove'
# Stages all changes
    git add . && git ls-files --deleted | xargs --no-run-if-empty git rm
}

function git-empty-branch {
# git-empty-branch <branchname>
#
# Stashes any current changes and creates an empty branch in a git
# repository with no ancestors.
#
# WARNING: this annihilates the current working directory, and if it
# is large, it may take some time to recover from stash!
#
# Returns 0 on success
# Returns 1 if no branch name is specified
# Returns 2 if the branch name is already in use
#

    if [ X"$1" = "X" ] ; then
        echo "You must specify a branch name!"
        return 1
    fi

    git branch | grep -q "^..$1$"
    if [ $? = 0 ] ; then
        echo "Branch '$1' already exists!"
        return 2
    fi

    git stash save "Automatic stash by git-empty-branch"
    git symbolic-ref HEAD refs/heads/$1
    rm .git/index
    git clean -f -d -x
}

function git-fake-parent {
# Add fake parents to a Git commit
# Based on code by Grawity at:
# https://github.com/grawity/code/blob/master/devel/git-fake-parent

    if (( $# != 2 )); then
        echo "Usage: git fake-parent <init-commit> <fake-parent>"
        echo ""
        echo "Add a fake parent to a given commit using 'git replace'."
        echo ""
        echo "<init-commit> must be an initial commit; i.e. it mustn't have parents."
        exit 2
    fi >&2

    newinit=$(git rev-parse --verify "$1")
    oldhead=$(git rev-parse --verify "$2")

    if [[ "$oldhead" == "$newinit" ]]; then
        echo "error: a commit cannot be a parent of itself"
        exit 1
    fi >&2

    if parent=$(git rev-parse --quiet --verify "$newinit^"); then
        echo "error: init-commit has a parent (did you mix up argument order?)"
        echo " commit: $newinit"
        echo " parent: $parent"
        exit 1
    fi >&2

    newfake=$(git cat-file commit "$newinit" \
        | sed "1,/^$/{
                 /^tree [0-9a-f]\+$/aparent $oldhead
               }" \
    | git hash-object -t commit -w --stdin)

    diff -u <(git cat-file commit "$newinit") --label "commit $newinit" \
        <(git cat-file commit "$newfake") --label "commit $newfake" \
        || true

    git replace -f "$newinit" "$newfake"
}

function git-remote-exists {
    # Silently determine if a git remote exists and return 1 if it does not
    git remote | grep -q "^${1}$"
}

function gitreview {
    # Shows a log of changes betwen the current branch and a remote
    #
    # Usage: gitreview <direction> <remotename> <remotebranch> [git log args]
    #    or: gitreview <direction> <remotename>/<remotebranch> [git log args]
    #
    # <direction> can be 'i' for incoming changes or 'o' for outgoing,
    # defaults to incoming
    #
    # If no remote is specified, uses the default remote for the
    # current branch, or if that does not exist, 'origin', or if
    # origin does not exist, the first remote listed by 'git remote'.
    #
    # If no remote branch is specified, defaults to be the same name
    # as the current branch if that exists on the remote, otherwise master.

    local gitdir=$(git rev-parse --show-toplevel)
    local localbranch=$(git_current_branch)
    local defaultremote=$(git config branch.${localbranch}.remote)
    local hashref
    local remoterefs

    if [ X"${1}" = "X" ] ; then
        local direction='i'
    else
        local direction=${1}
        shift
    fi

    case $1 in
    -*) # dash arguments left intact, treated as no argument
        if [ X"${defaultremote}" != "X" ] ; then
            local remote=${defaultremote}
        elif git-remote-exists origin ; then
            local remote="origin"
        else
            local remote=$(git remote | head -1)
        fi
        ;;
    ?*) # non-dash argument specified
        local remote=${1}
        shift
        # Check for <remotename>/<remotebranch> syntax
        case $remote in
        */*)
            local remotebranch=$(echo ${remote} | cut -d'/' -f2)
            remote=$(echo ${remote} | cut -d'/' -f1)
            ;;
        esac
        ;;
    *)  # no argument specified
        if [ X"${defaultremote}" != "X" ] ; then
            local remote=${defaultremote}
        elif git-remote-exists origin ; then
            local remote="origin"
        else
            local remote=$(git remote | head -1)
        fi
        ;;
    esac

    # Sanity check the remote existing
    if ! git-remote-exists $remote ; then
        echo "FATAL: remote '${remote}' not found!" 1>&2
        return 1
    fi

    if [ X"${remotebranch}" = "X" ] ; then
        case $1 in
        -*) # dash arguments left intact, treated as no argument
            if hashref=$(git rev-parse --verify --quiet remotes/${remote}/${localbranch}) ; then
                local remotebranch=${localbranch}
            elif hashref=$(git rev-parse --verify --quiet remotes/${remote}/master) ; then
                local remotebranch="master"
            else
                echo "FATAL: neither ${localbranch} nor master exist on ${remote} and no remote branch specified!" 1>&2
                return 2
            fi
            ;;
        ?*) # non-dash argument specified
            local remotebranch=${1}
            shift
            ;;
        *)  # no argument specified
            if hashref=$(git rev-parse --verify --quiet remotes/${remote}/${localbranch}) ; then
                local remotebranch=${localbranch}
            elif hashref=$(git rev-parse --verify --quiet remotes/${remote}/master) ; then
                local remotebranch="master"
            else
                echo "FATAL: neither ${localbranch} nor master exist on ${remote} and no remote branch specified!" 1>&2
                return 2
            fi
            ;;
        esac
    fi

    # Final sanity check on requested remote and branch to give an error message easier to read than Git's
    if ! hashref=$(git rev-parse --verify --quiet remotes/${remote}/${remotebranch}) ; then
        echo "FATAL: branch '${remotebranch}' does not exist on remote '${remote}'!" 1>&2
        return 3
    fi

    case $direction in
    i*)
        echo "Incoming changes from branch ${remotebranch} on ${remote}:"
        git log --color --pretty=medium --date=iso --stat --graph ${localbranch}..remotes/${remote}/${remotebranch} "$@"
        ;;
    o*)
        echo "Outgoing changes to branch ${remotebranch} on ${remote}:"
        git log --color --pretty=medium --date=iso --stat --graph remotes/${remote}/${remotebranch}..${localbranch} "$@"
        ;;
    *)
        echo "Invalid directionality '${direction}'! (use [i]ncoming or [o]utgoing)"
        return 1
        ;;
    esac
}

function gitrevhash {
    # Prints the hash of a git commit "number" (count of commits since
    # the first commit in the branch)
    #
    # This is to be used to reverse the result of function gitrevnum
    # (below) into something git can work with.
    git rev-list --reverse HEAD | awk "NR==$1"
}

function gitrevnum {
    # Prints the current "revision number" (count of commits since the
    # first commit in the branch)
    #
    # For commits since the last tag, use 'git describe'
    git rev-list HEAD | wc -l
}
