#
class master::client::snmp {

    $snmp_client_package = $::operatingsystem ? {
        'centos' => 'net-snmp-utils',
        'debian' => 'snmp',
        default  => 'snmp',
    }

    # Make sure the package is installed
    package { 'snmp-client':
        ensure => 'installed',
        name   => $snmp_client_package,
    }

    case $::operatingsystem {
        'debian': {
            templatelayer { "/etc/snmp/snmp.conf":
                require => Package['snmp-client'],
            }
        }
    }
}
