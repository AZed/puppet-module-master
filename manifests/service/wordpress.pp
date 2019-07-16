#
# class master::service::wordpress
#
# Sets up a Wordpress environment
#
# WARNING: based on the Debian environment, will probably fail
# anywhere else.
#

class master::service::wordpress (
  # An array of additional lines to add to /etc/wordpress/config-default.php
  # This isn't required, but it is recommended to copy into this array lines
  # from https://api.wordpress.org/secret-key/1.1/salt/
  # Changing those lines will invalidate all existing cookies
  $config_lines = [ ],

  # Create a special group with write access to Wordpress files?
  # This should either be false or a group name
  $group = false,

  # Members of the above group, if specified
  # This should be a comma-separated list of accounts
  $groupmembers = '',

  # GID of the above group, if specified.
  # This should either be undef or a valid and unused group number
  $groupnumber = undef,

  # The name of the MySQL database in which Wordpress will store its
  # data
  $mysql_db = 'wp',

  # The host of the MySQL database
  $mysql_host = 'localhost',

  # The password needed to connect to the Wordpress MySQL database
  # This MUST be set in the node definition -- the default is false,
  # which will force a failure
  $mysql_pass = false,

  # The user that will own the Wordpress MySQL database
  # This will be created if it does not exist
  $mysql_user = 'wordpress',

  # If redirect_root is set to true, then / on the webserver will be
  # automatically redirected to $urlpath
  $redirect_root = false,

  # This is the URL path at which Wordpress will be found on the webserver
  #
  # If set to false, it will attempt to use '/'.  This requires that
  # apache be set to use Wordpress as its DocumentRoot.
  $urlpath = '/wp'
)
{
  if ! $mysql_pass {
    fail("\n You must set a password in the node definition that calls ${name}!\n")
  }
  else {
    package { 'wordpress': ensure => latest }
    templatelayer { '/etc/apache2/conf.d/wordpress': }

    file { '/etc/wordpress': ensure => directory,
      owner => root, group => 'www-data', mode => '0755',
    }
    templatelayer { '/etc/wordpress/config-default.php':
      owner => root, group => 'www-data', mode => '0440',
    }
    templatelayer { '/etc/wordpress/htaccess':
      owner => root, group => 'www-data', mode => '0440',
    }

    mysql::create_db { $mysql_db: }

    mysql::create_user { "${mysql_user}@${mysql_host}":
      password => $mysql_pass, hashedpass => false,
    }
    mysql::grantall { "${mysql_db}-${mysql_user}@${mysql_host}":
      database => $mysql_db,
      user     => "${mysql_user}@${mysql_host}",
      require  => [ Mysql::Create_db[$mysql_db],
                    Mysql::Create_user["${mysql_user}@${mysql_host}"],
                    ],
    }
  }

  if $group {
    group { $group:
      ensure => present,
      gid    => $groupnumber,
    }
    groupmembers { $group:
      members => $groupmembers,
      require => Group[$group],
    }

    # You may also want to set all directories under
    # /var/lib/wordpress/wp-content setgid as well, but this class
    # will not do so for you at this time.
    exec { 'chgrp-wp-content':
      command => "chgrp -R ${group} /var/lib/wordpress/wp-content",
      path    => '/bin:/usr/bin',
      require => Group[$group],
    }
    exec { 'chmod-wp-content':
      command => 'chmod -R g+rwX /var/lib/wordpress/wp-content',
      path    => '/bin:/usr/bin',
      require => Exec['chgrp-wp-content'],
    }
  }
}
