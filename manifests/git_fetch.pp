#
# define master::git_fetch
# ========================
#
# Fetch remote changes into a local git repository (this makes no
# change to the checked-out filesystem state)
#
# A single remote can be fetched instead by specifying it as a
# parameter.
#
#
# Parameters
# ----------
#
# ### repo
# ### remote
#
define master::git_fetch($repo, $remote='--all') {
    include master::common::git

    exec { "git-fetch-${title}":
        command => "git fetch ${remote}",
        cwd => $repo,
        path => '/bin:/usr/bin',
        require => Class['master::common::git'],
    }
}
