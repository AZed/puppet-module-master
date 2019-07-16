#
class master::client::gluster (
    $release_package = 'centos-release-gluster37',
) {
    case $::operatingsystem {
        'centos': {
            $os_defined = true
            $glusterfs_client_package = 'glusterfs'

            # This is a kludge because Puppet 3.8.5 breaks passing arrays to
            # the name parameter in the package resource.
            package { 'glusterfs-fuse': ensure => 'installed', before => Package['glusterfs-client'] }
            package { 'glusterfs-cli':  ensure => 'installed', before => Package['glusterfs-client'] }

            # Gluster repos have moved
            if ! defined(Package[$release_package]) {
                package { $release_package:
                    before => Package['glusterfs-client'],
                }
            }
#            if ! defined(Master::Yum_repo['glusterfs-3-7-epel']) {
#                master::yum_repo { 'glusterfs-3-7-epel':
#                    before => Package['glusterfs-client'],
#                }
#            }
        }
        'debian': {
            $os_defined = true
            $glusterfs_client_package = 'glusterfs-client'
        }
        default: {
            notify { "${name}_OS_${::operatingsystem}_unknown":
                loglevel => 'alert',
                message  => "Unknown OS '${::operatingsystem}', skipping",
            }
            $os_defined = false
        }
    }
    if $os_defined {
        # Make sure the package is installed
        package { 'glusterfs-client':
            ensure => 'installed',
            name   => $glusterfs_client_package,
        }
    }
}

define gluster_mount(
    $volume = undef,
    $device = "localhost"
) {
    file { "${name}":
        ensure => directory,
        mode   => '0755',
        owner  => 'root',
        group  => 'root'
    }

    mount { "${name}":
        atboot  => true,
        ensure  => mounted,
        device  => "${device}:${volume}",
        fstype  => glusterfs,
        options => "log-file=/var/log/${volume}.vol,defaults",
        dump    => 0,
        pass    => 0,
        require => [ Package["glusterfs-client"],
                     File["${name}"],
                   ]
    }
}
