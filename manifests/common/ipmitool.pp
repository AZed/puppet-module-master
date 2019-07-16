#
# class master::common::ipmitool
# ==============================
#
# Installs and configures the ipmitool package
#
# TODO: Added the modules to /etc/modules so they'll load at boot
#

class master::common::ipmitool (
    # Parameters
    # ----------
    #
    # ### clear_bmc_lan
    # Simple flag to dermine if the bmc lan configuration should be cleared
    $clear_bmc_lan = true,
)
{
    # Code
    # ----

    # Set the module file to modify and fail directly if we don't know
    # how to handle it for a given OS
    case $::osfamily {
        'Debian': {
            $module_file = '/etc/modules'
            $ipmievd_default_file = '/etc/default/ipmievd'
            $ipmi_packages = [ 'openipmi', 'ipmitool' ]
        }
        'RedHat': {
            $module_file = '/etc/rc.modules'
            $ipmievd_default_file = '/etc/sysconfig/ipmievd'
            $ipmi_packages = [ 'OpenIPMI', 'ipmitool' ]
        }
        default: {
            fail( "kernel-module not configured for ${::operatingsystem}" )
        }
    }

    # Whether or not the system is virtual and thus incapable of
    # actually returning IPMI information, we install the IPMI packages
    # so Puppet doesn't throw errors when trying to use the ipmitool
    # command.
    package { $ipmi_packages: ensure => 'latest' }

    case $::virtual {
        'physical': {
            case $::osfamily {
                'RedHat': {
                    # ensure the impi service is running
                    service { 'ipmi':
                        ensure  => 'running',
                        require => Package[$ipmi_packages],
                    }

                    file { '/tmp/ipmi-os-kludge':
                        ensure  => 'absent',
                        require => [ Package[$ipmi_packages],
                                     Service['ipmi'],
                                     ],
                    }
                }
                'Debian': {
                    # Ensure the ipmi_msghandler module is loaded
                    master::kernel_module { 'ipmi_msghandler':
                        module_file => $module_file,
                        require     => Package[$ipmi_packages],
                    }

                    # Ensure the ipmi_devintf module is loaded
                    master::kernel_module { 'ipmi_devintf':
                        module_file => $module_file,
                        require     => Package[$ipmi_packages],
                    }

                    # Ensure the ipmi_si module is loaded
                    master::kernel_module { 'ipmi_si':
                        module_file => $module_file,
                        require     => [ Package[$ipmi_packages],
                                         Master::Kernel_module['ipmi_msghandler'],
                                         Master::Kernel_module['ipmi_devintf'],
                                         ]
                    }

                    file { '/tmp/ipmi-os-kludge':
                        ensure  => 'absent',
                        require => [ Package[$ipmi_packages],
                                     Master::Kernel_module['ipmi_msghandler'],
                                     Master::Kernel_module['ipmi_devintf'],
                                     Master::Kernel_module['ipmi_si'],
                                     ]
                    }
                }
            }

            # Set the SEL time
            exec { 'ipmi-sel-time-set':
                command => "/usr/bin/ipmitool sel time set \"`/bin/date +'%m/%d/%Y %H:%M:%S'`\"",
                unless  => "/usr/bin/ipmitool sel time get | /bin/grep -q \"`/bin/date +'%m/%d/%Y %H:%M:%S'`\"",
                require => [ Package[$ipmi_packages],
                             File['/tmp/ipmi-os-kludge'],
                             ]
            }

            # Enable ipmievd so SEL events are sent to SYSLOG
            templatelayer { $ipmievd_default_file: }
            service { 'ipmievd':
                ensure => running,
                require => [ Package[$ipmi_packages],
                             File['/tmp/ipmi-os-kludge'],
                             Templatelayer[$ipmievd_default_file],
                             ]
            }

            # Disable the BMC LAN configuration
            # NOTE: This is really a placeholder to disable the BMC LAN until
            #       we're ready to implement network based management properly
            if ( $clear_bmc_lan ) {
                exec { 'ipmi-set-ipsrc':
                    command => '/usr/bin/ipmitool lan set 1 ipsrc static',
                    unless  => "/usr/bin/ipmitool lan print 1 | /bin/grep -q 'IP Address Source.*Static Address'",
                    require => [ Package[$ipmi_packages],
                                 File['/tmp/ipmi-os-kludge'],
                                 ]
                }
                exec { 'ipmi-set-ipaddr':
                    command => "/usr/bin/ipmitool lan set 1 ipaddr 0.0.0.0",
                    unless  => "/usr/bin/ipmitool lan print 1 | /bin/grep -q '^IP Address.*.\\.0\\.0\\.0'",
                    require => [ Package[$ipmi_packages],
                                 Exec['ipmi-set-ipsrc'],
                                 File['/tmp/ipmi-os-kludge'],
                                 ]
                }
                exec { 'ipmi-set-netmask':
                    command => '/usr/bin/ipmitool lan set 1 netmask 255.255.255.255',
                    unless  => "/usr/bin/ipmitool lan print 1 | /bin/grep -q '^Subnet Mask.*255\\.255\\.255\\.255'",
                    require => [ Package[$ipmi_packages],
                                 Exec['ipmi-set-ipsrc'],
                                 File['/tmp/ipmi-os-kludge'],
                                 ]
                }
                #exec { 'ipmi-set-macaddr':
                #    command => '/usr/bin/ipmitool lan set 1 macaddr 00:00:00:00:00:00',
                #    unless  => "/usr/bin/ipmitool lan print 1 | /bin/grep -q '^MAC Address.*00:00:00:00:00:00'",
                #    require => [ Package['openipmi'],
                #                 Package['ipmitool'],
                #                 Master::Kernel_module['ipmi_msghandler'],
                #                 Master::Kernel_module['ipmi_devintf'],
                #                 Master::Kernel_module['ipmi_si'],
                #                 Exec['ipmi-set-ipsrc']
                #               ]
                #}
            }
            master::nagios_check { '10_IPMI': }
        }
        default: { notice('ipmitool not configured for virtual systems') }
    }
}
