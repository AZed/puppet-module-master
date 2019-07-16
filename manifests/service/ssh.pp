#
# class master::service::ssh
# ==========================
#
# Sets up one or more SSH daemons
#
# See also: master::sshd
#
# If you want to allow root logins (even via public key) but have not
# set a root password via master::common::root::password, you MUST set
#
#     master::common::pam::deny_root: false
#
# Example of a complex setup:
#
#     master::service::ssh::config:
#       Banner: '/etc/issue.net'
#       ClientAliveInterval: '120'
#       PermitRootLogin: 'no'
#       Match:
#         - type: 'User'
#           list:
#           - shelluser1,
#           - shelluser2,
#           - shelluser3'
#           not: true
#           rules:
#           - 'ForceCommand /usr/local/sbin/restricted_sleep'
#         - type: 'Group'
#           list:
#           - 'specialgroup'
#           rules:
#           - 'PermitOpen any'
#           - 'X11Forwarding yes'
#     master::service::ssh::alt:
#       p2222:
#         execname: 'sshalt'
#         servicename: 'sshalt'
#         pam_radius: false
#         conf:
#           PermitRootLogin: 'yes'
#       p2223:
#         final_templates: 'mymodule/etc/ssh/match_this.erb'
#
# Read below for fine details
#

class master::service::ssh (
    # Parameters
    # ----------
    #
    # ### disable
    #
    # If this is set to true, then the main SSH service will not be
    # handled.  Any specified alt entries will still be enabled.
    $disable = false,

    #
    # ### templates
    # Templates that will be used by default to construct
    # /etc/ssh/sshd_config by default and any alternate servers
    # created by master::sshd
    #
    # If specified, this REPLACES the default configuration template
    # and can be used to completely customize the sshd_config files
    $templates = undef,

    # ### final_templates
    # Templates that will be appended by default to
    # /etc/ssh/sshd_config and any alternate servers created by
    # master::sshd
    $final_templates = undef,

    # ### port
    # The port for the default SSH daemon
    $port = '22',

    # ### config
    # $config is a merged hash containing all remaining configuration
    # information used in sshd_config.  If specified, it will be used
    # as the default for any alternate servers created by
    # master::sshd.
    #
    # Due to a puppet limitation, it MUST be specified in Hiera, and
    # cannot be specified via class notation.  This may change in Puppet 4.
    #
    # All keys match the sshd_config keys and are case sensitive.  The
    # following keys must be specified in array format if specified at all:
    #
    # * AcceptEnv
    # * HostKey
    # * ListenAddress
    # * Match
    #
    # Match keys are handled specially via additional keys:
    #
    # * type: can be User, Group, Host, LocalAddress, LocalPort, or Address
    # * list: array of members of the above type
    # * not: if true, match everything *except* the list members
    # * rules: rules to apply to the match
    #
    # Example:
    #
    #     master::service::ssh::config:
    #       Match:
    #         - type: 'User'
    #           list:
    #           - shelluser1,
    #           - shelluser2,
    #           - shelluser3'
    #           not: true
    #           rules:
    #             - 'ForceCommand /usr/local/sbin/restricted_sleep'
    #         - type: 'Group'
    #           list:
    #             - 'specialgroup'
    #           rules:
    #             - 'PermitOpen any'
    #             - 'X11Forwarding yes'
    #
    # WARNING: enabling PubkeyAuthentication will bypass dual-factor
    # authentication even with:
    #
    #     master::common::pam::radius:
    #       sshd: true
    #
    # If left unspecified, it will default to disabled if
    # radius sshd is true, and enabled otherwise.
    #
    # ### config
    # DO NOT UNCOMMENT UNTIL PUPPET 4 (it is in the body)
    # $config = hiera_hash('master::service::ssh::config',{}),

    # ### alt
    # This is a hash of resource parameters for additional
    # master::sshd instances.  The first key must always be:
    #
    #     p<portnumber>
    #
    # By default, the name of the linked executable is 'sshd-<port>'
    # and the name of the service is 'ssh-<port>', meaning that by
    # default an alternate port will use separate hosts.allow entries.
    # These can be changed with the 'execname' and 'servicename' keys
    # respectively.  To have alternate ports use the same hosts.allow
    # rules as the main SSH port, set execname to 'sshd'.
    #
    # The remaining keys are 'pam_radius', 'templates',
    # 'final_templates', and 'conf' (not config!), e.g.:
    #
    #     master::service::ssh::alt:
    #       p2222:
    #         execname: 'sshalt'
    #         servicename: 'sshalt'
    #         pam_radius: false
    #         conf:
    #           PermitRootLogin: 'yes'
    #       p2223:
    #         final_templates:
    #           - 'mymodule/etc/ssh/match_this.erb'
    #
    # Keys specified in an alt config are merged with the keys
    # specifed in master::service::ssh::config, overwriting existing
    # keys and adding new ones.  To remove a key, overwrite it with
    # nil.  The alt key itself is also merged with any other alt keys
    # found.
    #
    # For more detail, see master::sshd
    # DO NOT UNCOMMENT UNTIL PUPPET 4 (it is in the body)
    # $alt = hiera_hash('master::service::ssh::alt',undef),

    # ### generate_host_keys
    # Generate supported types of SSH host keys if they are missing?
    # If keys are specified in host_keys below or if nodefiles are
    # found, they will be used instead.
    $generate_host_keys = true,

    # ### host_keys
    # Specification of SSH host keys
    #
    # This is a hash with the following possible keys:
    #
    # * ecdsa
    # * ecdsa_pub
    # * ed25519
    # * ed25519_pub
    # * rsa
    # * rsa_pub
    #
    # If specified, the matching host key files will be generated with
    # the matching values.  If a nodefile is present, it will override
    # this whether or not it is specified.  If neither nodefile nor
    # hiera entry is present, and the key does not already exist on
    # the filesystem, it will be automatically generated if supported.
    #
    # Use of the | and >- styles in Hiera to automatically handle long
    # text is recommended.
    $host_keys = undef,

    # ### version
    # Override the detected version of OpenSSH
    $version = $::operatingsystem ? {
        'Debian' => $::operatingsystemmajrelease ? {
            '6'     => '5.5',
            '7'     => '6.0',
            '8'     => '6.7',
            '9'     => '7.4',
            default => '7.4',
        },
        /(CentOS|RedHat)/ => $::operatingsystemmajrelease ? {
            '6'     => '5.3',
            '7'     => '6.6',
            default => '6.6',
        },
        'SLES' => $::operatingsystemmajrelease ? {
            '11'    => '6.6',
            '12'    => $::operatingsystemrelease ? {
                '12.0'  => '6.6',
                '12.1'  => '6.6',
                default => '7.2',
            },
            default => '6.6',
        },
        default  => '6.6',
    },
)
{
    # Code Comments
    # -------------

    require master::common::pam
    include master::common::ssh

    $config = hiera_hash('master::service::ssh::config',{})
    $alt = hiera_hash('master::service::ssh::alt',undef)
    $pam_radius = $master::common::pam::radius
    $radius = $pam_radius

    case $::operatingsystem {
        'sles': {
            # SLES has a server included in the 'openssh' package from common::ssh
        }
        default: {
            package { 'openssh-server': }
        }
    }

    templatelayer { '/etc/ssh/sshd_config':
        owner => 'root', group => 'root', mode => '0400',
        notify => Service['ssh'],
    }

    # SSH Host Keys

    if versioncmp($version, '6.5') >= 0 {
        if nodefile_exists('/etc/ssh/ssh_host_ed25519_key') {
            nodefile { '/etc/ssh/ssh_host_ed25519_key':
                mode    => '0600',
                notify  => Service['ssh'],
            }
        }
        elsif $host_keys and $host_keys['ed25519'] {
            file { '/etc/ssh/ssh_host_ed25519_key':
                content => $host_keys['ed25519'],
                mode    => '0600',
                notify  => Service['ssh'],
            }
        }
        elsif $generate_host_keys {
            exec { 'ssh_generate_host_key_ed25519':
                cwd     => '/etc/ssh',
                command => 'ssh-keygen -f ssh_host_ed25519_key -N "" -t ed25519',
                path    => '/usr/bin:/bin',
                creates => [ '/etc/ssh/ssh_host_ed25519_key',
                             '/etc/ssh/ssh_host_ed25519_key.pub',
                           ],
                notify  => Service['ssh'],
            }
        }
        if nodefile_exists('/etc/ssh/ssh_host_ed25519_key.pub') {
            nodefile { '/etc/ssh/ssh_host_ed25519_key.pub':
                notify  => Service['ssh'],
            }
        }
        elsif $host_keys and $host_keys['ed25519_pub'] {
            file { '/etc/ssh/ssh_host_ed25519_key.pub':
                content => $host_keys['ed25519_pub'],
                notify  => Service['ssh'],
            }
        }
    }
    if versioncmp($version, '6.0') >= 0 {
        if nodefile_exists('/etc/ssh/ssh_host_ecdsa_key') {
            nodefile { '/etc/ssh/ssh_host_ecdsa_key':
                mode    => '0600',
                notify => Service['ssh']
            }
        }
        elsif $host_keys and $host_keys['ecdsa'] {
            file { '/etc/ssh/ssh_host_ecdsa_key':
                content => $host_keys['ecdsa'],
                mode    => '0600',
                notify  => Service['ssh'],
            }
        }
        elsif $generate_host_keys {
            exec { 'ssh_generate_host_key_ecdsa':
                cwd     => '/etc/ssh',
                command => 'ssh-keygen -f ssh_host_ecdsa_key -N "" -t ecdsa',
                path    => '/usr/bin:/bin',
                creates => [ '/etc/ssh/ssh_host_ecdsa_key',
                             '/etc/ssh/ssh_host_ecdsa_key.pub',
                           ],
                notify  => Service['ssh'],
            }
        }
        if nodefile_exists('/etc/ssh/ssh_host_ecdsa_key.pub') {
            nodefile { '/etc/ssh/ssh_host_ecdsa_key.pub':
                notify  => Service['ssh'],
            }
        }
        elsif $host_keys and $host_keys['ecdsa_pub'] {
            file { '/etc/ssh/ssh_host_ecdsa_key.pub':
                content => $host_keys['ecdsa_pub'],
                notify  => Service['ssh'],
            }
        }
    }

    if nodefile_exists('/etc/ssh/ssh_host_rsa_key') {
        nodefile { '/etc/ssh/ssh_host_rsa_key':
            mode    => '0600',
            notify  => Service['ssh'],
        }
    }
    elsif $host_keys and $host_keys['rsa'] {
        file { '/etc/ssh/ssh_host_rsa_key':
            content => $host_keys['rsa'],
            mode    => '0600',
            notify  => Service['ssh'],
        }
    }
    elsif $generate_host_keys {
        exec { 'ssh_generate_host_key_rsa':
            cwd     => '/etc/ssh',
            command => 'ssh-keygen -f ssh_host_rsa_key -N "" -t rsa',
            path    => '/usr/bin:/bin',
            creates => [ '/etc/ssh/ssh_host_rsa_key',
                         '/etc/ssh/ssh_host_rsa_key.pub',
                       ],
            notify  => Service['ssh'],
        }
    }
    if nodefile_exists('/etc/ssh/ssh_host_rsa_key.pub') {
        nodefile { '/etc/ssh/ssh_host_rsa_key.pub':
            notify  => Service['ssh'],
        }
    }
    elsif $host_keys and $host_keys['rsa_pub'] {
        file { '/etc/ssh/ssh_host_rsa_key.pub':
            content => $host_keys['rsa_pub'],
            notify  => Service['ssh'],
        }
    }

    # Main SSH service
    #
    # The default service name is 'ssh' under Debian, but 'sshd'
    # almost everywhere else, but we want service dependencies
    # elsewhere in puppet to be able to use either name.
    case $::osfamily {
        'Debian': {
            $default_servicename = 'ssh'
            $default_servicealias = 'sshd'
        }
        default: {
            $default_servicename = 'sshd'
            $default_servicealias = 'ssh'
        }
    }
    if $disable {
        service { $default_servicename:
            ensure    => stopped,
            enable    => false,
            alias     => $default_servicealias,
            hasstatus => true,
            require   => [ Package['openssh-server'],
                           Templatelayer['/etc/ssh/sshd_config'],
                         ],
        }
    }
    else {
        service { $default_servicename:
            ensure    => running,
            enable    => true,
            alias     => $default_servicealias,
            hasstatus => true,
            require   => [ Package['openssh-server'],
                           Templatelayer['/etc/ssh/sshd_config'],
                         ],
        }
    }

    # Alternate port handling
    file { '/etc/ssh/alt':
        ensure  => directory,
        mode    => '0755',
        backup  => false,
        force   => true,
        purge   => true,
        recurse => true,
    }
    if $alt and is_hash($alt) {
        create_resources(master::sshd,$alt)
    }

    # Script to display warning message about restricted shell and then
    # sleep (useful for setting up restricted tunnels)
    master::file { '/usr/local/sbin/restricted_sleep': mode => '0755', }

    # Script to restrict SSH sessions to version-control commands only.
    master::file { '/usr/local/sbin/ssh_restrict_vc': mode => '0755', }

    master::nagios_check { '20_Proc_sshd': }

    if ( $::selinux == true )
    and ($master::service::ssh::x11forwarding == true )
    and  ($::operatingsystem == 'centos')
    and (versioncmp($::operatingsystemrelease, '7.0') >= 0) {
        selboolean { 'nis_enabled':
            persistent => true,
            value      => on
        }
    }
}
