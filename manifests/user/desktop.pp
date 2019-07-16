#
# master::user::desktop
#
# Basic Desktop Environments
#
# This does *NOT* include a display manager (kdm/gdm)
#
# Gnome has also been separated into master::user::desktop::gnome due
# to compatibility issues with 3rd-party software.
#
#

class master::user::desktop {
    include master::user::fonts
    include master::user::web
    Class['master::user::x11'] -> Class[$name]

    Package { ensure => latest }

    # Some packages may have been pulled in by dependencies, but should
    # be enforced as absent.
    #
    # Note that including user::desktop at the same time as
    # service::apache or dev::perl::catalyst will break.
    $user_desktop_blocked =
    [
     'apache2',
     'apache2-mpm-prefork',
     'apache2-utils',
     'libapache2-reload-perl',
     'network-manager',
     'php-xajax',
     'ktalkd',
     'talk',
     'ytalk',
     ]
    package { $user_desktop_blocked: ensure => absent, }

    package {
        [
         'gedit',
         'gv',
         'icewm',
         'pidgin',
         'xdg-utils',
         ]:
            before => Package[$user_desktop_blocked],
    }

    case $::operatingsystem {
        'centos','redhat': {
            package {
                [
                 'kdemultimedia',
                 'kdepim',
                 'kdeutils',
                 'pidgin-otr',
                 'xfce4-panel',
                 'xfce4-session',
                 'xfce4-settings',
                 'xfwm4',
                 ]:
                    before => Package[$user_desktop_blocked],
            }
        }
        'debian': {
            package {
                [
                 'grpn',
                 'kde-standard',
                 'kde-full',
                 'kterm',
                 'okular-extra-backends',
                 'pidgin-otr',
                 'xfce4',
                 'xfwm4',
                 'xfwm4-themes',
                 'xvkbd',
                 ]:
                    before => Package[$user_desktop_blocked],
            }
        }
        default: { }
    }
}
