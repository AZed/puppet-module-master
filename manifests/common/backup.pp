#
# class master::common::backup
# ============================
#
# Install the packages used for system backups
# (Currently this is just Duplicity and its dependencies)
#

class master::common::backup (
    # Parameters
    # ----------
    #
    # ### duphelper_repo
    # Repository to use to pull down the Duphelper source
    $duphelper_repo = 'git://github.com/AZed/duphelper.git'
)
{
    include master::common::git
    include master::common::gpg
    include master::dev::perl::config
    include master::dev::python::crypt

    case $::operatingsystem {
        'sles': {
            notify { "${name}-nopackages":
                message => "WARNING: Duplicity will have to be installed manually on ${::operatingsystem}.",
                loglevel => warning,
            }
        }
        default: {
            package { 'duplicity': ensure => latest,
                require => Class['master::common::package_management'],
            }
        }
    }

    master::git_mirror { 'duphelper':
        from => $duphelper_repo,
        schedule => 'oncedaily',
    }

    file { '/etc/duplicity': ensure => directory }

    file { 'duphelper':
        ensure => '../src/duphelper/scripts/duphelper',
        path => '/usr/local/sbin/duphelper',
    }
    file { 'dupback':
        ensure => 'duphelper',
        path => '/usr/local/sbin/dupback',
    }
    file { 'dupclean':
        ensure => 'duphelper',
        path => '/usr/local/sbin/dupclean',
    }
    file { 'dupcleancount':
        ensure => 'duphelper',
        path => '/usr/local/sbin/dupcleancount',
    }
    file { 'dupget':
        ensure => 'duphelper',
        path => '/usr/local/sbin/dupget',
    }
    file { 'duplist':
        ensure => 'duphelper',
        path => '/usr/local/sbin/duplist',
    }
    file { 'dupstat':
        ensure => 'duphelper',
        path => '/usr/local/sbin/dupstat',
    }
    file { 'dupver':
        ensure => 'duphelper',
        path => '/usr/local/sbin/dupver',
    }
}
