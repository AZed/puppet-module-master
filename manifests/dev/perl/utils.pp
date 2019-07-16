#
# class master::dev::perl::utils
# ==============================
#
# Perl utilities for validating or formatting perl code
#

class master::dev::perl::utils {
    include master::dev::perl::base

    case $::operatingsystem {
        "centos","redhat": {
            package {
                [ "perl-Perl-Critic",
                  "perltidy",
                ]: ensure => latest,
            }
        }
        'debian': {
            package {
                [ "libperl-critic-perl",
                  "perltidy",
                ]: ensure => latest,
            }
        }
        default: { }
    }
}
