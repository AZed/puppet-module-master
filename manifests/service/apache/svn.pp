#
# master::service::apache::svn
#
# Installs Subversion support for Apache.  This will necessarily also pull Apache.
#

class master::service::apache::svn {
    package { "libapache2-svn": ensure => latest,
        before => Exec["apache2-reload"]
    }
}
