#
# master::nagios_check
#
# This is a shortcut helper define to create a virtual templatelayer
# resource for a file in /usr/share/nagios-client/client.d tagged as
# 'nagios-client.d' that can be used in any class in any module, but
# will be activated by a separate Nagios client class later.
#
# Using this define on its own does not cause anything to happen on a
# system.  It is entirely virtual.  It still does require that the
# specified file exist underneath /usr/share/nagios-client/client.d/
# in the templates area of the calling module.
#
# Additional parameters can be passed to these templates via the
# $parameters hash.
#

define master::nagios_check (
  $owner       = 'root',
  $group       = 'root',
  $mode        = '0400',
  $module      = $caller_module_name,
  $parameters  = { },
  $templatedir = '/usr/share/nagios-client/client.d'
)
{
  @templatelayer { "${templatedir}/${title}":
    owner   => $owner,
    group   => $group,
    mode    => $mode,
    module  => $module,
    require => File['/usr/share/nagios-client/client.d'],
    tag     => 'nagios-client.d',
  }
}
