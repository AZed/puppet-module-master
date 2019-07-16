#
class master::service::gluster (
    $release_package = 'centos-release-gluster',

    # number of peers that should exist in the gluster
    # ('0' will cause nagios to only check peers that exist)
    $nagios_gluster_peers = 0,

    # array of gluster volumes to check
    $nagios_gluster_volumes = [ ],
)
{
    # Make sure the package is installed
    case $::operatingsystem {
        'centos': {
            $gluster_server_package = 'glusterfs-server'
            $gluster_service        = 'glusterd'

            # Gluster repos have moved
            package { $release_package:
                before => Package[ $gluster_server_package ],
            }
#            master::yum_repo { 'glusterfs-3-7-epel':
#                before => Package[ $gluster_server_package ],
#            }

            # Make sure the service is running
            service { 'glusterd':
                ensure     => running,
                hasrestart => true,
                require    => Package[$gluster_server_package],
            }

        }
        'debian': {
            $gluster_server_package = "glusterfs-server"
            $gluster_service        = 'glusterd'

            # Make sure the service is running
            service { 'glusterfs-server':
                ensure     => running,
                hasrestart => true,
                pattern    => $gluster_service,
                require    => Package[$gluster_server_package],
            }
        }
        default: {
            fatal( "unknown OS '${::operatingsystem}'" )
        }
    }

    package { $gluster_server_package:
        ensure => 'installed',
    }
    master::nagios_check { '20_Proc_gluster': }
    master::nagios_check { '30_gluster_peers': }
    master::nagios_check { '30_gluster_volumes': }
}

