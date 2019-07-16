class master::util::timeoutd {
  package { "timeoutd": ensure => latest }

  templatelayer { "/etc/timeouts": }

  templatelayer { "/etc/cron.d/timeoutd":
    mode => '0600', owner => 'root', group => 'root'
  }
  service { "timeoutd": ensure => running }
  master::nagios_check { '20_Proc_timeoutd': }
}
