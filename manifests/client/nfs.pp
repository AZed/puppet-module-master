#
# class master::client::nfs
#
# Sets up a NFS client
#
class master::client::nfs {
    Class['master::common::network'] -> Class[$name]

    case $::operatingsystem {
        'centos': {
            # CentOS uses the same package for both server and client
            # installations.  We'll check to make sure the package hasn't
            # already been defined before we try to install it here.
            if ( ! defined( Package['nfs-utils'] ) ) {
                package { [ 'nfs-utils', 'nfs-utils-lib' ]: ensure => latest }
            }
        }
        'debian': {
            package { "nfs-common": ensure => latest }
        }
        default: {
            fail( "not configured for '${::operatingsystem}'" )
        }
    }
}
