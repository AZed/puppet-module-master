# stonesh class
#
class master::service::stonesh (
    # Path where rsyslog should create the log
    # socket that stonesh will hardlink into the
    # user's dynamic chroot directory.  This must
    # be on the same volume where the chroot
    # directories are being placed
    $chroot_log_socket = '/home/chroot/log'
)
{
    # Make sure the required PAM packages are installed
    case $::operatingsystem {
        'centos': {
            package { "pam_script": ensure => latest }
        }
        'debian': {
            package { "libpam-chroot": ensure => latest }
            package { "libpam-script": ensure => latest }
        }
        default: {
            fail("${name} not configured for ${::operatingsystem}")
        }
    }

    # Make sure stonesh is installed
    package { "stonesh": ensure => latest }

    # Make sure the common script directory exists
    file { '/usr/share/libpam-script':
        ensure => 'directory',
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
    }

    # we need an rsyslog socket created
    master::rsyslog_config { 'stonesh':
        template => 'master/etc/rsyslog.d/stonesh.conf'
    }

    # pam_script session open and close scripts
    # (these set up and tear down the chrooted environment)
    nodefile { "/usr/share/libpam-script/pam_script_ses_open":
        owner   => 'root',
        group   => 'root',
        mode    => '0555',
        require => [
            File['/usr/share/libpam-script'],
        ]
    }
    nodefile { "/usr/share/libpam-script/pam_script_ses_close":
        owner   => 'root',
        group   => 'root',
        mode    => '0555',
        require => [
            File['/usr/share/libpam-script'],
        ],
    }

    # stonesh configuration files
    nodefile { "/etc/stonesh/hosts.lst": require => Package["stonesh"] }
    nodefile { "/etc/stonesh/stonesh.conf": require => Package["stonesh"] }

    # Symlink to old stonesh
    file { "/usr/local/bin/stonesh":
        ensure  => "/usr/bin/stonesh",
        require => Package["stonesh"],
    }

    # Symlink ssh and nc for stonesh
    # (used to identify stonesh process)
    file { "/bin/stonesh-proxy": ensure => "/bin/nc" }
    file { "/bin/stonesh-bastion": ensure => "/usr/bin/ssh" }
}
