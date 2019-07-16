#
# class master::service::glpi
#
# Asset management software that requires a web server
#

class master::service::glpi {
    Class['master::common::package_management'] -> Class[$name]
    include master::service::apache
    include master::service::mysql
    include master::dev::php

    package { 'glpi': ensure => installed,
        responsefile => '/usr/local/share/debconf/glpi',
        before => Templatelayer['/etc/glpi/apache.conf'],
    }

    file { '/etc/apache2/conf.d/glpi': ensure => absent }
    file { '/etc/apache2/conf.d-ssl/glpi':
        ensure => link,
        target => '/etc/glpi/apache.conf'
    }
    file { '/etc/glpi': ensure => directory,
        owner => root, group => root, mode => '0555',
    }
    file { '/etc/glpi/config': ensure => directory,
        owner => 'www-data', group => root, mode => '0755',
    }
    nodefile { '/etc/glpi/config/config_db.php': defaultensure => 'ignore' }
    nodefile { '/etc/glpi/config/define.php': defaultensure => 'ignore' }

    templatelayer { '/etc/cron.hourly/glpi':
        owner => root, group => root, mode => '0555',
    }
    templatelayer { '/etc/glpi/apache.conf':
        require => Package['glpi'],
    }
}
