#
# master::user::displaymanager::gdm
# =================================
#
# Installs the Gnome display manager
# Do not use this class with any other user::displaymanager:* class
#

class master::user::displaymanager::gdm (
    # What file to display as a banner via xmessage?
    $banner = '/etc/issue',

    # Should gdm start X with an allowed xhost entry?
    $xhost = false
)
{
    require master::user::x11

    package { 'gdm': ensure => latest }

    # The following packages are required to actually get a login from GDM
    package { 'gnome-applets': ensure => latest }
    package { 'gnome-session-xsession': ensure => latest }

    package { 'kdm': ensure => absent }
    package { 'xdm': ensure => absent }

    file { '/etc/gdm':
        ensure => directory,
        owner => root, group => root, mode => '0755',
        require => Package['gdm'],
    }
    nodefile { '/etc/gdm/custom.conf':
        require => File['/etc/gdm'],
    }
    file { '/etc/gdm/Init':
        ensure => directory,
        owner => root, group => root, mode => '0755',
        require => File['/etc/gdm'],
    }
    templatelayer { '/etc/gdm/Init/Default':
        require => File['/etc/gdm/Init'],
    }
    # GDM isn't actually a service under CentOS
    case $::osfamily {
        'debian': {
            service { 'gdm':
                ensure => running,
                require => Templatelayer['/etc/gdm/Init/Default'],
            }
        }
        default: { }
    }
}
