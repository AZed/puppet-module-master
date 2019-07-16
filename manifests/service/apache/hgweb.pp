#
# class master::service::apache::hgweb
#
# Sets up the Mercurial web interface with Apache
#
# Using this class requires also using master::service::apache to set
# up the directories needed.
#

class master::service::apache::hgweb (
    # The LDAP auth string for the HGWeb interface
    $authldapurl = $master::client::ldap::authurl,

    # The base directory for Mercurial repositories
    # This should not have a leading slash, and MUST match the same
    # variable in master::common::mercurial!
    $hg_repo_base = 'var/vc/hg'
)
{
    include master::client::ldap
    include master::common::mercurial
    include master::service::apache

    # Remove Mercurial configuration from global configuration area, use
    # specific configurations based on SSL status.
    file { '/etc/apache2/conf.d/hg':
        ensure => absent,
        notify => Exec['apache2-reload'],
    }

    Templatelayer {
        owner  => root,
        group  => www-data,
        notify => Exec['apache2-reload'],
    }
    templatelayer { '/etc/apache2/conf.d-nossl/hg': }
    templatelayer { '/etc/apache2/conf.d-ssl/hg': }

    templatelayer { "/${hg_repo_base}/hgweb.config": mode => '0440', }
    templatelayer { "/${hg_repo_base}/hgwebdir.cgi": mode => '0750', }
}
