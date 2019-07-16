class master::service::dhttpd {
  package { "dhttpd": ensure => present }

  templatelayer { "/etc/default/dhttpd": notify => Service["dhttpd"] }

  service { "dhttpd": ensure => running }
}
