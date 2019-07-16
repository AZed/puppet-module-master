#
# define master::git_pull
# =======================
#
# Pull remote changes into a local git repository, merging the default
# remote into the current branch and updating the filesystem state.
#
#
# Parameters
# ----------
#
# ### repo
# ### remote
#
define master::git_pull($repo, $remote='origin') {
    include master::common::git

    exec { "git-pull-${title}":
        command => "git pull -f ${remote}",
        cwd => $repo,
        path => '/bin:/usr/bin',
        require => Class['master::common::git'],
    }
}
