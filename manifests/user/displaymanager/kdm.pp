#
# class master::user::displaymanager::kdm
# =======================================
#
# Installs the KDE display manager
# Do not use this class with any other user::displaymanager:* class
#

class master::user::displaymanager::kdm (
    # Parameters
    # ----------

    # ### banner
    # What file to display as a banner via xmessage?
    $banner = '/etc/issue',

    # ### xhost
    # Should kdm start X with an allowed xhost entry?
    $xhost = false,

    # ### xsetup_templates
    # Template fragments to place at the top of Xsetup_0
    $xsetup_templates = [ ]
)
{
    Class['master::user::x11'] -> Class[$name]

    package { 'kdm': ensure => latest }
    package { 'gdm': ensure => absent }
    package { 'xdm': ensure => absent }

    case $::osfamily {
        'RedHat': {
            $kdedir = '/etc/kde'

            # CentOS KDM actually makes use of Xsetup from XDM
            templatelayer { '/etc/X11/xdm/Xsetup_0':
                require => Package['kdm'],
                suffix  => $::osfamily,
            }
            file { "/etc/kde/kdm/Xsetup":
                ensure => link,
                target => '../../X11/xdm/Xsetup_0',
            }
        }
        'Debian': {
            $kdedir = '/etc/kde4'
            templatelayer { "${kdedir}/kdm/Xsetup":
                owner => root, group => root, mode => '0755',
                require => File["${kdedir}/kdm"],
            }
        }
        default: {
            $kdedir = '/etc/kde'
            templatelayer { "${kdedir}/kdm/Xsetup":
                owner => root, group => root, mode => '0755',
                require => File["${kdedir}/kdm"],
            }
        }
    }

    file { $kdedir:
        ensure => directory,
        owner => root, group => root, mode => '0755'
    }
    file { "${kdedir}/kdm":
        ensure => directory,
        owner => root, group => root, mode => '0755',
        require => File[$kdedir]
    }
    templatelayer { "${kdedir}/kdm/kdmrc":
        require => File["${kdedir}/kdm"],
        suffix => $::osfamily,
    }
}
