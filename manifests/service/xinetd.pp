#
# class master::service::xinetd
# =============================
#
# Sets up xinetd as an inetd superserver
#

class master::service::xinetd (
    # Parameters
    # ----------

    # ### instances
    # Maximum number of requests xinetd can handle at once
    $instances = '30'
)
{
    package { "xinetd": ensure => installed }

    case $::operatingsystem {
        'SLES': {
            templatelayer { '/etc/xinetd.conf': suffix => $::operatingsystem }
        }
        default: {
            templatelayer { '/etc/xinetd.conf': }
        }
    }
    service { 'xinetd':
        ensure  => running,
        enable  => true,
        require => Templatelayer['/etc/xinetd.conf'],
    }
    master::nagios_check { '20_Proc_xinetd': }
}
