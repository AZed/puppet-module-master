#
# class master::client::pamldap
# =============================
#
# Configures pam_ldap, provided by pam-ldapd on Debian 7 and
# RedHat/CentOS 7+ or pam-ldap on SuSE-based systems, Debian 8+, and
# RedHat/CentOS 6
#
# This will automatically include master::service::nscd, and conflicts
# with master::service::sssd
#
# Note that although this is in master::client for historical reasons,
# on pam-ldapd systems it will start and configure a service (nslcd).
#

class master::client::pamldap (
    # Parameters
    # ----------

    # ### check_host_attr
    # Users must have a matching 'host' entry in LDAP to log in
    $check_host_attr = false,

    # Parameters for original pam-ldap package
    # ----------------------------------------
    #
    # PARAMETERS BELOW THIS POINT VALID ONLY FOR ORIGINAL pam-ldap
    # (and should not normally require changing)

    # ### bind_policy
    # Reconnect policy:
    #
    #     hard_open: reconnect to DSA with exponential backoff if
    #                opening connection failed
    #     hard_init: reconnect to DSA with exponential backoff if
    #                initializing connection failed
    #     hard:      alias for hard_open
    #     soft:      return immediately on server failure
    #
    # Some implementations may only recognize 'hard' and 'soft'
    #
    # WARNING: SLES 11 will lock at boot unless bind_policy is 'soft'!
    # See: http://www.novell.com/support/kb/doc.php?id=7007555
    $bind_policy = $::operatingsystem ? {
        'SLES'  => 'soft',
        default => 'hard',
    },

    # ### nss_base_passwd
    # ### nss_base_shadow
    # ### nss_base_group
    # ### nss_base_hosts
    # ### nss_base_services
    #
    # RFC2307bis naming contexts
    # Syntax:
    # nss_base_XXX	base?scope?filter
    # where scope is {base,one,sub}
    # and filter is a filter to be &'d with the default filter.
    #
    # If left false, this will default automatically to the base dn, and
    # usually does not need to be changed.
    $nss_base_passwd   = false,
    $nss_base_shadow   = false,
    $nss_base_group    = false,
    $nss_base_hosts    = false,
    $nss_base_services = false,

    # ### pam_filter
    # Filter to AND with uid=%s
    # Default is to not filter
    $pam_filter = false
){
    require master::client::ldap
    include master::service::nscd

    $base    = $master::client::ldap::base
    $cacert  = $master::client::ldap::cacert
    $uri     = $master::client::ldap::uri
    $authurl = $master::client::ldap::authurl

    package { 'sssd': ensure => absent }
    service { 'sssd':
        ensure => stopped,
        enable => false,
    }

    case $::osfamily {
        'Debian': {
            # In Debian versions prior to 8 (Jessie), libnss-ldap and
            # libpam-ldap are extremely buggy when combined with LDAP
            # over SSL.  For that case, libnss-ldapd and libpam-ldapd
            # is used instead, but as those have poor to nonexistent
            # support for displaying time until password expiration,
            # they are only used in this emergency circumstance.
            #
            # WARNING: this may trigger unintentionally on some
            # derivatives, as it is inside a $::osfamily check, but it
            # should still result in a working system
            if versioncmp($::operatingsystemrelease, '8.0') < 0 {
                package { 'libnss-ldapd':
                    ensure => installed,
                    alias  => 'nss-ldap',
                    before => Package['nscd'],
                    notify => Service['nslcd'],
                }
                package { 'libpam-ldapd':
                    ensure => installed,
                    alias  => 'pam-ldap',
                    before => Package['nscd'],
                    notify => Service['nslcd'],
                }
                templatelayer { '/etc/nslcd.conf':
                    suffix => $::osfamily,
                    notify => Service['nslcd']
                }
                service { 'nslcd':
                    enable  => true, ensure => running,
                    require => Package['nss-ldap'],
                    before  => Package['nscd'],
                    notify  => [ Exec['nscd-invalidate-passwd'],
                                 Exec['nscd-invalidate-group'], ]
                }
            }
            else {
                package { 'libnss-ldap':
                    ensure => installed,
                    alias  => 'nss-ldap',
                    before => Package['nscd'],
                }
                package { 'libpam-ldap':
                    ensure => installed,
                    alias  => 'pam-ldap',
                    before => Package['nscd'],
                }
                templatelayer { '/etc/libnss-ldap.conf':
                    notify => [ Exec['nscd-invalidate-passwd'],
                                Exec['nscd-invalidate-group'], ],
                }
                templatelayer { '/etc/pam_ldap.conf':
                    notify => [ Exec['nscd-invalidate-passwd'],
                                Exec['nscd-invalidate-group'], ],
                }
            }
        }
        'RedHat': {
            package { 'nss-pam-ldapd': ensure => installed,
                alias => 'nss-ldap',
            }
            # centos7 does not have pam-ldap. functionality collapsed into nss-pam-ldapd
            if versioncmp($::operatingsystemrelease, '7.0') < 0 {
                package { 'pam_ldap': ensure => installed,
                    alias => 'pam-ldap',
                }
                templatelayer { '/etc/libnss-ldap.conf': notify => Service['nslcd'] }
                templatelayer { '/etc/pam_ldap.conf': notify => Service['nslcd'] }
            }
            templatelayer { '/etc/nslcd.conf':
                suffix => $::osfamily,
                notify => Service['nslcd']
            }
            service { 'nslcd':
                enable  => true, ensure => running,
                require => Package['nss-ldap'],
                before  => Package['nscd'],
                notify  => [ Exec['nscd-invalidate-passwd'],
                             Exec['nscd-invalidate-group'], ]
            }
        }
        'Suse': {
            package { 'nss_ldap':
                ensure => installed,
                alias  => 'nss-ldap',
            }
            package { 'pam_ldap':
                ensure => installed,
                alias  => 'pam-ldap',
            }
            templatelayer { '/etc/ldap.conf':
                template => 'master/etc/libnss-ldap.conf',
                notify   => Service['nscd'],
                require  => [ Package['nss_ldap'], Package['pam_ldap'] ],
            }
        }
    }
}
