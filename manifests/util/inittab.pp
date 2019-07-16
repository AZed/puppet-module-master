class master::util::inittab {
  Class['master::common::base'] -> Class[$name]

  exec { "/sbin/telinit Q":
    path        => [ "/sbin" ],
    refreshonly => true,
    require     => Templatelayer['/etc/inittab'],
    subscribe   => Templatelayer['/etc/inittab']
  }
  exec { "/usr/bin/killall getty":
    path        => [ "/usr/bin" ],
    refreshonly => true,
    require     => [ Templatelayer['/etc/inittab'],
                     Exec["/sbin/telinit Q"]
                     ],
    subscribe   => Templatelayer['/etc/inittab']
  }
}
