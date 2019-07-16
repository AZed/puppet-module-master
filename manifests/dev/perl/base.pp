#
# master::dev::perl::base
# =======================
#
# Ensures that the base perl system is available and that a
# /usr/local/bin/perl symlink exists.
#

class master::dev::perl::base {
    Package { ensure => installed }
    case $::osfamily {
        'debian': {
            package { ['perl','perl-base']: }
        }
        'redhat': {
            package { ['perl']: }
        }
        'suse': {
            package { ['perl','perl-base']: }
        }
        default: {
            notify { "${name}-nopackages":
                message => "WARNING: no packages were defined for ${name} on ${::operatingsystem}.",
                loglevel => warning,
            }
        }
    }
    file { '/usr/local/bin/perl': ensure => '../../bin/perl' }
}
