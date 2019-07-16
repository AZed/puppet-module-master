#
# class master::service::mysql
# ============================
#
# This installs MySQL, but is heavily Debian-specific, locking the
# root account by default and relying on the debian-sys-maint account
# for most maintenance.
#
# Expect a rewrite
#

class master::service::mysql (
    # Parameters
    # ----------

    # Default MySQL root password is '*', which locks the account
    $mysql_root_password = '*'
)
{
    require master::common::network

    package { 'mysql-server': ensure => latest,
        before  => Exec['mysql-set-root-password'],
    }

    schedule { 'master::service::mysql-oncemonthly':
        period => monthly,
        repeat => 1
    }

    case $::operatingsystem {
        # Default version values are probably a bad idea, but leaving them
        # in place until doing this clearly breaks a server.
        'Debian': {
            case $::release_majornum {
                '5': {
                    $mysql_version = '5.0'
                }
                '6': {
                    $mysql_version = '5.1'
                    package { 'maatkit': ensure => latest, }
                }
                '7': {
                    $mysql_version = '5.5'
                    package { 'percona-toolkit': ensure => latest }
                }
                default: {
                    $mysql_version = '5.5'
                }
            }
        }
        default: {
            $mysql_version = '5.1'
        }
    }

    templatelayer { '/etc/mysql/my.cnf':
        notify => Exec['/etc/init.d/mysql restart'],
        suffix => $mysql_version,
    }
    file { '/etc/mysql/conf.d': ensure => directory, mode => '0755' }
    templatelayer { '/etc/mysql/conf.d/cis.cnf':
        notify => Exec['/etc/init.d/mysql restart'],
    }

    ### MySQL doesn't have the concept of PAM, UNIX
    ### passwords, or LDAP.  Additionally, Debian
    ### uses a configuration file and a specific user
    ### for automated DB changes.
    ###
    ### This script is a 'blunt' instrument designed
    ### to strengthen and change the password used
    ### by this automation user.
    file { '/usr/local/sbin/mysql_debian_randpw':
        owner   => root,
        group   => root,
        mode    => '0750',
        source  => 'puppet:///modules/master/usr/local/sbin/mysql_debian_randpw',
        require => Package['mysql-server'],
        before  => Exec['/usr/local/sbin/mysql_debian_randpw']

    }
    exec { '/usr/local/sbin/mysql_debian_randpw':
        path     => [ '/bin:/usr/bin:/usr/local/sbin' ],
        require  => File['/usr/local/sbin/mysql_debian_randpw'],
        schedule => 'master::service::mysql-oncemonthly',
    }

    file { '/usr/local/sbin/backup-mysql-database.sh':
        owner   => root,
        group   => root,
        mode    => '0750',
        source  => 'puppet:///modules/master/usr/local/sbin/backup-mysql-database.sh'
    }

    templatelayer { '/etc/cron.d/mysql-backup': }

    # Set the MySQL root password
    exec { 'mysql-set-root-password':
        command => "/usr/bin/mysql --defaults-file=/etc/mysql/debian.cnf -sBe \"LOCK TABLE user WRITE; UPDATE user SET password = '$mysql_root_password' WHERE user = 'root'; UNLOCK TABLES; FLUSH PRIVILEGES;\" mysql",
        path    => [ '/usr/bin' ],
        require => Package['mysql-server'],
    }

    # If root has a .my.cnf file, force it to be mode 0600 for safety
    file { '/root/.my.cnf': owner => root, group => root, mode => '0600', }

    exec { '/etc/init.d/mysql restart':
        command     => '/etc/init.d/mysql restart',
        path        => '/bin:/usr/bin:/usr/sbin',
        refreshonly => true,
        require     => Package['mysql-server'],
    }

    service { 'mysql':
        ensure  => running,
        enable  => true,
        start   => '/etc/init.d/mysql start',
        stop    => '/etc/init.d/mysql stop',
        require => Package['mysql-server'],
    }

    master::nagios_check { '30_mysql': }
}


###############
### Defines ###
###############

# Create a database, but only if the database name is not already in
# use
#
# Arguments:
#   $charset       : if defined, the database will be set to that character set
#   $defaults_file : if defined, will be passed to mysql as a configuration
#                    file.  Debian uses /etc/mysql/debian.cnf automatically
#                    for passwordless update.
#
define mysql::create_db ($charset=false,$defaultsfile=false) {
    if $charset {
        $charsetopt = "CHARACTER SET = ${charset}"
    }
    else {
        $charsetopt = ''
    }

    if $defaultsfile {
        $defaultsopt = "--defaults-file=${defaultsfile}"
    }
    else {
        case $::operatingsystem {
            'debian': {
                $defaultsopt = '--defaults-file=/etc/mysql/debian.cnf'
            }
            default: {
                $defaultsopt = ''
            }
        }
    }

    exec { "mysql_create_db-${title}":
        command => "mysql ${defaultsopt} -B -e 'CREATE DATABASE ${title} ${charsetopt}'",
        path    => '/sbin:/usr/sbin:/bin:/usr/bin',
        unless  => "mysql ${defaultsopt} -B -e 'SHOW DATABASES' | grep '^${title}$'",
        require => Service['mysql'],
    }
}


# Create a user, but only if the username is not already in the database
#
# The title is the user string that will be created, and should be in
# the form of <user>@<host>.  If you fail to specify the host, the
# creation may succeed, but Puppet will be unable to determine that
# the username does not already exist.
#
# Arguments:
#   $defaults_file : if defined, will be passed to mysql as a configuration
#                    file.  Debian uses /etc/mysql/debian.cnf automatically
#                    for passwordless update.
#   $auth_plugin   : Auth plugin to use for the user
#   $auth_string   : If auth_plugin is true, then identify as this string
#                    to the plugin
#   $password      : Password string to assign to the user
#                    This is mutually exclusive with $auth_plugin
#   $hashedpass    : If this is true (default), then $password is interpreted
#                    as a hashed string.  If set false, $password is treated
#                    as a plaintext password.
#
define mysql::create_user (
    $defaultsfile=false,
    $auth_plugin=false, $auth_string=false,
    $password=false, $hashedpass=true
)
{
    if $defaultsfile {
        $defaultsopt = "--defaults-file=${defaultsfile}"
    }
    else {
        case $::operatingsystem {
            'Debian': {
                $defaultsopt = '--defaults-file=/etc/mysql/debian.cnf'
            }
            default: {
                $defaultsopt = ''
            }
        }
    }

    if $auth_plugin {
        if $auth_string {
            $authsql = "IDENTIFIED WITH ${auth_plugin} AS ${auth_string}"
        }
        else {
            $authsql = "IDENTIFIED WITH ${auth_plugin}"
        }
    }
    elsif $password {
        if $hashedpass {
            $authsql = "IDENTIFIED BY PASSWORD '${password}'"
        }
        else {
            $authsql = "IDENTIFIED BY '${password}'"
        }
    }
    else {
        $authsql = ''
    }

    exec { "mysql_create_user-${title}":
        command => "mysql ${defaultsopt} -B -e \"CREATE USER ${title} ${authsql}\"",
        path    => '/sbin:/usr/sbin:/bin:/usr/bin',
        unless  => "mysql ${defaultsopt} -BN -e 'USE mysql ; SELECT user,host FROM user' | tr '\t' '@' | grep -q '^${title}$'",
        require => Service['mysql'],
    }
}


# Drop a database, but only if it exists
#
# Arguments:
#   $defaults_file : if defined, will be passed to mysql as a configuration
#                    file.  Debian uses /etc/mysql/debian.cnf automatically
#                    for passwordless update.
#
define mysql::drop_db ( $defaultsfile=false ) {
    if $defaultsfile {
        $defaultsopt = "--defaults-file=${defaultsfile}"
    }
    else {
        case $::operatingsystem {
            'Debian': {
                $defaultsopt = '--defaults-file=/etc/mysql/debian.cnf'
            }
            default: {
                $defaultsopt = ''
            }
        }
    }

    exec { "mysql_drop_db-${title}":
        command => "mysql ${defaultsopt} -B -e 'DROP DATABASE ${title}",
        path    => '/sbin:/usr/sbin:/bin:/usr/bin',
        onlyif  => "mysql ${defaultsopt} -B -e 'SHOW DATABASES' | grep '^${title}$'",
        require => Service['mysql'],
    }
}


# Drop a user, but only if the username is already in the database
define mysql::drop_user ( $defaultsfile=false )
{
    if $defaultsfile {
        $defaultsopt = "--defaults-file=${defaultsfile}"
    }
    else {
        case $::operatingsystem {
            'Debian': {
                $defaultsopt = '--defaults-file=/etc/mysql/debian.cnf'
            }
            default: {
                $defaultsopt = ''
            }
        }
    }
    exec { "mysql_drop_user-${title}":
        command => "mysql ${defaultsopt} -B -e 'DROP USER ${title}'",
        path => '/sbin:/usr/sbin:/bin:/usr/bin',
        onlyif => "mysql ${defaultsopt} -BN -e 'USE mysql ; SELECT user FROM user' | grep -q '^${title}$'",
        require => Service['mysql'],
    }
}


# Grant all permissions on a database to a user
# Fails if either database or user is not specified
# Recommended syntax:
#   mysql::grantall { '<database>-<user':
#     database => <database>
#     user     => <user>
#   }
define mysql::grantall ( $defaultsfile=false, $database=false, $user=false )
{
    if ! $database {
        fail("\n No database specified for ${name}-${title}!\n")
    }
    if ! $user {
        fail("\n No user specified for ${name}-${title}!\n")
    }

    if $defaultsfile {
        $defaultsopt = "--defaults-file=${defaultsfile}"
    }
    else {
        case $::operatingsystem {
            'Debian': {
                $defaultsopt = '--defaults-file=/etc/mysql/debian.cnf'
            }
            default: {
                $defaultsopt = ''
            }
        }
    }

    exec { "mysql_grantall-${title}":
        command => "mysql ${defaultsopt} -B -e 'GRANT ALL PRIVILEGES ON ${database}.* TO ${user}'",
        path    => '/sbin:/usr/sbin:/bin:/usr/bin',
        require => Service['mysql'],
    }
}
