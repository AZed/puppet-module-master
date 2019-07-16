#
# class master::service::apache::modsecurity
#
# Enables modsecurity on the Apache server.
#
# Using this class requires correctly configuring
# master::service::apache in the same node.
#
class master::service::apache::proxy_wstunnel (
)
{
  include master::service::apache

  #apache2_install_module { "proxy_wstunnel": }

  templatelayer { '/etc/apache2/mods-available/proxy_wstunnel.load':
  }
}
