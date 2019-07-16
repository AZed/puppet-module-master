#
# class master::service::apache::gitweb
#
# Sets up the Git web interface with Apache 2.4+
#
# Currently, this only allows read-only exports, and only where the
# repository contains the file "git-daemon-export-ok".  The repository
# base is currently hardwired to "/git", so ensure that is a symlink
# to wherever your repositories actually are if needed.
#

class master::service::apache::gitweb (
    # Webserver alias (URL path)
    $webalias = '/gitweb'
)
{
    include master::service::apache

    package { 'gitweb': ensure => latest }

    Templatelayer {
        owner => root, group => www-data,
        notify  => Exec['apache2-reload'],
    }
    File {
        notify  => Exec['apache2-reload'],
    }
    templatelayer { '/etc/gitweb.conf': }
    templatelayer { '/etc/apache2/conf-available/gitweb.conf': }
    file { '/etc/apache2/conf-enabled/gitweb.conf':
        ensure => link,
        target => '../conf-available/gitweb.conf',
    }

    # Remove old gitweb configuration files if present
    file { '/etc/apache2/conf.d/gitweb': ensure => absent, }
    file { '/etc/apache2/conf.d-nossl/git': ensure => absent, }
}
