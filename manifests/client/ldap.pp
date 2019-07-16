#
# class master::client::ldap
# ==========================
#
# Configures the basic ability to search LDAP servers and sets LDAP
# defaults usable by other classes
#
# The variables:
#   $master::client::ldap::base
#   $master::client::ldap::uri
#   $master::client::ldap::authurl
# are intended for use in other classes, which must include this one
# at the top of the definition to guarantee that they are readable
#

class master::client::ldap (
    # Parameters
    # ----------

    # ### base
    # By default the base will be in the format dc=domain,dc=tld
    $base = regsubst(
            regsubst($::domain,'([a-zA-Z0-9-]+)\.?','dc=\1,','G'),
            '(.*),','\1'
            ),

    # ### cacert
    # CA Certificate file to use when validating server certificates
    $cacert = undef,

    # ### cipher_suite
    # Colon-separated list of ciphers to try
    $cipher_suite = undef,

    # Do we require server certificate validation?  Valid values are
    # 'never', 'allow', 'try', 'demand' (see man page for ldap.conf)
    $reqcert = 'never',

    $uri = "ldaps://ldap.${::domain}"
)
{
    include master::common::pam
    require master::common::ssl

    # Default URI used for LDAP authentication by Apache and similar
    $authurl = "${uri}/${base}?uid??(objectclass=*)"

    case $::osfamily {
        'Debian': {
            package { 'ldap-utils':  ensure => installed }

            file { '/etc/ldap':
                ensure => directory,
                owner  => 'root',
                group  => 'root',
                mode   => '0755',
            }

            templatelayer { '/etc/ldap/ldap.conf':
                require => File['/etc/ldap'],
            }
        }
        'RedHat': {
            package { 'openldap-clients': ensure => installed }

            file { '/etc/openldap': ensure => directory }
            templatelayer { '/etc/openldap/ldap.conf':
                template => 'master/etc/ldap/ldap.conf',
            }
            file { '/etc/openldap/cacerts': ensure => '../ssl/certs' }
            file { '/etc/ldap': ensure => link,
                target => '/etc/openldap',
                force => true,
            }
            file { '/etc/ldap.conf':
                ensure => 'openldap/ldap.conf',
                require => Templatelayer['/etc/openldap/ldap.conf'],
            }
        }
        'Suse': {
            package { 'openldap2-client': ensure => installed, }

            file { '/etc/openldap': ensure => directory }
            templatelayer { '/etc/openldap/ldap.conf':
                template => 'master/etc/ldap/ldap.conf',
            }
        }
        default: {
            file { '/etc/ldap':
                ensure => directory,
                owner => 'root', group => 'root', mode => '0755',
            }
        }
    }
}
