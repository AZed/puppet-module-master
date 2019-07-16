#
# class master::util::minicom
#
# Installs and configures the minicom package for serial communication
#

class master::util::minicom (
    $minicom_port      = '/dev/ttyS0',
    $minicom_baudrate  = '9600',
    $minicom_bits      = '8',
    $minicom_parity    = 'N',
    $minicom_stopbits  = '1',
    $minicom_minit     = '',
    $minicom_mreset    = '',
    $minicom_mhangup   = '',
    $minicom_mdialcan  = '',
    $minicom_rtscts    = '',
)
{
    package { "minicom": ensure => latest }

    $minicom_users = $::operatingsystem ? {
        'centos' => '/etc/minicom.users',
        'redhat' => '/etc/minicom.users',
        default  => '/etc/minicom/minicom.users',
    }

    $minirc_dfl = $::operatingsystem ? {
        'centos' => '/etc/minirc.dfl',
        'redhat' => '/etc/minirc.dfl',
        default  => '/etc/minicom/minirc.dfl',
    }

    templatelayer { $minirc_dfl:
        require => Package['minicom'],
    }
    templatelayer { $minicom_users:
        require => Package['minicom'],
    }
}
