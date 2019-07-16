#
# class master::service::apache::modsecurity
#
# Enables modsecurity on the Apache server.
#
# Using this class requires correctly configuring
# master::service::apache in the same node.
#
class master::service::apache::qos (
)
{
  include master::service::apache

  apache2_install_module { "qos": }
  apache2_enable_module { "qos":}

  templatelayer { '/etc/apache2/mods-available/qos.load':
  }

  templatelayer { '/etc/apache2/mods-available/qos.conf':
  }

}
