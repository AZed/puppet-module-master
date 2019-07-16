#
# define master::git_mirror
# =========================
#
# A combination of clone, fetch, and reset -- use this to ensure that
# the contents of the filesystem exactly match the upstream remote
# branch
#
define master::git_mirror (
    # Parameters
    # ----------
    #
    # ### from
    $from,

    # ### into
    $into=false,

    # ### remote
    $remote='origin',

    # ### remotebranch
    $remotebranch='master'
)
{
    $reponame = regsubst($from,'^.*/([a-zA-Z0-9_-]+)(.git)?$','\1')
    if $into {
        $repo=$into
    }
    else {
        $repo="/usr/local/src/${reponame}"
    }
    master::git_clone { $title:
        from   => $from,
        into   => $into,
        remote => $remote
    }
    master::git_fetch { $title:
        repo => $repo, remote => $remote,
        require => Master::Git_clone[$title],
    }
    master::git_reset { $title:
        repo => $repo, revision => "${remote}/${remotebranch}",
        require => Master::Git_fetch[$title],
    }
}
