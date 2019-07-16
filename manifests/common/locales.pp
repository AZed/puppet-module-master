#
# class master::common::locales
# =============================
#
# Special locales handling under Debian.  There doesn't appear to be
# an equivalent mechanism under either CentOS or SLES.
#

class master::common::locales {
    case $::operatingsystem {
        'Debian': {
            package { 'locales': ensure => present, }
            templatelayer { '/etc/locale.gen':
                notify => Exec['locale-gen'],
                require => File['/etc/default/locale']
            }
            templatelayer { '/etc/default/locale': }

            exec { 'locale-gen':
                path => '/bin:/usr/bin:/usr/sbin',
                refreshonly => true,
                timeout => 30
            }
        }
        default: { }
    }
}
