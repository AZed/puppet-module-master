#
# class master::common::pam
# =========================
#
# Controls files in /etc/pam.d
#
# Also controls /etc/nsswitch.conf
#

class master::common::pam (
    # Parameters
    # ----------
    #
    # ### deny_unspecified
    # ### warn_unspecified
    # Deny unspecified services by default?  If this is set to false,
    # /etc/pam.d/other will fall through to the default authentication
    # for the system.
    #
    # If both $deny_unspecified and $warn_unspecified are true,
    # pam_warn will log attempts to use an unspecified service.
    #
    # NOTE: this can currently only be specified on Debian, where
    # false is the system default, though the default in this class is
    # true.
    $deny_unspecified = true,
    $warn_unspecified = true,

    # ### access_login
    # ### access_sshd
    # Enable special access limits via /etc/security/access.conf for
    # login and ssh respectively
    $access_login = false,
    $access_sshd = false,

    # ### authmech
    # Authentication mechanism to use on top of pam_unix
    #
    # Valid values are:
    #   ldap
    #   sss
    #
    # There is an experimental support for 'radius' as well, but it is
    # untested and likely to be broken.
    $authmech = undef,

    # ### authmech_nss_shadow
    # ### authmech_nss_services
    # ### authmech_nss_sudoers
    # Use the specified auth mechanism for various NSS entries?
    #
    # Adding ldap to the shadow entry will enable tools like
    # getent and such to be able to percieve ldap accounts as
    # having a shadow entry.  This has the cascade effect of
    # causing pam_unix to percieve the shadow entry as well.
    #
    # Be sure you understand the consequences of this -- incorrect
    # usage can prevent password expirations from being displayed and
    # break sudo or su access.
    $authmech_nss_shadow = false,
    $authmech_nss_services = false,
    $authmech_nss_sudoers = false,

    # ### cracklib
    # Use cracklib config in place of pwquality?
    # (pwquality is only available in Debian 8+)
    $cracklib = true,

    # ### pam_mkhomedir
    # Should PAM create home directories for users as needed?
    $pam_mkhomedir = true,

    # ### password_hash
    # Password hash type
    $password_hash = 'sha512',

    # ### password_minlen
    # Minimum password length
    $password_minlen = '10',

    # ### radius
    # RADIUS 2-factor configuration
    #
    # This is intended for use in addition to $authmech, where
    # dual-factor authentication is desired.  If you want to use
    # RADIUS for primary authentication, set
    # master::common::pam::authmech: 'radius' and leave this as an
    # empty hash.
    #
    # Hash values in hiera are merged.
    #
    # $radius is a hash of values where valid keys are:
    #   prompt
    #     - authentication prompt string for pam_radius v1.4 and later
    #   shared_secret
    #     - safety string that must be true for this to enable
    #     - this does NOT configure RADIUS -- the expected use is to
    #       use hiera interpolation to automatically become true if a
    #       variable was set in another class
    #   sshd
    #     - make pam_radius a requisite for the primary SSH daemon
    #   sudo
    #     - make pam_radius a requisite for sudo
    #
    # ### ONLY UNCOMMENT AFTER PUPPET 4 (and remove from main) ###
    # $radius = hiera_hash('master::common::pam::radius',{}),

    # $script is a hash of values where they keys are the pam.d files
    # to modify and the values are the pam_script directory to use.
    #
    # Currently supported keys are:
    #   sshd
    #
    # Example:
    #
    #     master::common::pam::script:
    #       sshd: '/usr/share/libpam-script'
    #
    # This parameter has no effect on Suse
    # ### ONLY UNCOMMENT AFTER PUPPET 4 (and remove from main) ###
    # $script = hiera_hash('master::common::pam::script',{}),

    # ### sshd_deny_root
    # Special case of sshd_deny_users below -- default to blocking all
    # attempts to log in via root (including via public key) if the
    # root password is not set in hiera.
    #
    # You MUST manually set this to false if you want to lock the root
    # account password but allow key-based access!
    $sshd_deny_root = !hiera('master::common::root::password',false),

    # ### sshd_deny_users
    # Users to deny SSH access to via pam_listfile (populates
    # /etc/ssh/deny.users)
    $sshd_deny_users = [],

    # ### sshd_deny_users_templates
    # Template fragments to transclude into /etc/ssh/deny.users
    #
    # If you want to block all login attempts to common system
    # accounts that should never under normal circumstances ever need
    # a shell, add the following config:
    #
    #     master::common::pam::sshd_deny_users_templates:
    #       - 'master/etc/ssh/deny.users-common'
    $sshd_deny_users_templates = [],

    # ### sshd_succeed_if
    # An array of conditions that must be met for SSH access to be
    # granted.  Only the conditions need to be specified, e.g.:
    #
    #     master::common::pam::sshd_succeed_if:
    #       - 'user ingroup mygroup'
    #
    # generates
    #
    #     auth requisite pam_succeed_if.so user ingroup mygroup
    #
    # Array syntax isn't required if you only want one entry:
    #
    #     master::common::pam::sshd_succeed_if: 'user ingroup mygroup'
    #
    $sshd_succeed_if = false,
)
{
    # Code
    # ----
    #
    # hiera_hash can only be used in the body prior to Puppet 4
    #
    $radius = hiera_hash('master::common::pam::radius',{})
    $script = hiera_hash('master::common::pam::script',{})

    # Check for valid auth mechanisms and fail hard immediately if one
    # isn't found to prevent writing an unusable PAM configuration.
    #
    if $authmech {
        case $authmech {
            'ldap': {
                include master::client::pamldap
            }
            'radius': {}
            'sss': {
                include master::service::sssd
            }
            default: {
                fail("Not a valid auth mechanism: '${authmech}'")
            }
        }
    }

    file { '/etc/pam.d':
        owner => root, group => root,
        recurse => true,
    }

    # This isn't part of PAM, but it's more convenient to handle it here
    templatelayer { '/etc/nsswitch.conf': }

    # Templates common to all systems
    templatelayer { '/etc/pam.d/chfn': suffix => $::osfamily }
    templatelayer { '/etc/pam.d/chsh': suffix => $::osfamily }
    templatelayer { '/etc/pam.d/login': suffix => $::osfamily }
    templatelayer { '/etc/pam.d/other': suffix => $::osfamily }
    templatelayer { '/etc/pam.d/passwd': suffix => $::osfamily }
    templatelayer { '/etc/pam.d/sshd': suffix => $::osfamily }
    templatelayer { '/etc/pam.d/su': suffix => $::osfamily }
    templatelayer { '/etc/pam.d/sudo': suffix => $::osfamily }

    if $sshd_deny_root or $sshd_deny_users or $sshd_deny_users_templates {
        # This requires that /etc/ssh already exist, which it may not
        # if no SSH class is invoked, but we can't forcibly include
        # master::common::ssh here because that will preclude
        # alternate implementations and this is a core common class.
        templatelayer { '/etc/ssh/deny.users': }
    }

    case $::osfamily {
        'Debian': {
            package { 'libpam-cap': }
            package { 'libpam-cracklib': }
            package { 'libpam-script': }

            if versioncmp($::operatingsystemrelease, '8.0') >= 0 {
                package { 'libpam-pwquality': }
            }
            templatelayer { '/etc/pam.d/common-account':
                suffix => $::osfamily
            }
            templatelayer { '/etc/pam.d/common-auth':
                suffix => $::osfamily
            }
            templatelayer { '/etc/pam.d/common-password':
                suffix => $::osfamily
            }
            templatelayer { '/etc/pam.d/common-session':
                suffix => $::osfamily
            }
            templatelayer { '/etc/pam.d/cron':
                suffix => $::osfamily
            }
            templatelayer { '/etc/pam.d/postgresql':
                suffix => $::osfamily
            }
            templatelayer { '/etc/pam.d/run_init':
                suffix => $::osfamily
            }
        }
        'RedHat': {
            package { 'cracklib': }
            package { 'cracklib-dicts': }
            package { 'pam_script': }

            file { '/etc/pam.d/system-auth': ensure => 'system-auth-ac' }
            file { '/etc/pam.d/password-auth': ensure => 'password-auth-ac' }
            file { '/etc/pam.d/password-auth-ac': ensure => 'system-auth-ac' }
            file { '/etc/pam.d/fingerprint-auth': ensure => 'fingerprint-auth-ac' }
            file { '/etc/pam.d/smartcard-auth': ensure => 'smartcard-auth-ac' }

            templatelayer { '/etc/pam.d/config-util':
                suffix => $::osfamily
            }
            templatelayer { '/etc/pam.d/crond':
                suffix => $::osfamily
            }
            templatelayer { '/etc/pam.d/halt':
                suffix => $::osfamily
            }
            templatelayer { '/etc/pam.d/kbdrate':
                suffix => $::osfamily
            }
            templatelayer { '/etc/pam.d/newrole':
                suffix => $::osfamily
            }
            templatelayer { '/etc/pam.d/fingerprint-auth-ac':
                suffix => $::osfamily
            }
            templatelayer { '/etc/pam.d/run_init':
                suffix => $::osfamily
            }
            templatelayer { '/etc/pam.d/smartcard-auth-ac':
                suffix => $::osfamily
            }
            templatelayer { '/etc/pam.d/system-auth-ac':
                suffix => $::osfamily
            }
        }
        'Suse': {
            package { 'cracklib': }
            package { 'cracklib-dict-full': }

            templatelayer { '/etc/pam.d/common-account-pc':
                suffix => $::osfamily
            }
            templatelayer { '/etc/pam.d/common-auth-pc':
                suffix => $::osfamily
            }
            templatelayer { '/etc/pam.d/common-password-pc':
                suffix => $::osfamily
            }
            templatelayer { '/etc/pam.d/common-session-pc':
                suffix => $::osfamily
            }
        }
        default: { }
    }
}
