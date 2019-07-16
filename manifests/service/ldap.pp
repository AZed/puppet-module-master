#
# class master::service::ldap
#
# Set up an LDAP server
#

class master::service::ldap (
    $syncpass = false,
    $ldap_sync_id = false,
    $ldap_sync_provider = false,
    $ldap_admins  = [],
)
{
    Class['master::client::ldap'] -> Class[$name]
    Class['master::common::package_management'] -> Class[$name]

        case $::operatingsystem {
            'debian': {
                package { 'slapd':
                           name => 'slapd',
                           ensure => installed,
                }
                if versioncmp($::operatingsystemrelease, '7.0') < 0 {
                    package { 'db4-util': 
                              name   => 'db4.2-util',
                              ensure => installed, }
                }
                elsif versioncmp($::operatingsystemrelease, '8.0') < 0 {
                    package { 'db4-util': ensure => installed }
                }
            }
            'centos': { 
                package { 'slapd': name => 'openldap-servers', ensure => installed }
                if versioncmp($::operatingsystemrelease, '7.0') < 0 {
                    package { 'db4-util': 
                              name => 'db4-utils',
                              ensure => installed, }
                }
                elsif versioncmp($::operatingsystemrelease, '8.0') < 0 {
                    package { 'db4-util': name => 'libdb4-utils', ensure => installed }
                }
            }
            default: {}
               
        }

    $ldap_server_group = $::operatingsystem ? {
        'centos' => 'ldap',
        'debian' => 'openldap',
        default  => 'openldap',
    }

    $ldap_server_user = $::operatingsystem ? {
        'centos' => 'ldap',
        'debian' => 'openldap',
        default  => 'openldap',
    }

    $ldap_server_cert_group = $::operatingsystem ? {
        'centos' => 'root',
        'debian' => 'ssl-cert',
        default  => 'root',
    }

    $ldap_server_user_groups = $::operatingsystem ? {
        'centos' => $ldap_server_group,
        'debian' => [
            $ldap_server_group,
            $ldap_server_cert_group,
        ],
        default  => $ldap_server_group,
    }

    # Ensure the openldap group exists
    group { $ldap_server_group:
        ensure  => present,
        require => Package['slapd'],
    }

    # Ensure the openldap user is in the ssl-cert group
    user { $ldap_server_user:
        groups  => $ldap_server_user_groups,
        require => Group[$ldap_server_group],
    }

    # Copy in the slapd configuration
    templatelayer { "/etc/ldap/slapd.conf":
        owner         => "root",
        group         => $ldap_server_group,
        mode          => '0640',
        parsenodefile => true,
        require       => Package['slapd'],
        notify        => Service["slapd"],
    }

    # Copy in the check_password configuration
    templatelayer { "/etc/ldap/check_password.conf":
        owner   => "root",
        group   => $ldap_server_group,
        mode    => '0640',
        require => Package["slapd"],
    }

    # Copy in the service defaults
    if $::operatingsystem == 'debian' {
      templatelayer { "/etc/default/slapd":
          owner   => root,
          group   => $ldap_server_group,
          mode    => '0640',
          notify  => Service["slapd"],
          require => Package['slapd'],
      }
    }

    if $::operatingsystem == 'centos' {
      templatelayer { "/etc/sysconfig/slapd":
          alias   => '/etc/default/slapd',
          owner   => root,
          group   => $ldap_server_group,
          mode    => '0640',
          notify  => Service["slapd"],
          require => Package['slapd'],
      }
    }

    # Ensure the log directory exists
    file { "/var/log/slapd":
        ensure  => directory,
        owner   => $ldap_server_user,
        group   => $ldap_server_group,
        mode    => '0637',
        recurse => false,
        require => Package['slapd'],
    }

    # Copy in the logrotation rules
    templatelayer { "/etc/logrotate.d/slapd":
        mode    => '0444',
        require => File["/var/log/slapd"]
    }

    # Ensure that directory ownership & permissions are correct
    file { "/var/lib/ldap":
        ensure  => directory,
        owner   => $ldap_server_user,
        group   => $ldap_server_group,
        mode    => '0640',
        recurse => true,
        require => Package['slapd'],
    }

    # Copy in any additional schemas
    file { "/etc/ldap/schema":
        ensure  => directory,
        source  => "puppet:///modules/master/etc/ldap/schema",
        owner   => root,
        group   => $ldap_server_group,
        mode    => '0640',
        recurse => true,
        notify  => Service["slapd"],
        require => Package['slapd'],
    }

    # Copy the script to backup the ldap database
    nodefile { "/usr/local/sbin/backup-ldap-database.sh":
        owner   => root,
        group   => root,
        mode    => '0700',
    }

    # Copy the script to create the ldap database directories
    file { "/usr/local/sbin/create-ldap-directories.sh":
        source  => "puppet:///modules/master/usr/local/sbin/create-ldap-directories.sh",
        owner   => root,
        group   => root,
        mode    => '0700',
    }

    # Running this script ensures that LDAP database directories exist
    exec { "/usr/local/sbin/create-ldap-directories.sh":
        path    => [ "/bin", "/usr/bin" ],
        require => [
            File["/usr/local/sbin/create-ldap-directories.sh"],
            Templatelayer["/etc/ldap/slapd.conf"],
        ],
    }

    # Copy the cron jobs for ldap
    templatelayer { "/etc/cron.d/ldap":
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        require => File["/usr/local/sbin/backup-ldap-database.sh"]
    }


    # systemd overrides for centos7 
    if $::operatingsystem == 'centos' {
       if versioncmp($::operatingsystemrelease, '8.0') < 0 { 
           templatelayer { "/etc/systemd/system/slapd.service":
              notify => Exec['/usr/bin/systemctl daemon-reload'],
           }
           exec { "/usr/bin/systemctl daemon-reload":
             refreshonly   => true,
             require       => Package['slapd'],
             notify        => Service["slapd"],
           }
       }
    }

    # ensure permissions on centos.
    if $::operatingsystem == 'centos' {
       nodefile { "/etc/ssl/certs/${::fqdn}.cert":
        owner   => $ldap_server_user,
        group   => root,
        mode    => '0644',
       }
    

       nodefile { "/etc/pki/tls/private/${::fqdn}.key":
        owner   => $ldap_server_user,
        group   => $ldap_server_cert_group,
        mode    => '0640',
       }

       file { "/etc/pki/tls/certs/ldap.nccs.nasa.gov.cert":
          ensure => "/etc/pki/tls/certs/${::fqdn}.cert",
       }

       file { "/etc/ssl/private/${::fqdn}.key":
          ensure => "/etc/pki/tls/private/${::fqdn}.key",
       }

       file { "/etc/pki/tls/private/ldap.nccs.nasa.gov.key":
          ensure => "/etc/pki/tls/private/${::fqdn}.key",
       }
    }
    elsif $::operatingsystem == 'debian' { 
       # Copy in our certificate
       nodefile { "/etc/ssl/certs/${::fqdn}.cert":
           owner   => $ldap_server_user,
           group   => root,
           mode    => '0644',
       }

       # Copy in our certificate key
       nodefile { "/etc/ssl/private/${::fqdn}.key":
           owner   => $ldap_server_user,
           group   => $ldap_server_cert_group,
           mode    => '0640',
       }
    }
    file { '/etc/ldap/slapd.d':
	ensure  => absent,
	force   => true,
	notify  => Service['slapd'],
    }

    # Start|Restart the slapd service
    service { "slapd":
        ensure  => true,
        enable  => true,
        require => [
            Templatelayer["/etc/ldap/slapd.conf"],
            File["/etc/ldap/schema"],
            Templatelayer["/etc/default/slapd"],
            File["/var/lib/ldap"],
            File["/etc/ssl/certs/$fqdn.cert"],
            File["/etc/ssl/private/$fqdn.key"],
            Package['slapd'],
        ]
    }
}
