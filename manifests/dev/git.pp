#
# class master::dev::git
#
# A complete development package set for the Git version control
# system.  The core system is defined in master::common::git, and this
# adds on the additional tools that someone would expect to have if
# actually developing something with Git as a version control system,
# rather than just using it for basic system versioning.
#

class master::dev::git (
    # Git Repository Base (where the /git symlink points)
    $git_repo_base = false
)
{
    if (!defined(Class['master::dev::perl::email'])) {
        include master::dev::perl::email
    }
    if (!defined(Class['master::dev::tcl'])) {
        include master::dev::tcl
    }
    Class['master::common::git'] -> Class[$name]
    Class['master::dev::perl::email'] -> Class[$name]
    Class['master::dev::tcl'] -> Class[$name]


    case $::operatingsystem {
        'Debian': {
            $dev_git_packages =
            [ 'git-doc',
              'git-cvs',
              'git-email',
              'git-svn',
              'gitk',
              'guilt',
              'tig',
              ]
        }
        'centos','redhat': {
            $dev_git_packages = [ 'git-all', ]
        }
        'SLES': {
            $dev_git_packages =
            [ 'git-cvs',
              'git-email',
              'git-gui',
              'git-svn',
              'gitk',
              ]
        }
        default: {
            $dev_git_packages = [ ]
        }
    }

    package { $dev_git_packages:
        ensure => latest,
        require => Package['git'],
    }

    if $git_repo_base {
        file { '/git': ensure => $git_repo_base }
    }
}
