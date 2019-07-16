#
# master::service::saslauth
#
# Sets up a Cyrus SASL authentication service
#

class master::service::saslauth (
    # Enable or disable the service
    $enable = $::osfamily ? {
        'Debian' => true,
        'RedHat' => true,
        default  => false,
    },

    # Enforce a specific GID for the SASL group
    #
    # Setting this to a number below 200 is extremely likely to cause
    # a problem on the next system rebuild.
    $gid = undef,

    # Which users have group membership with SASL (array)
    #
    # If you want to use Postfix SASL auth, you must add 'postfix'
    $groupmembers = undef,

    # Auth mechanism
    $mech = 'pam',

    # Additional options
    #
    # These override the default and if done wrong CAN PREVENT THE
    # SYSTEM FROM BOOTING, so be sure you understand this before
    # modifying
    #
    # The default value is set to support a chrooted Postfix (even if
    # Postfix is not installed).  Despite this, Postfix SASL does not
    # work with this, though it still works fine for testsaslauthd.
    #
    $options = '-c -m /var/spool/postfix/var/run/saslauthd',
) {
    include master::service::postfix::dirs

    case $::osfamily {
        'Debian': {
            package { 'saslauthd':
                name => 'sasl2-bin',
            }
            $saslgroup = 'sasl'
            templatelayer { '/etc/default/saslauthd': }
        }
        'RedHat': {
            package { 'saslauthd':
                name => 'cyrus-sasl',
            }
            $saslgroup = 'saslauth'
            templatelayer { '/etc/sysconfig/saslauthd': }
            file { '/etc/pam.d/smtp':
                ensure => link,
                target => 'system-auth',
            }
        }
        default: {
            notify { "${title}-unsupported-os":
                message => "ERROR: ${title} is not configured for ${::operatingsystem}!",
                loglevel => err,
            }
        }
    }

    if $enable {
        group { $saslgroup:
            ensure  => present,
            gid     => $gid,
            members => $groupmembers,
            require => Package['saslauthd']
        }
        file { '/var/spool/postfix/var/run/saslauthd':
            ensure  => directory,
            owner   => root,
            group   => $saslgroup,
            require => Group[$saslgroup],
        }
        file { '/var/run/saslauthd':
            ensure  => link,
            target  => '/var/spool/postfix/var/run/saslauthd',
            force   => true,
            require => File['/var/spool/postfix/var/run/saslauthd'],
        }
        service { 'saslauthd':
            ensure => running,
            enable => true,
            require => File['/var/run/saslauthd'],
        }
    }
    else {
        service { 'saslauthd':
            ensure => stopped,
            enable => false,
        }
    }
}
