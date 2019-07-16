class master::util::iptables {
  ### This is a work-in-progress ... YOU HAVE BEEN WARNED!!!

  ### Include the following in your sysctl.conf if you want
  ### to stop iptables and printk from logging things to the
  ### console.  This is why the Exec["/sbin/sysctl..."] below.
  ###    kernel.printk = 3 4 1 7
  ###

  #####################
  ### IPv4 IPTABLES ###
  #####################

  $custom_iptables_conf = nodefile_exists("/etc/iptables.conf-${::fqdn}")
  $custom_ip6tables_conf = nodefile_exists("/etc/ip6tables.conf-${::fqdn}")
  
  case $operatingsystem {
      'debian','ubuntu': {
       # BEGIN: debian block
           #BEGIN debian iptables block
           # Determine if there is a FQDN specific file
           if $custom_iptables_conf {
               file { "/etc/iptables.conf":
                   name    => "/etc/iptables.conf",
                   owner   => "root",
                   group   => "root",
                   mode    => '0400',
                   content => template("nodefiles/${::fqdn}/etc/iptables.conf-${::fqdn}"),
                   notify => Exec['/etc/network/if-up.d/iptables'],
               }
           } else {
                 templatelayer { "/etc/iptables.conf":
                     parsenodefile => true,
                     owner  => root,
                     group  => root,
                     mode   => '0400',
                     notify => Exec['/etc/network/if-up.d/iptables'],
                 }
           }

           # Copy the script to make iptables persistent
           file { "/etc/network/if-up.d/iptables":
               owner  => root,
               group  => root,
               mode   => '0700',
               source => "puppet:///modules/master/etc/network/if-up.d/iptables",
           }

           # Reload iptables only if the rules have changed 
           exec { "/etc/network/if-up.d/iptables":
               refreshonly => true,
               require     => [ File["/etc/iptables.conf"],
                                File["/etc/network/if-up.d/iptables"],
                                Exec["/sbin/sysctl -p /etc/sysctl.conf"]
                              ]
           }
           # END debian iptables block
           # BEGIN debian ip6tables block
           if $custom_ip6tables_conf {
               file { "/etc/ip6tables.conf":
                   name    => "/etc/ip6tables.conf",
                   owner   => "root",
                   group   => "root",
                   mode    => '0400',
                   content => template("nodefiles/${::fqdn}/etc/ip6tables.conf-${::fqdn}"),
                   notify => Exec['/etc/network/if-up.d/ip6tables'],
               }
           } else {
                 templatelayer { "/etc/ip6tables.conf":
                     parsenodefile => true,
                     owner  => root,
                     group  => root,
                     mode   => '0400',
                     notify => Exec['/etc/network/if-up.d/ip6tables'],
                 }
           }

           # Copy the script to make ip6tables persistent
           file { "/etc/network/if-up.d/ip6tables":
               owner  => root,
               group  => root,
               mode   => '0700',
               source => "puppet:///modules/master/etc/network/if-up.d/ip6tables",
           }

           # Reload ip6tables only if the rules have changed
           exec { "/etc/network/if-up.d/ip6tables":
               refreshonly => true,
               require     => [ File["/etc/ip6tables.conf"],
                                File["/etc/network/if-up.d/ip6tables"],
                                Exec["/sbin/sysctl -p /etc/sysctl.conf"]
                              ]
           }
           # END debian ip6tables block
      # END debian block
      }

      'centos','redhat': {
      # START centos/RHEL block
           # START centos iptables block
           if versioncmp($operatingsystemrelease, '7.0') >= 0 { 
               service { "firewalld":
                   ensure => stopped,
                   enable => false
               }
               package { "firewalld":
                   ensure => absent }
               package { "iptables-services":
                    ensure => latest }
           }
           if $custom_iptables_conf {
               file { "/etc/sysconfig/iptables":
                   name    => "/etc/sysconfig/iptables",
                   owner   => "root",
                   group   => "root",
                   mode    => '0400',
                   content => template("nodefiles/${::fqdn}/etc/iptables.conf-${::fqdn}"),
                   notify => Service['iptables'],
               }
           } else {
                 templatelayer { "/etc/sysconfig/iptables":
                     parsenodefile => true,
                     owner  => root,
                     group  => root,
                     mode   => '0400',
                     notify => Service['iptables'],
                 }
           }
            service { 'iptables':
                ensure => running,
                enable => true,
                require => File['/etc/sysconfig/iptables'],
            }
        # END centos iptables block
        # START centos ip6tables block
        if $custom_ip6tables_conf {
               file { "/etc/sysconfig/ip6tables":
                   name    => "/etc/sysconfig/ip6tables",
                   owner   => "root",
                   group   => "root",
                   mode    => '0400',
                   content => template("nodefiles/${::fqdn}/etc/ip6tables.conf-${::fqdn}"),
                   notify => Service['ip6tables'],
               }
           } else {
                 templatelayer { "/etc/sysconfig/ip6tables":
                     parsenodefile => true,
                     owner  => root,
                     group  => root,
                     mode   => '0400',
                     notify => Service['ip6tables'],
                 }
           }
            service { 'ip6tables':
                ensure => running,
                require => File['/etc/sysconfig/ip6tables'],
            }
        }
        # END centos ip6tables

    }
    # END centos/RHEL
# END case
}
