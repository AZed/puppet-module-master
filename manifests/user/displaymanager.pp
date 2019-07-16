#
# master::user::displaymanager
#
# Installs a display manager (gdm/kdm/xdm)
# Defaults to kdm
#

class master::user::displaymanager (
  $displaymanager = 'kdm',

  # Should gdm start X with an allowed xhost entry?
  $xhost = false,

  # X server arguments for local sessions
  # (Currently only valid for KDM)
  # Default is to not listen for TCP connections and disable test extensions
  $xserverargslocal = '-nolisten tcp -tst',

  # Template fragments to place at the top of Xsetup
  # (currently only valid for kdm)
  $xsetup_templates = [ ],
)
{
  Class['master::user::x11'] -> Class[$name]

  templatelayer { '/etc/X11/default-display-manager':
    require => File['/etc/X11']
  }


  case $displaymanager {
    gdm: {
      class { 'master::user::displaymanager::gdm':
        xhost => $xhost,
      }
    }
    gdm3: {
      class { 'master::user::displaymanager::gdm3':
        xhost => $xhost,
      }
    }
    kdm: {
      class { 'master::user::displaymanager::kdm':
        xhost            => $xhost,
        xsetup_templates => $xsetup_templates,
      }
    }
    xdm: {
      class { 'master::user::displayamanger::xdm':
        xhost => $xhost,
      }
    }
    default: {
      fail("I don't know how to manage display manager ${displaymanager}!")
    }
  }
}
