#
# class master::service::trac
# ===========================
#
# This sets up the system such that trac projects can be easily
# defined by the node, but does not actually generate a trac project
# by default, and forces the use of a define rather than an array
# variable (the data that has to be passed is too complex for just a
# single name).
#

class master::service::trac (
    # Parameters
    # ----------

    # ### apache_require
    # Apache access requirements
    #
    # This can be presented either as a string or as an array.
    # Generated lines will be placed inside a RequireAll block
    # preceded by the keyword 'require'
    #
    # Example:
    #
    #     master::service::apache::cvsweb::apache_require:
    #       - 'valid-user'
    #       - 'ip 1.2.3.4'
    #
    $apache_require = 'valid-user',

    # ### errordocument
    #
    # A hash where the keys are the response codes and the values are URLs
    #
    $errordocument = lookup('master::service::apache::cvsweb::errordocument',Hash,undef),

    # ### header_logo
    # Customized logo information can be provided as a hash as follows:
    #   header_logo => {
    #     'alt'    => '...',
    #     'link'   => '...',
    #     'src'    => '...',
    #     'height' => '...',
    #     'width'  => '...',
    #   }
    $header_logo = false,

    # ### notification
    # Notification information can be provided as a hash as follows:
    #   notification => {
    #     'always_notify_reporter'  => '...',
    #     'always_notify_owner'     => '...',
    #     'always_notify_updater'   => '...',
    #     'mime_encoding'		  => '...',
    #     'smtp_enabled'		  => '...',
    #     'smtp_from'		  => '...',
    #     'smtp_port'		  => '...',
    #     'smtp_replyto'		  => '...',
    #     'smtp_server'		  => '...',
    #	'ticket_subject_template' => '...',
    #	'use_public_cc'		  => '...',
    #     'use_short_addr'	  => '...',
    #     'use_tls'		  => '...',
    #   }
    $notification = false,

    # ### ldap
    # STUB: Authenticate via LDAP?
    # Currently, this is required
    $ldap = true
)
{
    # Code Comments
    # -------------
    require master::common::mercurial
    require master::dev::git
    require master::dev::python
    require master::service::postgresql

    if $ldap {
        include master::client::ldap
        $authldapurl = $master::client::ldap::authurl
    }

    package { 'trac': }

    case $operatingsystem {
        'debian': {
            package { 'trac-customfieldadmin': }
            package { 'trac-email2trac': }
            package { 'trac-mastertickets': }
            package { 'trac-mercurial': }

            # Trac-spamfilter is in a weird state -- available in Squeeze
            # and in Jessie, but not Wheezy
            #package { 'trac-spamfilter': }

            if versioncmp($::operatingsystemrelease, '7.0') >= 0 {
                package { 'trac-jsgantt': }
                package { 'trac-subtickets': }
            }
            else {
                # trac-git was folded into the main Trac 1.0
                package { 'trac-git': }
            }
        }
        'centos','redhat': {
            package { 'trac-customfield-admin': }
            package { 'trac-git-plugin': }
            package { 'trac-mastertickets-plugin': }
            package { 'trac-mercurial-plugin': }
            package { 'trac-spamfilter-plugin': }
        }
        default: { }
    }

    file { ['/etc/trac','/var/trac']:
        ensure => directory,
        owner => root, group => root, mode => '0755',
    }
    file { '/var/www/trac': ensure => directory,
        owner => root, group => root, mode => '0755',
        require => Class['master::service::apache'],
    }

    # Trac requires SSL
    file { '/etc/apache2/conf.d/trac': ensure => absent,
        notify => Exec['apache2-reload'],
    }
    templatelayer { '/etc/apache2/conf.d-ssl/trac':
        require => [ Templatelayer['/var/trac/trac.wsgi'],
                     Class['master::service::apache::packages'],
                     ],
        notify => Exec['apache2-reload']
    }
    templatelayer { '/etc/trac/trac.ini': }
    templatelayer { '/var/trac/trac.wsgi': }

    master::hg_clone { 'mercurial-trac-hook':
        repo => 'http://bitbucket.org/madssj/mercurial-trac-hook/',
    }
    file { '/usr/local/lib/trachook.py':
        ensure => '../src/mercurial-trac-hook/trachook.py',
        require => Master::Hg_clone['mercurial-trac-hook'],
    }

    file { '/usr/local/sbin/istracadmin':
        owner => root, group => root, mode => '0555',
        source => "puppet:///modules/master/usr/local/sbin/istracadmin",
    }
    file { '/usr/local/sbin/trac-defaultperms':
        owner => root, group => root, mode => '0555',
        source => "puppet:///modules/master/usr/local/sbin/trac-defaultperms",
    }

    master::pg_create_user { 'trac': createdb => true }
}
