#
# class master::service::sssd
# ===========================
#
# Sets up the System Security Services Daemon
#
# This will only set up the daemon.  Use master::common::pam to enable
# it for authentication.
#
# This uses master::client::ldap for its base configuration, though
# that can be bypassed if necessary.
#
# This conflicts with master::service::nscd.
#

class master::service::sssd (
    # Parameters
    # ----------
    #
    # ### templates
    # Templates to replace the contents of /etc/sssd/sssd.conf
    $templates = undef,

    # ### final_templates
    # Templates to append to the end of /etc/sssd/sssd.conf
    $final_templates = undef,

    # ### full_name_format
    # A printf(3)-compatible format that describes how to translate a
    # (name, domain) tuple into a fully qualified name.
    $full_name_format = undef,

    # ### re_expression
    # Regular expression that describes how to parse the string
    # containing user name and domain into these components.
    $re_expression = undef,

    # ### reconnection_retries
    # Number of times services should attempt to reconnect in the
    # event of a Data Provider crash or restart before they
    # give up
    $reconnection_retries = '3',

    # ### services
    # Services to enable
    $services = [ 'nss', 'pam' ],

    # ### nss
    # ### pam
    # NSS and PAM configuration options are treated as hiera-merged
    # hashes, with keys holding the parameter names and the values
    # holding the values.  Values in array format will be
    # automatically converted to comma-separated strings.
    #
    # As an example, the hiera equivalent of the default $nss value is:
    #   master::service::sssd::nss:
    #     filter_groups:
    #       - root
    #       - bind
    #       - openldap
    #       - postfix
    #     filter_users:
    #       - root
    #       - bind
    #       - openldap
    #       - postfix
    $nss = hiera_hash('master::service::sssd::nss', {
        filter_groups => 'root, bind, openldap, postfix',
        filter_users => 'root, bind, openldap, postfix',
        }),
    $pam = hiera_hash('master::service::sssd::pam',{}),

    # ### domains_enabled
    # Domains to enable - SSSD will not start if no domains are configured
    $domains_enabled = [ 'LDAP', ],

    # ### domains
    # Domain configuration
    #
    # The format of this variable is an array of hashes, where the key
    # 'name' provides the name of the domain, and the remaining keys
    # are configuration values for that domain, e.g.:
    #
    #   master::service::sssd::domains:
    #     - name: 'LDAP'
    #       id_provider: 'ldap'
    #       auth_provider: 'ldap'
    #       ldap_access_order: 'host'
    #     - name: 'AD'
    #       id_provider: 'ldap'
    #       auth_provider: 'krb5'
    #
    # Most options are supported.  By default, SSSD will be configured
    # as a RFC2307 LDAP client using values from master::client::ldap,
    # with sudo lookups disabled.
    #
    # Note that the default LDAP access order is 'filter', and the
    # default filter is '(objectClass=posixAccount)' (i.e. any valid
    # account).  If you want to use LDAP host entries for control, you
    # must specify ldap-access_order: 'host' as in the above example.
    $domains = [ { name => 'LDAP', } ],
){
    # Code
    # ----
    include master::client::ldap

    $ldap_uri_default = $master::client::ldap::uri
    $ldap_base_default = $master::client::ldap::base
    $ldap_cacert_default = $master::client::ldap::cacert
    $ldap_reqcert_default = $master::client::ldap::reqcert
    $ldap_cipher_suite_default = $master::client::ldap::cipher_suite

    package { 'sssd': }
    templatelayer { '/etc/sssd/sssd.conf':
        # Older versions of SSSD are really picky about the
        # permissions of sssd.conf and will refuse to start if
        # sssd.conf is 0400 instead of 0600
        mode    => '0600',
        require => Package['sssd'],
        notify  => Service['sssd'],
    }
    service { 'sssd':
        ensure => running,
        enable => true,
        require => Service['nscd'],
    }

    package { 'nscd': ensure => absent }
    service { 'nscd':
        ensure => stopped,
        enable => false,
    }

    # RedHat-based systems that previously used nss-pam-ldapd will
    # need that removed to remove nscd
    package { 'nss-pam-ldapd':
        ensure => absent,
        before => Package['nscd']
    }


    # Debian Stretch SELinux fixup for sssd
    #
    if ( $::selinux ) and ( $::lsbdistcodename == "stretch" )  {
        include master::common::selinux
        selinux_enable_module {"systemd-sssd": }
    }

}
