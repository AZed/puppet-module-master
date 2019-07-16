#
# class master::service::apache::git
#
# WARNING: OBSOLETE - Apache 2.2 only!
# For Apache 2.4+ use master::service::apache::gitweb
#
# Sets up the Git web interface with Apache
#
# Currently, this only allows read-only exports, and only where the
# repository contains the file "git-daemon-export-ok".  The repository
# base is currently hardwired to "/git", so ensure that is a symlink
# to wherever your repositories actually are if needed.
#

class master::service::apache::git {
    include master::service::apache

    package { "gitweb": ensure => latest }

    Templatelayer {
        owner => root, group => www-data,
        notify  => Exec['apache2-reload'],
    }
    templatelayer { "/etc/gitweb.conf": }
    templatelayer { "/etc/apache2/conf.d-nossl/git": }

    # Remove gitweb configuration from global configuration area, as we
    # use specific configurations based on SSL status.
    file { "/etc/apache2/conf.d/gitweb":
        ensure => absent,
        notify  => Exec['apache2-reload'],
    }
}
