# == Class: master::service::opensm
#
#   Class to configure the OpenSM service.
#
# == Parameters
#
#   The following parameters are used by master::service::opensm
#
#   [*sm_priority*]
#       Sets the subnet manager priority.  
#       0 (lowest priority) to 15 (highest). ( default: 14 )
#
#   [*sminfo_polling_timeout*]
#       Timeout in [msec] between two polls of active master SM
#
#   [*sweep_interval*]
#       The number of seconds between subnet sweeps (0 disables it)
#
# === Examples
#
#   node mynode1 {
#       class { 'master::service::opensm': }
#   }
#
#   node mynode2 {
#       class { 'master::service::opensm': sm_priority => 13 }
#   }
#
# === Supported Operating Systems
#
#   * Centos
#   * Debian
#
###############################################################################
class master::service::opensm (
    $sm_priority            = 14,
    $sminfo_polling_timeout = 1000,
    $sweep_interval         = 10,
    $standby                = 'no'
)
{
    Class['master::util::ib'] -> Class[$name]

    # OS prep
    case $::operatingsystem {
        'debian': {
            $package  = 'opensm'
            $service  = 'opensm'
            $confdir  = '/etc/opensm'
            $config   = 'opensm.conf'
            $owner    = 'root'
            $group    = 'root'
            $confmode = '0644'
        }
        'centos': {
            $package  = 'opensm'
            $service  = 'opensm'
            $confdir  = '/etc/rdma'
            $config   = 'opensm.conf'
            $owner    = 'root'
            $group    = 'root'
            $confmode = '0644'
        }
        default: {
            fail("$::module not configured for $::operatingsystem")
        }
    }

    # Make sure the OpenSM package is installed
    package { $package: ensure => 'installed' }

    # Make sure the configuration directory exists
    file { $confdir:
        ensure  => 'directory',
        owner   => $owner,
        group   => $group,
        mode    => $confmode,
        require => Package[$package],
    }

    # Configure OpenSM
    templatelayer { "$confdir/$config":
        owner   => $owner,
        group   => $group,
        mode    => $confmode,
        notify  => Service[$service],
        require => [
            Package[$package],
            File[$confdir],
        ]
    }

    # Ensure the service is running
    service { $service:
        ensure     => 'running',
        enable     => true,
        status     => "/usr/bin/pgrep -fx '/usr/sbin/$service .*'",
        hasstatus  => false,
        require    => [
            Package[$package],
            File[$confdir],
            Templatelayer["$confdir/$config"], 
        ]
    }
}
