#
# class master::util::fuse
# ========================
#
# FUSE (Filesystem in User Space) tools and libraries
#

class master::util::fuse {
    case $::osfamily {
        'RedHat': {
            package { "fuse": }
        }
        'Debian': {
            package { "fuse-utils": }
        }
        default: { }
    }
}
