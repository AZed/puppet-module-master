# Make sure that /etc/services has the following entries:
#   nuttcp          5000/tcp
#   nuttcp-data     5001/tcp
#   nuttcp6         5000/tcp
#   nuttcp6-data    5001/tcp
#
################################################################
class master::service::nuttcp (
    $nuttcp_disable = "yes",
)
{
  include master::service::xinetd

  package { "nuttcp": 
    ensure  => installed
  }

  templatelayer { "/etc/xinetd.d/nuttcp": 
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => [ Package["nuttcp"],
                 Package["xinetd"]
               ]
  }

  exec { "/etc/init.d/xinetd reload":
    path        => [ "/bin", "/usr/bin" ],
    refreshonly => true,
    require     => [ Package["xinetd"],
                     Package["nuttcp"],
                     Templatelayer["/etc/xinetd.d/nuttcp"],
                     Templatelayer["/etc/services"]
                   ]
  }
}
