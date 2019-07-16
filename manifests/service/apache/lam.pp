#
# class master::service::apache::lam
#
# Sets up the LDAP Account Manager web interface for Apache
#
# Only tested under Debian
#

class master::service::apache::lam (
    # Handle home directories and quotas?
    $lamdaemon = true,
){
    require master::service::apache::dirs
    include master::dev::php
    
    package { 'ldap-account-manager': }
    if $lamdaemon {
        package { 'ldap-account-manager-lamdaemon': }
    }

    # We don't manage /etc/ldap-account-manager/config.cfg because
    # that file can be rewritten from the web interface.
}
