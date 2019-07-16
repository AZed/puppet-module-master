#
# class master::service::squid
#
# Use this class if a Squid Proxy Server is needed
#
# If the proxy server will need to use RADIUS authentication via PAM,
# use master::service::squid::radius instead (see below)
#

class master::service::squid {
  Package { ensure => installed }
  Service {
    ensure     => running,
    hasrestart => true,
  }

  case $::operatingsystem {
    'centos','redhat': {
      package { 'squid': }
      service { 'squid': }
    }
    'debian': {
      package { 'squid3': alias => 'squid' }
      package { 'squid3-common': }
      package { 'squidclient': }
      service { 'squid3': alias => 'squid' }
    }
    default: {
      package { 'squid': }
    }
  }

  # Squid helper files
  file { '/usr/lib/squid3':
    ensure => directory,
    owner => 'root', group => 'root', mode => '0755',
    recurse => true
  }

 
  case $::operatingsystem {
    'centos','redhat': {
        master::nagios_check { '20_Proc_squid': }
        nodefile { '/etc/squid/squid.conf':
          owner         => 'root',
          group         => 'root',
          mode          => '0400',
          notify        => Service['squid'],
          require       => Package['squid'],  # Creates /etc/squid3 directory
        }
    }
    'debian': {
        master::nagios_check { '20_Proc_squid3': }
        nodefile { '/etc/squid3/squid.conf':
          owner         => 'root',
          group         => 'root',
          mode          => '0400',
          defaultensure => 'ignore',
          notify        => Service['squid'],
          require       => Package['squid'],  # Creates /etc/squid3 directory
        }
    }
  } 

  if ( $::selinux ) {
        include master::common::selinux
        selinux_enable_module {"squid-selinux": }
    }
  

}


#
# class master::service::squid::radius
#
# Squid RADIUS authentication via PAM requires that the pam_auth
# helper be setuid root to be able to access the RADIUS shared secret.
#

class master::service::squid::radius inherits master::service::squid {
  file { '/usr/lib/squid3/pam_auth':
    owner => 'root', group => 'root', mode => '4755',
    require => Package['squid'],
    notify => Service['squid']
  }
}
