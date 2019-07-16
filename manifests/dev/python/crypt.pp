#
# class master::dev::python::crypt
# ================================
#
# Python cryptographic libraries, required in particular by Duplicity
#

class master::dev::python::crypt {
    Package { ensure => installed }

    case $::operatingsystem {
        'sles': {
            if versioncmp($::operatingsystemrelease, '12.0') < 0 {
                package { 'python-crypto': }
            }
            else {
                package { 'python-cryptography': }
            }
        }
        'centos': {
            package { 'python-paramiko': }
            if versioncmp($::operatingsystemrelease, '7.0') < 0 {
                package { 'python-crypto': }
            }
            else {
                package { 'python2-crypto': }
                # python2-paramiko used to be a package in EPEL 7, but
                # is no longer, and conflicts with the standard
                # python-paramiko in recent RH/CentOS releases
                package { 'python2-paramiko':
                    ensure => absent,
                    before => Package['python-paramiko'],
                }
            }
        }
        default: {
            package { 'python-paramiko': }
            package { 'python-crypto': }
        }
    }
}
