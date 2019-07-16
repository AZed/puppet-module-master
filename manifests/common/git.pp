#
# class master::common::git
# =========================
#
# This places just the core git package on every system using
# master::common, for much the same reason as master::common::mercurial
# exists.  This is, however, only a minimal environment for tracking
# system packages (i.e. so /etc can use git), and not a complete
# development environment.  For a complete development environment,
# use master::dev::git.
#
# See also the master::git_* defines
#

class master::common::git {
    include master::common::package_management

    case $::operatingsystem {
        # The core git package was renamed from 'git-core' to 'git' for
        # Debian Squeeze
        'debian': {
            if versioncmp($::operatingsystemrelease, '6.0') < 0 {
                $git_package = 'git-core'
            }
            else {
                $git_package = 'git'
            }
        }
        'sles': {
            $git_package = 'git-core'
        }
        default: { $git_package = 'git' }
    }

    package { $git_package: ensure => latest,
        alias => 'git',
        require => Class['master::common::package_management']
    }

    templatelayer { '/usr/local/bin/gitssh':
        owner => root, group => root, mode => '0555',
    }
}
