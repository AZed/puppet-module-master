#
# class master::common::rsync
# ===========================
#
# Ensure that the rsync command is available, enable rsyncd service
# based on parameter (defaults to off), and optionally configure rsyncd.conf.
#

class master::common::rsync (
    # Parameters
    # ----------
    #
    # ### rsyncd
    # Enable rsyncd?
    #
    # If this is false, /etc/rsyncd.conf will be removed
    $rsyncd = false,

    # ### global_params
    # A hash of global parameters to apply to all modules.  The key of
    # the hash is the name of the configuration entry, the value is
    # placed on the right side of the '=' sign.
    #
    # Example:
    #
    #     master::common::rsync::global_params:
    #       'uid': 'root'
    #       'gid': 'root'
    #
    $global_params = undef,

    # ### module_params
    # Module parameters in rsyncd.conf in 2-level hash format, where
    # the top level is the name of the module and below it is a hash
    # of configuration values.
    #
    # Example:
    #
    #     master::common::rsync::module_params:
    #       home:
    #         'path': '/home'
    #         'read only': 'false'
    #         'use chroot': 'true'
    #       usrlocal:
    #         'path': '/usr/local'
    #
    $module_params = undef,
)
{
    package { 'rsync': ensure => latest, }
    templatelayer { '/etc/default/rsync': }

    if $rsyncd {
        templatelayer { '/etc/rsyncd.conf': }

        case $::osfamily {
            'Debian': {
                service { 'rsync':
                    ensure => $rsyncd ? {
                        true => 'running',
                        default => 'stopped',
                    },
                    hasrestart => true,
                    hasstatus => false,
                    subscribe => File['/etc/rsyncd.conf'],
                }
            }
            default: { }
        }
    }
    else {
        file { '/etc/rsyncd.conf': ensure => absent }
    }
}
