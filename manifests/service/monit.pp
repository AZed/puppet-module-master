#
# class master::service::monit
# ============================
#
# Sets up the monit daemon to monitor and automatically restart other processes
#
# Note that the configuration file locations vary by operating system
# release.  Debian uses /etc/monit/monitrc and /etc/monit/monitrc.d,
# RedHat uses /etc/monitrc and /etc/monit.d.
#

class master::service::monit (
    # Parameters
    # ----------

    # ### binary_version
    # For distributions that either do not package monit, or package a
    # version too old to be useful, obtain the specified monit version
    # from the mmonit.com official site
    #
    # This parameter is ignored if the OS packages at least monit v5.
    $binary_version = '5.25.2',

    # ### daemon
    # Number of seconds between daemon checks
    $daemon = '60',

    # ### startdelay
    # Number of seconds to wait after monit starts before the first check is made
    $startdelay = undef,

    # ### templates
    # Template fragments to transclude into /etc/monitrc
    $templates = undef,
){
    $binary_url = "https://mmonit.com/monit/dist/binary/${binary_version}/monit-${binary_version}-linux-x64.tar.gz"

    case $::operatingsystem {
        'Debian','Ubuntu': {
            package { 'monit': }
            $monitrc = '/etc/monit/monitrc'
            $monitrcd = '/etc/monit/monitrc.d'
        }
        'RedHat','CentOS': {
            if versioncmp($::operatingsystemrelease, '7.0') < 0 {
                exec { 'monit-download':
                    cwd     => '/usr/local',
                    path    => '/bin:/usr/bin',
                    command => "curl -sLO ${binary_url}",
                    creates => "/usr/local/monit-${binary_version}-linux-x64.tar.gz",
                }
                exec { 'monit-unpack':
                    cwd     => '/usr/local',
                    path    => '/bin:/usr/bin',
                    command => "tar xf /usr/local/monit-${binary_version}-linux-x64.tar.gz",
                    creates => "/usr/local/monit-${binary_version}",
                    require => Exec['monit-download'],
                }
                file { '/usr/local/monit':
                    ensure  => link,
                    target  => "/usr/local/monit-${binary_version}",
                    require => Exec['monit-unpack'],
                }
                $monitrc = '/etc/monitrc'
                $monitrcd = '/etc/monit.d'
            }
            else {
                package { 'monit': }
                $monitrc = '/etc/monitrc'
                $monitrcd = '/etc/monit.d'
            }
        }
        'Suse','SLES': {
            exec { 'monit-download':
                cwd     => '/usr/local',
                path    => '/bin:/usr/bin',
                command => "curl -sLO ${binary_url}",
                creates => "/usr/local/monit-${binary_version}-linux-x64.tar.gz",
            }
            exec { 'monit-unpack':
                cwd     => '/usr/local',
                path    => '/bin:/usr/bin',
                command => "tar xf /usr/local/monit-${binary_version}-linux-x64.tar.gz",
                creates => "/usr/local/monit-${binary_version}",
                require => Exec['monit-download'],
            }
            file { '/usr/local/monit':
                ensure  => link,
                target  => "/usr/local/monit-${binary_version}",
                require => Exec['monit-unpack'],
            }
            $monitrc = '/etc/monitrc'
            $monitrcd = '/etc/monit.d'
        }
        default: {
            package { 'monit': }
            $monitrc = '/etc/monitrc'
            $monitrcd = '/etc/monit.d'
        }
    }
}
