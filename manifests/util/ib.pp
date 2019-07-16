#
class master::util::ib (
)
{
    # OS prep
    case $::operatingsystem {
        'debian': {
            master::kernel_module { 'ib_umad': }
            master::kernel_module { 'ib_uverbs': }
            master::kernel_module { 'ib_ipoib': }

            templatelayer { '/etc/network/if-up.d/ib':
                owner => 'root',
                group => 'root',
                mode  => '0755',
            }
        }
        'centos': {
            master::kernel_module { 'ib_umad':   module_file => "/etc/rc.modules" }
            master::kernel_module { 'ib_uverbs': module_file => "/etc/rc.modules" }
            master::kernel_module { 'ib_ipoib':  module_file => "/etc/rc.modules" }

            package { 'infiniband-diags': ensure => 'installed' }
            package { 'ibutils': ensure => 'installed' }

            case $::operatingsystemmajrelease {
                '6': {
                    exec { 'start-rdma':
                        path => [ '/bin', '/usr/bin', '/sbin', '/usr/sbin' ],
                        command => '/etc/init.d/rdma start',
                        unless  => '/etc/init.d/rdma status | grep -c ib0',
                    }
                }
                '7': {
                    service { 'rdma':
                        ensure => 'running',
                        enable => true,
                    }
                }
                default: {
                    fail("$::module not configured for $::operatingsystem $::operatingsystemmajrelease")
                }
            }
        }
        default: {
            fail("$::module not configured for $::operatingsystem")
        }
    }

}
