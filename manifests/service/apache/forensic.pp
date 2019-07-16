#
# class master::service::apache::forensic
#
# Enables forensic logging on the Apache server.
#
# Using this class requires correctly configuring
# master::service::apache in the same node.
#
class master::service::apache::forensic {
  apache2_enable_module { "log_forensic":
    require => Class["master::service::apache::packages"]
  }

  file { "/var/log/apache2":
    ensure => directory,
    owner  => 'root',
    group  => 'adm',
    mode   => '0750',
  }

  file { "/var/log/apache2/forensic":
    ensure  => directory,
    owner   => 'root',
    group   => 'adm',
    mode    => '0750',
    require => File["/var/log/apache2"]
  }

  templatelayer { "/etc/apache2/conf.d/log_forensic": 
    require => File["/etc/apache2/conf.d",
                    "/var/log/apache2/forensic"],
  }

  templatelayer { "/etc/logrotate.d/apache-forensic": }
}
