#
# master::user::office
#
# Non-KDE/Gnome office applications
#

class master::user::office {
    case $::operatingsystem {
        'debian': {
            # In Debian Wheezy or later:
            if versioncmp($::operatingsystemrelease, '7.0') >= 0 {
                package { 'libreoffice': }
            }
            else {
                package { "openoffice.org": ensure => latest }
                package { "openoffice.org-filter-binfilter": ensure => latest }
            }
        }
        default: {
            package { 'libreoffice': ensure => latest }
        }
    }
}
