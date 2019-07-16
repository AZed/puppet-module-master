#
# class master::dev::perl::uuid
# ===============================
#
# Install Perl packages related to universally unique identifiers
#

class master::dev::perl::uuid {
    include master::dev::perl::base

    case $::osfamily {
        'Debian': {
            package { 'libossp-uuid-perl': }
            package { 'libuuid-perl': }
        }
        'RedHat': {
            package { 'uuid-perl': }
        }
        'Suse': {
            package { 'perl-Data-UUID': }
            package { 'perl-UUID': }
        }
        default: { }
    }
}
