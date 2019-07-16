#
# class master::service::apache::dirs
# ===================================
#
# Sets up base directories for Apache in a separate class so that
# configuration resources can depend upon it to know that they exist.
#

class master::service::apache::dirs {
    include master::service::apache
    require master::service::apache::packages

    # Base directories
    case $::operatingsystem {
        'centos','redhat','sles': {
            file { '/etc/httpd': ensure => directory,
                owner => root, group => root, mode => '0755',
            }
            file { '/etc/httpd/conf': ensure => directory,
                owner => root, group => root, mode => '0755',
            }
            file { '/etc/apache2': ensure => link,
                target => '/etc/httpd',
                require => File['/etc/httpd'],
            }
            # mods-enabled needs special handling >= RH7
            if versioncmp($::operatingsystemrelease, '7.0') >= 0 {
                file { '/etc/apache2/mods-enabled':
                    alias   => '/etc/httpd/mods-enabled',
                    ensure  => link,
                    target  => 'conf.modules.d',
                    force   => true,
                    require => [ File['/etc/apache2'],
                                 Package['httpd'],
                                 ],
                }
                # These conflicts with our managed configuration
                file { '/etc/apache2/conf.modules.d/00-ssl.conf':
                    ensure => absent,
                }
            }
            else {
                file { '/etc/apache2/mods-enabled':
                    alias   => '/etc/httpd/mods-enabled',
                    ensure  => directory,
                    owner   => root, group => root, mode => '0755',
                    require => File['/etc/apache2']
                }
            }
        }
        'debian': {
            file { '/etc/apache2': ensure => directory,
                owner => 'root', group => 'root', mode => '0755',
            }

            file { '/etc/apache2/mods-enabled':
                ensure  => directory,
                owner   => root, group => root, mode => '0755',
                require => File['/etc/apache2']
            }

            # This isn't default to Debian, but is instead taken from
            # CentOS/RedHat for compatibility
            file { '/etc/apache2/modules':
                ensure => link,
                target => '/usr/lib/apache2/modules',
            }
            file { '/etc/httpd':
                ensure => link,
                target => '/etc/apache2',
            }
        }
        'sles': {
            file { '/etc/apache2': ensure => directory,
                owner => root, group => root, mode => '0755',
            }
            file { '/etc/apache2/mods-enabled':
                ensure  => directory,
                owner   => root, group => root, mode => '0755',
                require => File['/etc/apache2']
            }
        }
        default: { }
    }

    # These aren't default on all operating systems, but are
    # standardized here for mod management
    #
    # Note that sites-available and mods-enabled are handled
    # separately
    file { '/etc/apache2/mods-available':
        ensure  => directory,
        owner   => root, group => root, mode => '0755',
    }
    file { '/etc/apache2/sites-enabled':
        ensure  => directory,
        owner   => root,
        group   => root,
        mode    => '0755',
        recurse => true,
        purge   => true,
    }
}
