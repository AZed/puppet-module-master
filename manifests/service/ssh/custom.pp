#
# class master::service::ssh::custom
#
# Provide an additional ssh daemon running on a custom port.  This
# will require that the standard ssh service is installed and running.
#
# This is DEPRECATED and does not allow as much customization as
# master::service::ssh or master::sshd.  Use those instead.
#
# The default for this class is to only allow key-based auth.  You can
# tune this with the "pam" and "pubkeyauth" parameters.
#

class master::service::ssh::custom (
    # Location of the authorized keys file (including any macros)
    $authorizedkeysfile = "%h/.ssh/authorized_keys",

    # Space-separated list of allowed users on the custom sshd.  If set to
    # false, no AllowUsers line will be created in /etc/ssh/sshd_config,
    # and all users will be allowed to log in.
    $allowusers = false,

    # ClientAliveInterval (integer seconds)
    $clientaliveinterval = 120,

    # Use password authentication? (valid values are "yes" and "no")
    # Despite the name, this won't actually set "UsePAM".  It will set
    # "PasswordAuthentication" and "ChallengeResponseAuth"
    $pam = "no",

    # What port the custom sshd will run on.
    $port = 22223,

    # Allow public key authentication.  Valid values are "yes" and "no"
    $pubkeyauth = 'yes'
)
{
    notify { "deprecated-${title}":
        message => "DEPRECATED: use master::service::ssh::alt instead",
        loglevel => warning,
    }

    file { '/etc/ssh/sshd_config-custom': ensure => absent }

    master::sshd { "p${port}":
        execname    => 'sshd',
        servicename => 'ssh-custom',
        conf => {
            'AllowUsers'                      => $allowusers,
            'AuthorizedKeysFile'              => $authorizedkeysfile,
            'ClientAliveInterval'             => $clientaliveinterval,
            'PubkeyAuthentication'            => $pubkeyauth,
            'PasswordAuthentication'          => $pam,
            'ChallengeResponseAuthentication' => $pam,
        },
    }
}
