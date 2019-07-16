#
# class master::dev::perl::unicode
# ================================
#
# Install Perl packages related to Unicode
#

class master::dev::perl::unicode {
    include master::dev::perl::base

    case $::operatingsystem {
        'debian': {
            package { 'libunicode-map-perl': }
            package { 'libunicode-map8-perl': }
            package { 'libunicode-maputf8-perl': }
            package { 'libunicode-string-perl': }
        }
        'centos','redhat': {
            package { 'perl-Unicode-Map': }
            package { 'perl-Unicode-Map8': }
            package { 'perl-Unicode-MapUTF8': }
            package { 'perl-Unicode-String': }
        }
        default: {
            notify { "${title}-unknown-os":
                message => "WARNING: ${title} is not configured for ${::operatingsystem}!",
                loglevel => warning,
            }
        }
    }
}
