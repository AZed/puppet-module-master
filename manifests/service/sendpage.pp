#
# class service::sendpage
#
# This automatically upgrades the sendpage packages and installs a
# configuration file that allows pages to be sent.
#
# More complex configurations will require a template
#

class master::service::sendpage {
  package { [ "sendpage-server", "minicom",
              "sendpage-common", "sendpage-client" ]:
                ensure => latest,
  }

  file { "/etc/sendpage": ensure => directory,
    owner => 'root', group => 'root', mode => '0755',
  }

  file { "/var/spool/sendpage": ensure => directory,
    owner => 'daemon', group => 'root', mode => '0700',
  }

  templatelayer { "/etc/sendpage/sendpage.cf":
    owner => 'root', group => 'root', mode => '0444',
    require => File["/etc/sendpage"]
  }
  
  file { "/etc/minicom": ensure => directory,
    owner => 'root', group => 'root', mode => '0755',
  }

  templatelayer { "/etc/minicom/minicom.users":
    owner => 'root', group => 'root', mode => '0444',
    require => File["/etc/sendpage"]
  }

  templatelayer { "/etc/minicom/minirc.dfl":
    owner => 'root', group => 'root', mode => '0444',
    require => File["/etc/sendpage"]
  }

  templatelayer { "/etc/sendpage/email2page.conf":
    owner => 'root', group => 'root', mode => '0444',
    require => File["/etc/sendpage"]
  }

  templatelayer { "/etc/sendpage/snpp.conf":
    owner => 'root', group => 'root', mode => '0444',
    require => File["/etc/sendpage"]
  }

  master::nagios_check { '20_Proc_sendpage': }
}
