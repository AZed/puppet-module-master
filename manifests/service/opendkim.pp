#
# class master::service::opendkim
# ===============================
#
# OpenDKIM is a package for signing and verifying DomainKeys
# Identified Mail (DKIM)
#
# Keys are stored in /etc/dkimkeys on Debian-based systems, and
# /etc/opendkim/keys on RedHat-based systems, but compatibility
# symlinks are set so they can always be found in either place.
#
# The configuration is always set up via key tables to make it easy to
# add multiple domains, even if only the one default domain is in use.
#
# Related Perl packages are available in master::dev::perl::email
#
# This class requires Puppetlabs Stdlib and automatically includes
# master::common::mta, which in practice will force Postfix to be
# used.
#

class master::service::opendkim (
    # Parameters
    # ----------

    # ### canonicalization
    #
    # Rules for canonicalization of header/body.  Valid values are
    # 'simple' or 'relaxed', or two of those separated by a slash.
    #
    # 'simple' will do extremely minimal blank line trimming in most
    # cases.  'relaxed' will attempt to normalize much more to deal
    # with mail servers that themselves could rewrite headers or trim
    # whitespace from end of lines.
    #
    # For more detail, see the DKIM RFC6376 at
    # https://tools.ietf.org/html/rfc6376#section-3.4.1
    $canonicalization = 'simple/simple',

    # ### dkim_keys
    # Hash of key names to contents
    # This is implemented via the master::dkim_key helper define
    $dkim_keys = false,

    # ### internal
    # Array of internal hosts for which mail should be signed but not verified
    #
    # Defaults to master::common::mta::trusted_networks
    $internal = $master::common::mta::trusted_networks,

    # ### key_table_lines
    # Array of lines to add to the key table configuration
    $key_table_lines = [ "default._domainkey.${domain} nccs.nasa.gov:default:/etc/dkimkeys/default.private" ],

    # ### key_table_templates
    # Array of template fragments to add to the key table configuration
    $key_table_templates = [],

    # ### report_address
    #
    # Specifies the sending address to be used on From: headers of
    #  outgoing failure reports.  By default, the e-mail address of
    #  the user executing the filter is used
    #  (executing_user@hostname).
    $report_address = undef,

    # ### signing_table_lines
    # Array of lines to add to the signing table configuration
    $signing_table_lines = [ "*@${domain} default._domainkey.${domain}" ],

    # ### signing_table_templates
    # Array of template fragments to add to the signing table configuration
    $signing_table_templates = [],

    # ### signverify
    # Operating mode of opendkim (to sign, verify, or both)
    #
    # Valid values are 's', 'v', or 'sv'
    $signverify = 'v',

    # ### socket
    #
    # Names the socket where this filter should listen for milter connections
    # from the MTA.  Should be in one of these forms:
    #
    #     inet:port@address           to listen on a specific interface
    #     inet:port                   to listen on all interfaces
    #     local:/path/to/socket       to listen on a UNIX domain socket
    #
    # Whatever is chosen will have to match the milter entry on the MTA.
    $socket = 'inet:8891@localhost',

    # ### trusted_hosts
    #
    # Array of trusted hosts that will be appended to the internal
    # hosts for the external ignore list. This has the effect of
    # suppressing the "external host (hostname) tried to send mail as
    # (domain)" log messages.
    $trusted_hosts = [],
) {
    case $::osfamily {
        'Debian': {
            $packages = [
                'opendkim',
                'opendkim-tools',
            ]
            file { '/etc/dkimkeys':
                ensure  => directory,
                owner   => 'opendkim',
                group   => 'opendkim',
                mode    => '0700',
                require => Package['opendkim'],
            }
            file { '/etc/opendkim/keys':
                ensure => link,
                target => '/etc/dkimkeys',
                require => Package['opendkim'],
            }
        }
        'RedHat': {
            $packages = [
                'opendkim',
            ]
            file { '/etc/dkimkeys':
                ensure => link,
                target => '/etc/opendkim/keys',
                require => Package['opendkim'],
            }
            file { '/etc/opendkim/keys':
                ensure  => directory,
                owner   => 'opendkim',
                group   => 'opendkim',
                mode    => '0700',
                require => Package['opendkim'],
            }
        }
        default: {
            fail("${::name} is not supported under ${::operatingsystem}")
        }
    }

    if $packages {
        ensure_packages($packages)
    }

    file { '/etc/opendkim':
        ensure  => directory,
        owner   => 'opendkim',
        group   => 'opendkim',
        require => Package['opendkim'],
    }
    templatelayer { '/etc/opendkim.conf':
        notify  => Service['opendkim'],
        require => Package['opendkim'],
    }
    templatelayer { '/etc/opendkim/internal': notify => Service['opendkim'] }
    templatelayer { '/etc/opendkim/key_table': notify => Service['opendkim'] }
    templatelayer { '/etc/opendkim/signing_table': notify => Service['opendkim'] }
    templatelayer { '/etc/opendkim/trusted': notify => Service['opendkim'] }

    service { 'opendkim':
        ensure  => running,
        enable  => true,
        require => [ Package['opendkim'],
                     File['/etc/opendkim.conf'],
                   ],
    }

    if $dkim_keys and is_hash($dkim_keys) {
        create_resources(master::dkim_key,$dkim_keys)
    }
    else {
        /* Create default key if none are specified */
        exec { 'opendkim-genkey-default':
            cwd     => '/etc/dkimkeys',
            path    => '/bin:/usr/bin',
            command => "opendkim-genkey -r -d ${::domain}",
            creates => [ '/etc/dkimkeys/default.private',
                         '/etc/dkimkeys/default.txt', ],
            require => [ Package['opendkim'],
                         File['/etc/dkimkeys'],
                         Templatelayer['/etc/opendkim.conf'],
                       ],
        }
    }
}
