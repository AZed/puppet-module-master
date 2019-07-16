#
# master::common::sysctl
# ======================
#
# Handle construction of /etc/sysctl.conf
#

class master::common::sysctl (
    # Parameters
    # ----------
    #
    # ### ipv4_ip_forward
    # Allow IPv4 IP forwarding
    $ipv4_ip_forward = '0',

    # ### ipv6_forwarding
    # Allow IPv6 forwarding
    $ipv6_forwarding = '0',

    # ### shmmax
    # Sets the value of kernel/shmmax in sysctl.conf, specified in bytes.
    # The default for both RedHat and Debian is 32MB, which is too small
    # for some applications.
    #
    # If this is set to false, then the template will automatically set
    # this to half of available memory on Linux systems, or 32 MB on
    # systems where memorysizeinbytes isn't available.
    #
    # If this is set to the string 'NULL', then it will not be listed at all.
    $shmmax = 33554432,

    # ### shmall
    # Sets the value of kernel/shmall in sysctl.conf.  The default value
    # on most systems is 2097152, but this needs to be raised if shmmax
    # exceeds 8G.  In most cases, this can be left false, in which case
    # it will be computed automatically (assuming 4096-byte pages) if it
    # is needed.
    #
    # If this is set to the string 'NULL', then it will not be listed at all.
    $shmall = false,

    # ### templates
    # An array of template fragments to be transcluded
    $templates = [ ]
)
{
    templatelayer { '/etc/sysctl.conf':
        notify => Exec['/sbin/sysctl -p /etc/sysctl.conf']
    }
    exec { '/sbin/sysctl -p /etc/sysctl.conf':
        path        => [ '/sbin' ],
        refreshonly => true,
        require     => File['/etc/sysctl.conf']
    }
}
