#
# class master::dev::perl::json
# =============================
#
# Install packages related to JSON parsing in Perl
#

class master::dev::perl::json {
    include master::dev::perl::base

    case $::osfamily {
        'Debian': {
            package { 'libjson-any-perl': }
            package { 'libjson-perl': }
            package { 'libjson-pp-perl': }
            package { 'libjson-rpc-perl': }
            package { 'libjson-xs-perl': }
        }
        'RedHat': {
            package { 'perl-JSON': }
            package { 'perl-JSON-Any': }
            package { 'perl-JSON-MaybeXS': }
            package { 'perl-JSON-XS': }
        }
        'Suse': {
            package { 'perl-Cpanel-JSON-XS': }
            package { 'perl-JSON': }
            package { 'perl-JSON-MaybeXS': }
            package { 'perl-JSON-PP': }
            package { 'perl-JSON-XS': }
        }
        default: {
            notify { "${name}-nopackages":
                message => "WARNING: no packages were defined for ${name} on ${::operatingsystem}.",
                loglevel => warning,
            }
        }
    }
}
