#
# define master::git_reset
# ========================
#
# Perform a hard reset on a git repository to a specified revision,
# discarding all existing changes whether or not they have been
# committed.  Unlike master::git_pull, this command should never fail
# if the target revision exists.
#
#
# Parameters
# ----------
#
# ### repo
# ### revision
#
define master::git_reset($repo, $revision='origin/master') {
    include master::common::git

    exec { "git-reset-${title}":
        command => "git reset --hard ${revision}",
        cwd     => $repo,
        path    => '/bin:/usr/bin',
        unless  => "test $(git rev-parse HEAD) = $(git rev-parse ${revision})",
        require => Class['master::common::git'],
    }
}
