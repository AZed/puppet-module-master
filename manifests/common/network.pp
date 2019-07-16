#
# class master::common::network
# =============================
#
# Set up the base networking environment
#

class master::common::network (
    # Parameters
    # ----------
    #
    # ### interfaces
    # This can be fed a hash of master::network_config resources via
    # the interfaces parameter as follows:
    #   interfaces => {
    #     eth0 => {
    #       template => 'module/path/to/template'
    #     }
    #   }
    #
    # Or in YAML:
    #   master::common::network::interfaces:
    #     eth0:
    #       template: 'module/path/to/template'
    #
    # Or for some very common cases:
    #   master::common::network::interfaces:
    #     eth0:
    #       suffix: "%{::fqdn}"
    #     eth1:
    #       config:
    #         address: '192.168.1.10'
    #
    # If the template/suffix arguments are left blank, then it will
    # default to a nodefile of the OS-appropriate default location for
    # that network interface configuration.
    #
    # If $interfaces is set to false (the default), then no attempt to
    # manage network interfaces will be made at all.
    #
    # If this is set to true, but is not a hash, then standard
    # nodefiles will be searched for and used if found:
    #
    # Debian:
    #   /etc/network/interfaces
    #   /etc/network/interfaces.d/eth0
    #   /etc/network/interfaces.d/eth1
    # CentOS/RedHat:
    #   /etc/sysconfig/network-scripts/ifcfg-eth0
    #   /etc/sysconfig/network-scripts/ifcfg-eth1
    # SLES:
    #   /etc/sysconfig/network/ifcfg-eth0
    #   /etc/sysconfig/network/ifcfg-eth1
    $interfaces = false,

    # ### prefer_ipv4
    # Prefer IPv4 connections over IPv6?
    $prefer_ipv4 = true,

    # ### resolv_conf
    # This can be a hash such as:
    #   master::common::network::resolv_conf:
    #     domain: 'mydomain'
    #     search: 'mysearch'
    #     nameservers:
    #       - 'nameserver1'
    #       - 'nameserver2'
    #       - 'nameserver3'
    # If left false, /etc/resolv.conf will be unmanaged
    $resolv_conf = false,

    # ### routes
    # Configurations of static routes on RedHat and SuSE-based systems
    #
    # This parameter is ignored on Debian-based systems.  Use up and
    # down config parameters to the interfaces instead.
    #
    # The format of this parameter is a hash of master::route_config
    # resources, where the top level keys are names of files in
    # /etc/network/sysconfig and below that are the parameters for the
    # line or temlate fragment arrays.
    #
    # RedHat example:
    #
    #     master::common::network::routes:
    #       route-eth0:
    #         templates:
    #           - 'mymodule/route-10-0.erb'
    #         lines:
    #           - 'GATEWAY1=10.164.234.112'
    #           - 'NETMASK1= 255.255.255.240'
    #           - 'ADDRESS1=10.164.234.132'
    #
    # Example for SuSE setting default route:
    #
    #     master::common::network::routes:
    #       routes:
    #         lines:
    #           - 'default 10.10.1.1'
    #
    $routes = false,

){
    # Code
    # ----
    #
    # /etc/gai.conf (configuration for getaddrinfo, where prefer_ipv4
    # is used) is managed the same way on all systems
    #
    templatelayer { '/etc/gai.conf': }

    if $resolv_conf {
        templatelayer { '/etc/resolv.conf': }
    }

    case $::operatingsystem {
        'Debian','Ubuntu': {
            Templatelayer { notify => Exec['ifupall'], }

            package { 'bridge-utils': }
            package { 'hostname': }
            package { 'ifupdown': }
            package { 'iproute': }
            package { 'isc-dhcp-client': }

            if versioncmp($::operatingsystemrelease, '8.0') >= 0 {
                package { 'ifupdown-multi': }
            }

            file { '/etc/network/interfaces.d':
                ensure  => directory,
                purge   => true,
                recurse => true,
            }
            if $interfaces {
                if is_hash($interfaces) {
                    create_resources(master::network_config,$interfaces)
                    templatelayer { '/etc/default/ifupdown': }
                    templatelayer { '/etc/network/interfaces': }
                }
                else {
                    templatelayer { '/etc/default/ifupdown': }
                    templatelayer { '/etc/network/interfaces': }
                    nodefile { '/etc/network/interfaces.d/eth0': defaultensure => 'ignore' }
                    nodefile { '/etc/network/interfaces.d/eth1': defaultensure => 'ignore' }
                }
            }
            if $routes and is_hash($routes) {
                create_resources(master::route_config,$routes)
            }
            exec { 'ifupall':
                command     => 'ifup -a',
                cwd         => '/etc/network',
                path        => '/sbin:/usr/sbin:/bin:/usr/bin',
                refreshonly => true,
            }
        }
        'CentOS','RedHat': {
            package { 'dhclient': }
            package { 'iproute': }

            templatelayer { '/etc/default/ifupdown': }

            file { '/etc/sysconfig/network-scripts': ensure => directory }

            if $interfaces {
                templatelayer { '/etc/sysconfig/network':
                    suffix => 'CentOS',
                }

                if is_hash($interfaces) {
                    create_resources(master::network_config,$interfaces)
                }
                else {
                    nodefile { '/etc/sysconfig/network-scripts/ifcfg-eth0':
                        parsenodefile => true,
                        defaultensure => ignore
                    }
                    nodefile { '/etc/sysconfig/network-scripts/ifcfg-eth1':
                        parsenodefile => true,
                        defaultensure => ignore
                    }
                }
            }
        }
        'Suse','SLES': {
            if $interfaces {
                if is_hash($interfaces) {
                    create_resources(master::network_config,$interfaces)
                }
                else {
                    nodefile { '/etc/sysconfig/network/ifcfg-eth0':
                        parsenodefile => true, defaultensure => ignore
                    }
                    templatelayer { '/etc/sysconfig/network/config': }
                }
            }
        }
        default: {
            if $interfaces {
                notify { "${name}-default-netconfig":
                    message  => "WARNING: puppet-generated network configuration not available on ${::operatingsystem}.",
                    loglevel => warning,
                }
            }
        }
    }
}
