#
# class master::service::postfix
# ==============================
#
# Installs and configures a Postfix mail server.
#
# This class relies on:
#   master::common::base (for /etc/mailname)
#   master::common::mta (for default values)
#   master::common::package_management (for repo preconfiguration)
#
# It has an intimidating number of individual parameters, but they can
# also be managed by template fragments if preferred.
#

class master::service::postfix (
    # Parameters
    # ----------
    #
    # ### main_cf_templates
    # ### master_cf_templates
    # Instead of using full parameter-based configuration below, it is
    # possible to completely override the main.cf and master.cf
    # configuration with arrays of template fragments
    $main_cf_templates = false,
    $master_cf_templates = false,

    # ### main_cf_templates_final
    # ### master_cf_templates_final
    # If you want to append additional templates to the default
    # generated ones, use these:
    $main_cf_templates_final = false,
    $master_cf_templates_final = false,

    # ### myhostname
    # Name of the server as far as mail is concerned
    $myhostname = $::fqdn,

    # ### mydestination
    # Accept mail from the following array of hostnames
    $mydestination = $master::common::mta::destinations,

    # ### pcre_destination
    # Generate an automatically anchored PCRE table of destinations
    # from the following array of regular expressions
    $pcre_destination = false,

    # ### inet_protocols
    # Set this to 'ipv4' to prevent slowdown from failing to connect on ipv6
    $inet_protocols = $master::common::mta::inet_protocols,

    # ### interfaces
    # ### mynetworks
    # ### origin
    # ### relayhost
    # As named
    $interfaces     = $master::common::mta::interfaces,
    $mynetworks     = $master::common::mta::trusted_networks,
    $origin         = $master::common::mta::maildomain,
    $relayhost      = $master::common::mta::relayhost,

    # ### mailbox_size_limit
    # ### message_size_limit
    # Mailbox and message size limits in bytes
    $mailbox_size_limit = $master::common::mta::mailbox_size_limit,
    $message_size_limit = $master::common::mta::message_size_limit,

    # ### chroot
    # Operate in a chroot?  This improves security, but can break addons
    # It's set up by default in Debian
    $chroot = $::osfamily ? {
        'Debian' => true,
        default  => false,
    },

    # ### defer
    # Should all outgoing mail be deferred, forcing 'sendmail -q' for
    # delivery or equivalent?  This can be used for testing.
    $defer = false,

    # ### tls
    # Use TLS?  Valid values are 'may', 'encrypt', or false
    $tls = $::osfamily ? {
        'Debian' => 'may',
        'RedHat' => 'may',
        default  => false,
    },
    # ### tls_cert_file
    # ### tls_key_file
    # Certificate and key files to use if TLS is enabled
    $tls_cert_file = hiera('master::common::ssl::cert_file',$::osfamily ? {
        'Debian' => '/etc/ssl/certs/ssl-cert-snakeoil.pem',
        'RedHat' => '/etc/pki/tls/certs/localhost.crt',
        default  => undef,
    }
                          ),
    $tls_key_file = hiera('master::common::ssl::key_file',$::osfamily ? {
        'Debian' => '/etc/ssl/private/ssl-cert-snakeoil.key',
        'RedHat' => '/etc/pki/tls/private/localhost.key',
        default  => undef,
    }
                         ),

    # ### tls_ciphers
    # ### tls_exclude_ciphers
    # ### tls_protocols
    # TLS security settings for $tls = 'may' or $tls = 'encrypt'
    #
    # These may be specified either as a comma-separated string or as
    # an array
    $tls_ciphers = undef,
    $tls_exclude_ciphers = undef,
    $tls_protocols = undef,

    # ### tls_mandatory_ciphers
    # ### tls_mandatory_exclude_ciphers
    # ### tls_mandatory_protocols
    # TLS security settings only for when $tls = 'encrypt'
    #
    # The defaults here differ from Postfix defaults in that the
    # weakest ciphers are excluded by default when encryption is
    # mandatory, where Postfix by default would allow them.
    $tls_mandatory_ciphers = undef,
    $tls_mandatory_exclude_ciphers = [ 'aNULL',
                                       'DES',
                                       '3DES',
                                       'RC4',
                                       'SSLv2',
                                       'SSLv3',
                                       'TLSv1'
                                     ],
    $tls_mandatory_protocols = undef,

    # ## SASL Auth Parameters
    # ### smtpd_sasl_auth_enable
    # If smtpd_sasl_auth_enable is false, the rest have no effect
    $smtpd_sasl_auth_enable = false,
    # ### smtpd_sasl_local_domain
    # ### smtpd_sasl_path
    $smtpd_sasl_local_domain = '',
    $smtpd_sasl_path = 'private/auth',
    # ### smtpd_sasl_security_options
    # ### smtpd_sasl_tls_security_options
    # If you are planning to set $smtpd_tls_auth_only to false, below,
    # and aren't delivering from external connections, you might want
    # to set these to:
    #   $smtpd_sasl_security_options = 'noanonymous, noplaintext',
    #   $smtpd_sasl_tls_security_options = 'noanonymous',
    $smtpd_sasl_security_options = 'noanonymous',
    $smtpd_sasl_tls_security_options = undef,
    # ### smtpd_sasl_type
    # Supported types are 'cyrus' and 'dovecot', and will invoke
    # master::service::saslauth and master::service::dovecot
    # respectively
    #
    # Although Dovecot is heavier, unfortunately I cannot get Cyrus
    # saslauthd to reliably work in a chroot, so the default is to
    # install Dovecot if SASL support is requested.
    $smtpd_sasl_type = 'dovecot',
    # ### smtpd_tls_auth_only
    # Only announce or accept SASL connections over TLS?
    # This will be ignored if $tls is false, above.
    $smtpd_tls_auth_only = true,
    # ### broken_sasl_auth_clients
    # Send two AUTH headers, one standards-compliant and one to
    # support very old and broken Outlook/Outlook Express versions?
    # (This is harmless, but unaesthetic unless you need it.)
    $broken_sasl_auth_clients = false,

    # ## Restriction Parameters
    # ### disable_vrfy_command
    # ### smtpd_client_restrictions
    # ### smtpd_helo_required
    $disable_vrfy_command = true,
    $smtpd_client_restrictions = [ 'permit_mynetworks',
                                   'permit_sasl_authenticated',
                                 ],
    $smtpd_helo_required = false,
    # ### smtpd_helo_restrictions
    # These are not included unless smtpd_helo_required is true, as
    # otherwise senders can simply skip the HELO/EHLO entirely and
    # bypass this.
    $smtpd_helo_restrictions = [ 'permit_mynetworks',
                                 'permit_sasl_authenticated',
                                 'reject_invalid_hostname',
                               ],
    # ### smtpd_helo_warnings
    # These are good to log, but some major internet sites have been
    # known to use broken settings that these will catch.  To hard
    # block them, remove them from this array and add them to
    # smtpd_helo_restrictions instead.  This is also not included
    # unless $smtpd_helo_required is true.
    $smtpd_helo_warnings = [ 'reject_non_fqdn_hostname',
                             'reject_unknown_helo_hostname',
                           ],

    # ### smtpd_relay_restrictions
    # Note that smtpd_recipient_restrictions inherently includes
    # smtpd_relay_restrictions.  In older versions of Postfix, they
    # will be merged into smtpd_recipient_restrictions.
    #
    # The default is to use reject_unauth_destination because
    # defer_unauth_destination requires Postfix 2.10 or later.  To
    # switch to defer, use the following entry in Hiera:
    #
    #     master::service::postfix::smtpd_relay_restrictions:
    #       - 'permit_mynetworks'
    #       - 'permit_sasl_authenticated'
    #       - 'defer_unauth_destination'
    $smtpd_relay_restrictions =
    [ 'permit_mynetworks',
      'permit_sasl_authenticated',
      'reject_unauth_destination',
    ],

    # ### smtpd_recipient_restrictions
    # These restrictions do not include greylisting, SPF, or DNS
    # blacklists, which are handled in separate parameters
    $smtpd_recipient_restrictions =
    [ 'reject_non_fqdn_recipient',
      'reject_unauth_pipelining',
      'reject_unknown_recipient_domain'
    ],

    # ### smtpd_sender_restrictions
    $smtpd_sender_restrictions = [ 'permit_mynetworks',
                                   'permit_sasl_authenticated',
                                 ],

    # ## DNS blacklists
    #
    # ### rbl_clients
    # Traditional IP lookup blocklists
    #
    # Suggested entries for organizations less than < 100,000
    # connections per day:
    #  * `zen.spamhaus.org`: for full coverage blocking
    # or
    #  * `sbl.spamhaus.org`: spam-only blocklist for organizations
    #                        serving outbound relay for customers
    $rbl_clients = [ ],
    # ### rhsbl_clients
    # Client domain-name blacklists.  Entries in these blacklists will
    # be blocked at both HELO and MAIL FROM stages
    #
    # Suggested entries for organizations less than < 100,000
    # connections per day:
    #  * `dbl.spamhaus.org`
    $rhsbl_clients = [ ],

    # ## Optional transports
    # ### submission
    # Port 587 for SMTP Message Submission
    $submission = false,
    # ### submission_alt
    # Alternate port for SMTP Message Submission (e.g. '1587')
    $submission_alt = false,
    # ### smtps
    # Port 465 for SMTPS (deprecated)
    $smtps = false,
    # ### smtps_alt
    # Alternate port for SMTPS (e.g. '1465')
    $smtps_alt = false,
    # ### uucp
    # Unix-to-Unix-Copy, for sites with only intermittent internet connection
    # Enabling this only activates the pipe -- further configuration is needed
    $uucp = false,

    # ## Restriction classes
    #
    # ### smtpd_restriction_classes
    #
    # A hash of arrays, where the key to the hash is the name of the
    # restriction class and the value is an array of restrictions.  To
    # follow the example in Chapter 11 of Postfix: The Definitive
    # Guide, you can use:
    #
    #     smtpd_restriction_classes:
    #       spamhater:
    #         - 'reject_invalid_hostname'
    #         - 'reject_non_fqdn_hostname'
    #         - 'reject_unknown_sender_domain'
    #         - 'reject_rbl_client nospam.example.com'
    #       spamlover:
    #         - 'permit'
    #
    # Note that you will still need to add a check_sender_access or
    # check_recipient_access entry to the $smtpd_sender_restrictions
    # or $smtpd_recipient_restrictions parameters respectively to take
    # advantage of anything defined here.
    $smtpd_restriction_classes = false,

    # ## Transport configuration
    # ### transport_maps
    # Entries must be specified in array form
    $transport_maps = [ 'hash:/etc/postfix/transport', ],
    # ### transport_entries
    # ### transport_templates
    # /etc/postfix/transport is always managed from the contents of
    # $transport_entries and $transport_templates, but it can be
    # bypassed entirely by not including it in $transport_maps and
    # managing files under different names.
    $transport_entries = undef,
    $transport_templates = undef,

    # ## Virtual mailbox configuration
    # ### virtual_alias_domains
    # Entries with default values of undef must be specified in array form
    $virtual_alias_domains   = undef,
    # ### virtual_alias_entries
    # ### virtual_alias_templates
    # ### virtual_alias_maps
    # ### virtual_mailbox_base
    # ### virtual_mailbox_domains
    # ### virtual_mailbox_limit
    # ### virtual_mailbox_maps
    # ### virtual_minimum_uid
    # ### virtual_uid_maps
    # /etc/postfix/virtual is always managed from the contents of
    # $virtual_alias_entries and $virtual_alias_templates, but it can
    # be bypassed entirely by not including it in $virtual_alias_maps
    # and managing files under different names.
    $virtual_alias_entries   = undef,
    $virtual_alias_templates = undef,
    $virtual_alias_maps      = [ 'hash:/etc/postfix/virtual', ],
    $virtual_mailbox_base    = '/var/mail',
    $virtual_mailbox_domains = undef,
    $virtual_mailbox_limit   = '51200000',
    $virtual_mailbox_maps    = undef,
    $virtual_minimum_uid     = '100',
    $virtual_uid_maps        = false,

    # ## Sender-Permitted-From
    # ### spf
    # Activate SPF checking
    # If this is set to 'warn', it will generate warnings in the logs,
    # but not outright reject messages failing SPF check.
    $spf = false,

    # ### spf_debuglevel
    # Debugging output level.  Valid values range from 0-5 (default 1)
    $spf_debuglevel = '1',

    # ### spf_helo_reject
    # HELO/EHLO check rejection policy
    # Valid values are:
    #
    #   * 'SPF_Not_Pass' (default)
    #   * 'Softfail'
    #   * 'Fail'
    #   * 'Null'
    #   * 'False' (note: not the boolean value false)
    #   * 'No_Check'
    #
    $spf_helo_reject = 'SPF_Not_Pass',

    # ### spf_mail_from_reject
    # Mail From rejection policy
    # Valid values are:
    #
    #   * 'SPF_Not_Pass'
    #   * 'Softfail'
    #   * 'Fail' (default)
    #   * 'False' (note: not the boolean value false)
    #   * 'No_Check'
    #
    $spf_mail_from_reject = 'Fail',

    # ### spf_no_mail
    # Only reject when SPF indicates the host/domain sends no
    # mail. This option will only cause mail to be rejected if the
    # HELO/Mail From record is "v=spf1 -all".
    $spf_no_mail = false,

    # ### spf_permerror_reject
    # Reject on permanent error responses?
    $spf_permerror_reject = false,

    # ### spf_temperror_defer
    # Defer on temporary error responses?
    $spf_temperror_defer = false,

    # ### spf_skip_addresses
    # List of CIDR-notation blocks to skip SPF checks for because
    # they are internal networks.  This will default to the value of
    # `mynetworks`, above.  If set to false or undefined, IPv4 and
    # IPv6 local network addresses will be filled in.
    #
    # This can be specified either as an array or a comma-separated
    # string
    $spf_skip_addresses = $mynetworks,

    # ### spf_domain_whitelist
    # List of domains whose sending IPs should be whitelisted from
    # SPF checks.  Use this to list trusted forwarders by domain name.
    # This option is less scalable than the SPF IP Whitelist
    # (`spf_whitelist`, below).
    #
    # This can be specified either as an array or a comma-separated
    # string
    $spf_domain_whitelist = undef,

    # ### spf_domain_whitelist_ptr
    # List of domains (and subdomains) whose sending IPs should be
    # whitelisted from SPF checks based on PTR match of the domain.
    # This is useful for large forwarders with complex outbound
    # infrastructures, but no SPF records and predictable host
    # naming. List the parent domain and all subdomains will
    # match. This option is less scalable than the SPF IP Whitelist.
    #
    # This can be specified either as an array or a comma-separated
    # string
    $spf_domain_whitelist_ptr = undef,

    # ### spf_whitelist
    # Array of CIDR-notation IP addresses to skip SPF checks for.  Use
    # this list to whitelist trusted relays, such as a secondary MX
    # and trusted forwarders.  This generates a different trace header
    # than `spf_skip_addresses`, above.
    #
    # This can be specified either as an array or a comma-separated
    # string
    $spf_whitelist = undef,


    # ## Milters
    # ### milter_default_action
    #
    # The default action when a Milter (mail filter) application is
    # unavailable or mis-configured. Valid values are 'accept',
    # 'reject', 'tempfail', 'quarantine'
    $milter_default_action = 'accept',

    # ### milter_protocol
    #
    # The mail filter protocol version and optional protocol
    # extensions for communication with a Milter application.  It
    # should match the version number that is expected by the mail
    # filter application (or by its Milter library).
    $milter_protocol = undef,

    # ### milters
    #
    # An array of sockets for Milter (mail filter) applications.
    # Values in this array will be added to both `non_smtpd_milters` and
    # `smtpd_milters` in the Postfix configuration.
    $milters = [],

    # ### milters_non_smtpd
    #
    # An array of sockets for Milter (mail filter) applications for
    # new mail that does not arrive via the Postfix smtpd(8)
    # server. This includes local submission via the sendmail(1)
    # command line, new mail that arrives via the Postfix qmqpd(8)
    # server, and old mail that is re-injected into the queue with
    # "postsuper -r".
    #
    # Values in this array are appended to the `milters` array and
    # placed in the Postfix configuration `non_smtpd_milters`
    $milters_non_smtpd = [],

    # ### milters_smtpd
    #
    # An array of sockets for Milter (mail filter) applications for
    # new mail that arrives via the Postfix smtpd(8) server.
    #
    # Values in this array are appended to the `milters` array and
    # placed in the Postfix configuration `smtpd_milters`
    $milters_smtpd = [],


    # ## Additional features
    # ### greylist
    # Activate a greylisting service
    $greylist = false,

    # ### maildrop
    # Maildrop virtual mailbox delivery
    $maildrop = false,

    # ### srs
    # Activate Sender Rewriting Scheme
    #
    # If this is set to true, the class `master::service::postsrsd` will
    # be included and Postfix will be configured to use it.
    $srs = false,

    # ### delay_warning_time
    # Set this to '4h' to generated delayed mail warnings after 4 hours.
    $delay_warning_time = false,

    # ### setgid_group
    # If you change setgid_group, you must manually run
    # 'postfix set-permissions' afterwards
    $setgid_group = $::osfamily ? {
        'Suse'  => 'maildrop',
        default => undef,
    },

    # ## Local paths
    # ### daemon_directory
    $daemon_directory = $::osfamily ? {
        'Suse'  => '/usr/lib/postfix',
        default => undef,
    },

    # ## Miscellaneous postfix-specific options
    # ### alias_maps
    # ### alias_database
    # ### append_dot_mydomain
    # ### biff
    $alias_maps = 'hash:/etc/aliases',
    $alias_database = 'hash:/etc/aliases',
    $append_dot_mydomain = false,
    $biff = false,
    # ### compatibility_level
    # Compatibility level will only be set by default if the Postfix
    # version is 3 or later, but it can be overridden here.
    $compatibility_level = undef,
    # ### recipient_delimiter
    # ### smtpd_banner
    $recipient_delimiter = '+',
    $smtpd_banner = '$myhostname ESMTP $mail_name',

    # ## Override the detected version of Postfix
    # ### version
    $version = $::osfamily ? {
        'Debian' => $::operatingsystemmajrelease ? {
            '6'     => '2.7',
            '7'     => '2.9',
            '8'     => '2.11',
            '9'     => '3.1',
            default => '2.6',
        },
        'RedHat' => $::operatingsystemmajrelease ? {
            '6'     => '2.6',
            '7'     => '2.10',
            default => '2.10',
        },
        'Suse'   => $::operatingsystemmajrelease ? {
            '11'    => '2.9',
            '12'    => '2.11',
            default => '2.9',
        },
        default  => '2.6',
    },
)
{
    include master::common::base
    include master::common::mta
    require master::common::package_management
    require master::common::ssl
    include master::service::postfix::dirs

    if $srs {
        include master::service::postsrsd
        $srs_forward_port = $master::service::postsrsd::forward_port
        $srs_reverse_port = $master::service::postsrsd::reverse_port
    }

    Exec { path => '/sbin:/usr/sbin:/bin/:/usr/bin' }

    package { 'postfix':
        require => File['/etc/mailname']
    }
    templatelayer { '/etc/postfix/main.cf': }
    if $chroot {
        templatelayer { '/etc/postfix/master.cf': suffix => 'chroot' }
    }
    else {
        templatelayer { '/etc/postfix/master.cf': }
    }
    if $pcre_destination {
        master::postfix_table { 'pcre_destination':
            params => {
                pcre_destination => $pcre_destination
            }
        }
    }
    master::postfix_table { 'transport':
        params => {
            entries   => $transport_entries,
            templates => $transport_templates,
        }
    }
    master::postfix_table { 'virtual':
        params => {
            entries   => $virtual_alias_entries,
            templates => $virtual_alias_templates,
        }
    }

    service { 'postfix':
        ensure     => running,
        enable     => true,
        hasrestart => true,
        subscribe  => [ Templatelayer['/etc/postfix/main.cf'],
                        Templatelayer['/etc/postfix/master.cf']
                      ]
    }

    if $greylist {
        case $::osfamily {
            'Debian': {
                include master::service::postgrey
                $greylist_port = $master::service::postgrey::port
            }
            default: {
                fail("Greylisting is not available for ${::operatingsystem}")
            }
        }
    }
    if $smtpd_sasl_auth_enable {
        case $smtpd_sasl_type {
            'cyrus': {
                include master::service::saslauth
            }
            'dovecot': {
                include master::service::dovecot2
            }
            default: {
                fail("Unrecognized SASL type: ${smtpd_sasl_type}")
            }
        }
    }
    if $spf {
        case $::osfamily {
            'Debian': {
                package { 'postfix-policyd-spf-python': }
                $policyd_exec = '/usr/bin/policyd-spf'
                $policyd_user = 'policyd-spf'
                templatelayer { '/etc/postfix-policyd-spf-python/policyd-spf.conf':
                    notify => Service['postfix']
                }
            }
            'RedHat': {
                package { 'pypolicyd-spf': }
                $policyd_exec = '/usr/libexec/postfix/policyd-spf'
                $policyd_user = 'postfix'
                templatelayer { '/etc/python-policyd-spf/policyd-spf.conf':
                    notify => Service['postfix']
                }
            }
            default: {
                fail("SPF support is not available for ${::operatingsystem}")
            }
        }
    }

    case $::osfamily {
        'Debian': {
            $readme_directory = '/usr/share/doc/postfix'
            $html_directory = '/usr/share/doc/postfix/html'

            package { 'postfix-doc': }
            package { 'postfix-ldap': }
            package { 'postfix-mysql': }
            package { 'postfix-pcre': }
            package { 'postfix-pgsql': }
            if versioncmp($::operatingsystemrelease, '9.0') >= 0 {
                package { 'postfix-lmdb': }
                package { 'postfix-sqlite': }
            }
            /*
            ** Debian uses some additional files in /etc/postfix for
            ** package post-install stuff.  We probably shouldn't be
            ** touching the contents of these, ever, for fear of
            ** breaking some obscure package thing, but the ownership
            ** and permissions we can mandate
            */
            file { '/etc/postfix/postfix-files':
                owner => root, group => root, mode => '0644',
                notify => Service['postfix']
            }
            file { '/etc/postfix/postfix-script':
                owner => root, group => root, mode => '0755',
                notify => Service['postfix']
            }
            file { '/etc/postfix/post-install':
                owner => root, group => root, mode => '0755',
                notify => Service['postfix']
            }

        }
        'RedHat': {
            if $chroot {
                include master::service::postfix::chroot
            }
            case $::operatingsystemmajrelease {
                '6': {
                    $readme_directory = '/usr/share/doc/postfix-2.6.6'
                }
                '7': {
                    $readme_directory = '/usr/share/doc/postfix-2.10.1'
                }
                default: {
                    $readme_directory = false
                }
            }
            $html_directory = false
        }
        'SuSE': {
            if $chroot {
                include master::service::postfix::chroot
            }
            $readme_directory = '/usr/share/doc/packages/postfix-doc/README_FILES'
            $html_directory = '/usr/share/doc/packages/postfix-doc/html'
        }
        default: {
            $readme_directory = false
            $html_directory = false
        }
    }

    /* Potential Nagios checks, if a Nagios client is activated */
    master::nagios_check { '20_Proc_postfix': }
    master::nagios_check { '30_postfix': }

    /* Rsyslog needs help to deal with chroots */
    master::rsyslog_config { 'postfix':
        template => 'master/etc/rsyslog.d/postfix.erb'
    }

    /* Activate virtual resources from defines or other classes */
    Templatelayer <| tag == 'postfix_table' |> -> Exec <| tag == 'postfix_table' |>
    Templatelayer <| tag == 'postfix_table' |>
    Exec <| tag == 'postfix_table' |>
}
