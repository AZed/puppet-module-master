#
# class master::service::drupal
# =============================
#
# Sets up a Drupal environment
#
# WARNING: based on the Debian environment, will probably fail
# anywhere else.
#

class master::service::drupal (
    # Parameters
    # ----------

    # ### mysql_db
    # The name of the MySQL database in which Drupal will store its
    # data
    $mysql_db = 'drupal',

    # ### mysql_host
    # The host of the MySQL database
    $mysql_host = 'localhost',

    # ### drupal_db_user
    # The user that will own the Drupal MySQL database
    # This will be created if it does not exist
    $drupal_db_user = 'drupal',

    # ### drupal_db_user_password
    # The user that will own the Drupal MySQL database's password
    $drupal_db_user_password = false,

    # ### baseurl
    # Base URL to go into settings.php (proxy address)
    $baseurl = '/',

    # ### cookie_domain
    # Drupal installs cookie domain (proxy)
    $cookie_domain = '',

    # ### drupal_doc_root
    # Directory where durpal lives under docroot (needed for apache rules)
    $drupal_doc_root = '/var/www/html/drupal',

    # ### drupal_base
    # Base directory for apache rewrite rules
    $drupal_base = '/',

    # ### rewrites
    # Rewrites for Drupal site
    $rewrites = [],
)
#FIXME - handle mysql database creation (mimic cds-dev)

{
    if ! $drupal_db_user_password {
        fail("\n You must set a password in the node definition that calls ${name}!\n")
    }

    else {
        file { '/etc/drupal':
            ensure => 'directory',
            owner  => 'root', group  => 'root', mode   => '0744',
        }
        templatelayer { "/etc/drupal/settings.php":
            template => "master/etc/drupal/settings.php",
            owner => root, group => 'www-data', mode => '0440',
            require => File['/etc/drupal']
        }
        file { "${drupal_doc_root}/sites/default/settings.php":
            ensure => link,
            target => '/etc/drupal/settings.php',
            require => Templatelayer['/etc/drupal/settings.php'],
        }
        templatelayer { '/etc/apache2/conf.d/drupal':
            owner => root, group => 'www-data', mode => '0440',
        }
        file { '/etc/apache2/conf-enabled/drupal.conf':
            ensure => link,
            target => '/etc/apache2/conf.d/drupal',
            require => Templatelayer['/etc/apache2/conf.d/drupal'],
        }
    }

}
