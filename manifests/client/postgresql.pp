#
# class master::client::postgresql
# ================================
#
# Ensure the appropriate PostgreSQL client package is installed and
# (under Debian) user clusters are set up
#
class master::client::postgresql {
    case $::operatingsystem {
        'Debian': {
            package { 'postgresql-client': }
            package { 'postgresql-client-common': }
            package { 'odbc-postgresql': }

            file { '/etc/postgresql-common': ensure => directory }

            templatelayer { '/etc/postgresql-common/user_clusters':
                require => Package['postgresql-client-common'],
            }
        }
        'RedHat','CentOS': {
            package { 'postgresql': }
            package { 'postgresql-odbc': ensure => latest }
        }
        default: {
            fail("PostgreSQL client not handled for ${::operatingsystem}")
        }
    }
}
