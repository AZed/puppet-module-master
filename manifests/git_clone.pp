#
# define master::git_clone
# ========================
#
# Clone a git repository (including submodules) into a specified path
#
# Does nothing if the destination directory already exists
#
#
# Parameters
# ----------
#
# ### from
# The URI of the repository
#
# ### into
# The filesystem path to clone into.  This defaults to
# '/usr/local/src/<reponame>' and if it already exists nothing
# will be done.
#
# ### remote
# The name of the remote after cloning, default: 'origin'
#
define master::git_clone($from, $into=false, $remote='origin') {
    # ## Code Comments
    include master::common::git

    $reponame = regsubst($from,'^.*/([a-zA-Z0-9_-]+)(.git)?$','\1')

    if $into {
        $destdir=$into
    }
    else {
        $destdir="/usr/local/src/${reponame}"
    }

    # In very old versions of git, --recursive may not be available
    case $::operatingsystem {
        'sles': { $recursive = '' }
        default: { $recursive = '--recursive' }
    }

    exec { "git-clone-${title}":
        command => "git clone ${recursive} --origin ${remote} ${from} ${destdir}",
        path => '/bin:/usr/bin',
        unless => "test -d ${destdir}",
        require => Class['master::common::git'],
    }
}
