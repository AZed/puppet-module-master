#
# class master::user::desktop::gnome
# ==================================
#
# Basic Desktop Environment for Gnome
#
# This does *NOT* include a display manager (kdm/gdm)
#

class master::user::desktop::gnome {
    include master::user::desktop
    Class['master::user::x11'] -> Class[$name]

    Package { ensure => latest }

    package {
        [
         'gnome-session',
         ]:
    }

    case $::operatingsystem {
        'centos','redhat': {
            package {
                [
                 'gnome-desktop',
                 ]:
            }
        }
        'debian': {
            package {
                [
                 'gnome',
                 'gnome-session',
                 ]:
            }
        }
        default: { }
    }
}
