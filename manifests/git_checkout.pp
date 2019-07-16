#
# define master::git_checkout
# ===========================
#
# Check out a git repository to a specified revision, discarding all
# existing uncommitted changes
#
# Parameters
# ----------
#
# ### repo
# The filesystem path to the git repository
#
# ### revision
# The revision spec to check out
#
define master::git_checkout($repo, $revision='master') {
    include master::common::git

    exec { "git-checkout-${title}":
        command => "git checkout -f ${revision}",
        cwd => $repo,
        path => '/bin:/usr/bin',
        require => Class['master::common::git'],
    }
}
