#
# master::service::qemu
#
# Sets up a hypervisor using QEMU, KVM compatibility, and LibVirt
#
# STUB: currently, this only installs the packages and sets up the
# service.  Configuration is completely unhandled.
#

class master::service::qemu (
    # STUB: hash for holding configuration for qemu.conf
    $qemu_config = undef,

    # Manage the UID and GID of the qemu user and group?  WARNING:
    # setting either of these to a number below 300 may impact your
    # ability to consistently rebuild the system.
    $qemu_uid = undef,
    $qemu_gid = undef,
){
    include master::common::package_management

    case $::osfamily {
        'Debian': {
            $qemu_packages =
            [ 'qemu',
              'qemu-kvm',
              'virt-goodies',
              'virt-manager',
              'virt-top',
              'virt-viewer',
              'libvirt-clients',
              'libvirt-doc',
              ]
            $qemu_user = 'libvirt-qemu'
            $qemu_group = 'libvirt-qemu'
        }
        'RedHat': {
            $qemu_packages =
            [ 'qemu-kvm',
              'qemu-img',
              'virt-manager',
              'libvirt',
              'libvirt-python',
              'libvirt-client',
              'virt-viewer',
              ]
            $qemu_user = 'qemu'
            $qemu_group = 'qemu'

        }
        default: {
            $qemu_packages = []
            $qemu_user = undef
            $qemu_group = undef
        }
    }
    package { $qemu_packages:
        require => Class['master::common::package_management'],
    }

    if $qemu_uid {
        user { $qemu_user:
            uid     => $qemu_uid,
            gid     => $qemu_gid,
            notify  => Service['libvirtd'],
            require => Package[$qemu_packages],
        }
    }
    if $qemu_gid {
        group { $qemu_group:
            gid     => $qemu_gid,
            notify  => Service['libvirtd'],
            require => Package[$qemu_packages],
        }
    }
    service { 'libvirtd':
        ensure  => 'running',
        enable  => true,
    }
}
