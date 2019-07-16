#
# class master::user::x11
# =======================
#
# End-user packages related to X11
#
# This does not include even the core X11 fonts, so if you are not
# using a font server, you need to also include master::user::fonts
#

class master::user::x11 (
    $x0hosts = false,
    $x1hosts = false
)
{
    case $::osfamily {
        'Debian': {
            $packages =
            [ 'libxt6',
              'libxtst6',
              'mesa-utils',
              'pterm',
              'x11-apps',
              'x11-session-utils',
              'x11-utils',
              'x11-xfs-utils',
              'x11-xkb-utils',
              'x11-xserver-utils',
              'xauth',
              'xbase-clients',
              'xfonts-base',
              'xinit',
              'xterm',
              'xutils-dev',
            ]
        }
        'RedHat': {
            $packages =
            [ 'glx-utils',
              'imake',
              'libXt',
              'libXtst',
              'xorg-x11-apps',
              'xorg-x11-drv-vmmouse',
              'xorg-x11-drv-vmware',
              'xorg-x11-font-utils',
              'xorg-x11-server-utils',
              'xorg-x11-server-Xorg',
              'xorg-x11-utils',
              'xorg-x11-xauth',
              'xorg-x11-xinit',
              'xorg-x11-xkb-utils',
              'xterm',
            ]
            if versioncmp($::operatingsystemrelease, '7.0') < 0 {
                package { 'putty': }
                package { "xorg-x11-resutils": }
            }
        }
        default: {
            $packages = [ ]
        }
    }
    ensure_packages($packages)

    file { "/etc/X11":
        ensure => directory,
        owner => 'root', group => 'root', mode => '0755'
    }

    Templatelayer { module => "master" }
    templatelayer { "/etc/X0.hosts": }
    templatelayer { "/etc/X1.hosts": }
    nodefile { '/etc/X11/xorg.conf': defaultensure => ignore }
}
