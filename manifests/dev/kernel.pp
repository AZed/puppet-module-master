#
# class master::dev::kernel
#
# Packages used for building a kernel or modules
#

class master::dev::kernel {
    Class['master::dev::base'] -> Class[$name]

    Package { ensure => latest }

    case $::operatingsystem {
        'debian': {
            package { 'linux-source': ensure => latest }
        }
        'centos','redhat': {
            package { 'kernel-devel': ensure => latest }
        }
        default: { }
    }
}
