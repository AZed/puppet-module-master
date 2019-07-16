#
# master::user::displaymanager::kdm
#
# Installs the basic X display manager
# Do not use this class with any other user::displaymanager:* class
#
# XDM configuration is incomplete -- this will just install the package
#

class master::user::displaymanager::xdm (
  # Should xdm start X with an allowed xhost entry?
  # (not currently used)
  $xhost = false
)
{
  Class['master::user::x11'] -> Class[$name]

  package { 'xdm': ensure => latest }
  package { 'gdm': ensure => absent }
  package { 'kdm': ensure => absent }
}
