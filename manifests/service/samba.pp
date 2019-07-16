class master::service::samba {
  package { "samba": ensure => installed }

  templatelayer { "/etc/samba/smb.conf":
    owner => root, group => root, mode => '0444',
    notify => Exec["samba-restart"]
  }

  exec { "samba-restart":
    command     => "/etc/init.d/samba restart",
    path        => "/bin:/usr/bin:/usr/sbin",
    refreshonly => true,
    require     => [ Package["samba"],
                     Templatelayer["/etc/samba/smb.conf"]
                   ]
  }

  
}
