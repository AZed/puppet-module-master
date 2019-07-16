#
# master::dev::python::base
#
# The absolute minimum to guarantee being able to install Python
# modules on a system.
#

class master::dev::python::base {
    Package { ensure => installed }
    package { 'python': }
    package { 'python-setuptools': }

    case $::osfamily {
        'Debian': {
            if versioncmp($::operatingsystemrelease, '9.0') < 0 {
                package { 'python-support': }
            }
        }
        'RedHat': {
        }
        'Suse': {
        }
        default: { }
    }
}
