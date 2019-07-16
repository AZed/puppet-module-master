#
# class master::util::geoip
# =========================
#
# GeoIP-related packages
#

class master::util::geoip {
    case $::osfamily {
        'RedHat': {
            package { "geoip-devel": }
        }
        'Debian': {
            package { "geoip-bin": }
            package { "geoip-database": }
            package { "libgeoip-dev": }
        }
    }
}
