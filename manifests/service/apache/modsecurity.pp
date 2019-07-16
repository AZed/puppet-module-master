#
# class master::service::apache::modsecurity
#
# Enables modsecurity on the Apache server.
#
# Using this class requires correctly configuring
# master::service::apache in the same node.
#
#Notes:
# Don't change modsec_default_action unless you know your site really well.
# Then still don't do it.
#
# modsec_auditlog_format can be Native or JSON. modsecurity will need to be linked wih yajl to work.
# 
# modsec_auditlog_type can be Serial or Concurrent. Serial is a single log file, one event at a time. 
# Concurrent uses a multiple file structure.
#
# modsec_auditlog_storagedir needs to be defined and have permissions for Concurrent. Otherwise, no logs.
#
# you will probably want to install the OWASP core ruleset in addition.
#
class master::service::apache::modsecurity (
    $modsec_default_action = "DetectionOnly",
    $modsec_log_directory = "/var/log/httpd/",
    $modsec_auditlog_format = "Native",
    $modsec_auditlog_type = "Serial",
    $modsec_auditlog_storagedir = "/var/log/httpd/audit",
)
{
  include master::service::apache

  apache2_install_module { "security": }
  apache2_enable_module { "security":
    require => Class["master::service::apache::packages"]
  }

  file { "/etc/modsecurity":
    ensure => directory,
    owner  => root,
    group  => "root",
    mode   => '0755',
  }

  file { $modsec_auditlog_storagedir:
    ensure => directory,
    owner  => apache,
    group  => "root",
    mode   => '0755',
  }

  templatelayer { "/etc/modsecurity/modsecurity.conf":
    owner  => root,
    group  => "root",
    mode   => '0755',
    suffix => $::operatingsystem, 
    require => File["/etc/modsecurity"]
  }

  file { "/etc/httpd/conf.d/mod_security.conf":
    ensure => absent
  }

  templatelayer { "/etc/modsecurity/unicode.mapping":
    owner   => root,
    group   => "root",
    mode    => '0755',
    require => File["/etc/modsecurity"]
  }

  templatelayer { '/etc/apache2/mods-available/security.load':
  }
  templatelayer { '/etc/apache2/mods-available/security.conf':
  }

  if ( $::selinux ) {
        include master::common::selinux
        selinux_enable_module {"modsecurity-apachelog": }
    }
}
