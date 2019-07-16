#
# master::user::displaymanager::gdm3
#
# Installs the Gnome display manager
# Do not use this class with any other user::displaymanager:* class
#

class master::user::displaymanager::gdm3 (
    # What file to display as a banner via xmessage?
    $banner = '/etc/issue',

    # Should gdm3 start X with an allowed xhost entry?
    $xhost = false
)
{
    require master::user::x11

    package { 'gdm3': ensure => latest }

    # The following packages are required to actually get a login from GDM
    package { 'gnome-applets': ensure => latest }
    package { 'gnome-session': ensure => latest }
    package { 'gnome-session-bin': ensure => latest }
    package { 'gnome-session-common': ensure => latest }
    package { 'gnome-session-fallback': ensure => latest }

    package { 'kdm': ensure => absent }
    package { 'xdm': ensure => absent }

    file { '/etc/gdm3':
        ensure => directory,
        owner => root, group => root, mode => '0755',
        require => Package['gdm3'],
    }
    nodefile { '/etc/gdm3/custom.conf':
        require => File['/etc/gdm3'],
    }
    file { '/etc/gdm3/Init':
        ensure => directory,
        owner => root, group => root, mode => '0755',
        require => File['/etc/gdm3'],
    }
    templatelayer { '/etc/gdm3/Init/Default':
        require => File['/etc/gdm3/Init'],
    }
    # GDM isn't actually a service under CentOS
    case $::osfamily {
        'debian': {
            service { 'gdm3':
                ensure => running,
                require => Templatelayer['/etc/gdm3/Init/Default'],
            }
        }
        default: { }
    }
}
