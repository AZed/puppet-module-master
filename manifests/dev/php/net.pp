#
# class master::dev::php::net
# ===========================
#
# Additional PHP packages related to networks and network
# authentication
#

class master::dev::php::net {
    package { 'php-http-request': }
    package { 'php-net-ipv6': }
    package { 'php-net-url': }
    package { 'php-soap': }

    case $::operatingsystem {
        'Debian': {
            if versioncmp($::operatingsystemrelease, '9.0') >= 0 {
                package { 'php-oauth': }
                package { 'php-curl': }
                package { 'php-geoip': }
                package { 'php-net-ldap3': }
            }
            else {
                package { 'php-net-checkip': }
                package { 'php-net-ipv4': }
                package { 'php-net-ldap': }
                package { 'php-openid': }
                package { 'php-xajax': }
                package { 'php5-curl': }
                package { 'php5-geoip': }
            }
        }
        default: { }
    }
}
