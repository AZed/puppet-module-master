class master::util::apache_syslog {
  include master::service::apache

  file { "/usr/local/bin/apache2_syslog":
    owner  => 'root', group => 'root', mode => '0755',
    source => "puppet:///modules/master/usr/local/bin/apache2_syslog"
  }

  templatelayer { "/etc/apache2/conf.d/log_syslog":
    owner   => 'root', group => 'root', mode => '0444',
    require => File["/usr/local/bin/apache2_syslog"],
    notify  => Exec["apache2-graceful"]
  }
}
