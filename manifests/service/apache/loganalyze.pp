#
# master::service::apache::loganalyze
#
# Installs and configures a log analyzer for Apache
#
# Authentication requires LDAP
#
# This class requires Puppetlabs Stdlib
#

class master::service::apache::loganalyze (
    # Prefix for the URL path
    # Full alias will append the sitename
    $aliaspath = '/logs',

    # Name of the site to be analyzed
    $site = $::hostname,

    # Logfile to analyze
    $logfile = $::osfamily ? {
        'Debian' => '/var/log/apache2/ssl_access.log',
        'RedHat' => '/var/log/httpd/ssl_access.log',
    },

    # LDAP Auth URL
    $authldapurl = $master::client::ldap::authurl,

    # Hiding Options
    $hidereferrer = [ "${::domain}/" ],
    $hideurl = [ '*.gif','*.GIF','*.jpg','*.JPG','*.png','*.PNG','*.ra' ],
    $hideuser = [ ],
    $groupurl = [ '/tmp/*', ],
    $groupandhideagent = [ ],

    # Replicated from Apache
    $webmasters = $master::service::apache::webmasters
)
{
    include master::common::package_management
    include master::client::ldap
    include master::service::apache
    include master::util::geoip

    package { ['awffull','dnshistory']: ensure => latest,
        before  => Exec['apache2-reload'],
        require => Class['master::common::package_management'],
    }

    templatelayer { '/etc/cron.daily/awffull': mode => '0555', }
    file { '/var/cache/awffull': ensure => directory,
        owner => 'root', group => 'www-data', mode => '2750',
    }
    file { '/var/www/awffull': ensure => absent, force => true }

    # We're naming the configuration files on a per-site basis in
    # preparation for being able to support analyzing more than one
    # logfile.  Unfortunately, a clean implementation of that requires
    # hashes, which in turn requires the future parser.
    templatelayer { "/etc/apache2/conf.d-ssl/awffull-${site}.conf":
        template => 'master/etc/apache2/conf.d-ssl/awffull',
    }

    file { '/etc/awffull':
        ensure  => directory,
        recurse => true,
        purge   => true,
    }
    templatelayer { "/etc/awffull/${site}.conf":
        template => 'master/etc/awffull/awffull.conf',
    }

    # Remove obsolete files
    file { '/etc/apache2/conf.d-ssl/awffull': ensure => absent }
}
