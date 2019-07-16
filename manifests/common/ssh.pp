#
# class master::common::ssh
# =========================
#
# Ensure that a ssh client is set up and configured
#
# WARNING:
#
# Suse-based systems keep the client and the server in the same
# package.  Using this class on such an OS will therefore start a
# listening port!
#
class master::common::ssh (
    # Parameters
    # ----------
    # ### known_hosts_templates
    # Template fragments to include in /etc/ssh/ssh_known_hosts
    $known_hosts_templates = [ ],

    # ### ssh_config_defaults
    # Configuration values applied to the Host * entry in hash format,
    # e.g.:
    #
    #     master::common::ssh::ssh_config_defaults:
    #           SendEnv: 'LANG LC_*'
    #           HashKnownHosts: 'yes'
    #           GSSAPIAuthentication: 'yes'
    #
    # This is a merged hiera hash to allow values to be added and
    # removed from a base definition.  Note that the very first hiera
    # entry to be found will REPLACE the default (shown above),
    # however, so start with that in your common.yaml unless you
    # actually intend to strip out these defaults.
    #
    $ssh_config_defaults = hiera_hash('master::common::ssh::ssh_config_defaults', {
        'Protocol'             => '2',
        'SendEnv'              => 'LANG LC_*',
        'HashKnownHosts'       => 'yes',
        'GSSAPIAuthentication' => 'yes',
    }
    ),

    # ### ssh_config_hosts
    # Host entries in hash+array format, e.g.:
    #
    #     master::common::ssh::ssh_config_hosts:
    #       'host1 host2prefix*':
    #         - 'ForwardX11Trusted yes'
    #         - 'Port 2222'
    #
    # Note that unlike ssh_config_defaults the config values are
    # straight strings here, and not a hiera-merged hash.  This is to
    # allow for comment lines to be inserted.
    #
    $ssh_config_hosts = undef,

    # ### ssh_config_templates
    # Template fragments to include in /etc/ssh/ssh_config
    $ssh_config_templates = [ ]
)
{
    # Code
    # ----

    Package { ensure => installed }
    case $::osfamily {
        'RedHat': {
            package { 'openssh': }
            package { 'openssh-clients': }
        }
        'Debian': {
            package { 'openssh-client': }
            package { 'keychain': }
        }
        'Suse': {
            # WARNING: the SLES openssh package includes both client and server!
            package { 'openssh': alias => 'openssh-server' }
        }
    }

    file { '/etc/ssh':
        ensure => directory,
        owner => root, group => root, mode => '0755',
    }
    templatelayer { '/etc/ssh/ssh_config': }
    templatelayer { '/etc/ssh/ssh_known_hosts': }

    # Helper tool to set up or find an SSH agent
    # TODO: deprecate this in favor of keychain?
    file { '/usr/local/bin/sshagent':
        owner => root, group => root, mode => '0755',
        source => 'puppet:///modules/master/usr/local/bin/sshagent'
    }
}
