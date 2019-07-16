class master::service::ntop {
  package {"ntop": ensure => present }

  templatelayer {"/etc/default/ntop": 
    notify => Service["ntop"],
  }
  
  nodefile { "/etc/apache2/conf.d/ntop.conf":
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File["/etc/apache2/conf.d"],
    notify  => Exec["apache2-graceful"]
  }

  # Set the NTop admin password
  if $ntop_admin_pw {
    exec { "set-ntop-admin-password":
      path    => [ "/usr/sbin" ],
      command => "/usr/sbin/ntop -A --set-admin-password=$ntop_admin_pw",
      require => Package["ntop"],
    }
  }

  # Reload the service if the configuration changed
  service { "ntop":
    ensure  => running,
    require => [ Templatelayer["/etc/default/ntop"],
                 Package["ntop"]
               ]
  }
}
