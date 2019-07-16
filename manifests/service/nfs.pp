#
# class master::service::nfs
#
# Set up an NFS server
#
class master::service::nfs (
    # An array containing lines to be placed in /etc/exports
    $exports = false,

    # An array of template fragments to place in /etc/exports
    $exports_templates = false,

    # Override the default mountd port
    $mountd_port = false,

    # specify a package providing the NFS server, autodetected if false
    $package = false,

    # Arguments to pass to rpc.statd
    $statd_args = false,
)
{
    include master::common::network
    Class['master::common::network'] -> Class[$name]

    # Determine actual values for NFS package and service
    if $package {
        $nfs_package = $package
    }
    else {
        case $::osfamily {
            'RedHat': {
                $nfs_package = "nfs-utils"
            }
            'Debian': {
                $nfs_package = "nfs-kernel-server"
            }
            'Suse': {
                $nfs_package = 'nfs-utils'
            }
            default: {
                fail("No default NFS package defined for ${::operatingsystem}")
            }
        }
    }
    case $nfs_package {
        'nfs-utils': {
            $nfs_service = 'nfs'
        }
        default: {
            $nfs_service = $nfs_package
        }
    }

    # Resource definitions begin here
    package { $nfs_package: ensure => latest }

    templatelayer { '/etc/exports':
        owner => 'root', group => 'root', mode => '0400',
        notify => Service[$nfs_service],
    }

    case $::osfamily {
        'Debian': {
            templatelayer { "/etc/default/nfs-kernel-server":
                notify => Service[$nfs_service],
            }
            templatelayer { "/etc/default/nfs-common":
                notify => Service[$nfs_service],
            }
        }
        'RedHat': {
            templatelayer { "/etc/sysconfig/nfs":
                notify => Service[$nfs_service],
            }
        }
    }

    service { $nfs_service: ensure => running,
        hasrestart => true,
        hasstatus  => true,
        require    => Package[$nfs_package],
    }

    master::nagios_check { '20_Proc_nfs': }
}
