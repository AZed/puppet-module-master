# gluster-peer - configure the peers of a gluster cluster
#
# usage:
#   gluster-peer { "<fqdn>": uuid => "<uuid>" }
#
#   The uuid can be generated via the uuid(1) tool.
#
#   Example:
#       uuid -v5 ns:DNS <fqdn>
#
##############################################################################
define master::service::gluster::peer( $uuid,
    $this = false
)
{
    case $::operatingsystem {
        'centos': {
            $peer_path  = '/var/lib/glusterd'
            $os_defined = true
        }
        'debian': {
            $peer_path  = '/etc/glusterd'
            $os_defined = true
        }
        default: {
            $os_defined = false
            notify { "${name}_OS_${::operatingsystem}_unknown":
                loglevel => 'alert',
                message  => "Unknown OS '${::operatingsystem}', skipping",
            }
        }
    }

    if $os_defined {
        $gluster_fqdn = $name
        $gluster_uuid = $uuid

        if ( ! ( $uuid =~ /^[a-z0-9]{8}-([a-z0-9]{4}-){3}[a-z0-9]{12}$/ ) ) {
            fail( "ERROR: invalid uuid '${uuid}' for ${name}" )
        }

        # If this is our entry then set glusterd.info
        if ( "${name}" == "${fqdn}" or $this ) {
            templatelayer { "${peer_path}/glusterd.info":
                require  => Package[glusterfs-server],
                notify   => Service[glusterfs-server],
                before   => Service[glusterfs-server],
                template => 'master/etc/glusterd/glusterd.info',
                mode     => '0400',
                owner    => 'root',
                group    => 'root',
            }
        } else {
            templatelayer { "${peer_path}/peers/${gluster_uuid}":
                require  => Package[glusterfs-server],
                notify   => Service[glusterfs-server],
                before   => Service[glusterfs-server],
                template => "master/etc/glusterd/peers/peer",
                mode     => '0600',
                owner    => 'root',
                group    => 'root',
            }
        }
    }
}
