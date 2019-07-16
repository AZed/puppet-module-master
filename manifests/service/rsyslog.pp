#
# class master::service::rsyslog
# ==============================
#
# Sets up rsyslog as a logging service
#
# See also the defines:
#  * master::rsyslog_config
#  * master::rsyslog_imfile
#
# Note that to use master::rsyslog_imfile you will need to set
#
#     master::service::rsyslog::module_imfile: true
#
# which is not the default.
#
# This class deliberately does not purge unmanaged contents from
# /etc/rsyslog.d, as multiple system packages may place files there.
#
# If you add a file there and then remove it from your configuration,
# you will need a separate rule or manual intervention to force the
# file to be deleted.
#

class master::service::rsyslog (
    # Common Parameters
    # -----------------

    # ### global_templates
    # An array of template fragments to be transcluded REPLACING the
    # modules and global sections.
    $syslog_global_templates = false,

    # ### syslog_rules_templates
    # An array of template fragments to be transcluded REPLACING the
    # rules section
    #$rules_templates = [ ],
    $syslog_rules_templates = false,

    # ### final_templates
    # An array of template fragments to be transcluded at the end of the
    # configuration file just before the remote loghost line (if specified)
    # These are APPENDED to the default global configuration and rules.
    $syslog_final_templates = false,

    # ### remote_loghost
    # Specify a remote loghost where a copy of all logs will be sent,
    # preceded by '@' for UDP or '@@' for TCP or use RELP syntax
    # e.g. '@@loghost.my.domain' or ':omrelp:192.168.1.200:2514'
    $remote_loghost = false,

    # ### configfiles
    # Specify a hash of master::rsyslog_config parameters to
    # generate arbitrary rsyslog.d/${title}.conf entries fed by
    # templates from arbitrary modules, e.g.
    #   master::service::rsyslog::configfiles:
    #     queues:
    #       template: mymodule/etc/rsyslog-queues.erb
    $configfiles = false,

    # ### filters
    # ### filters_mail
    # Technically, these are arrays of arbitrary lines inserted before
    # any of the log rules (for $filters) and before the mail-specific
    # rules (for $filters_mail), but they are intended to be used for
    # advanced filtering.
    #
    # Example:
    #   master::service::rsyslog::filters_mail:
    #     - ':msg, contains, "I do not want to see this log" ~
    $filters = false,
    $filters_mail = false,

    # ### imfiles
    # Specify a hash of master::rsyslog_imfile parameters to
    # automatically generate rsyslog.d/${title}.conf entries to feed
    # arbitrary filesystem logs into syslog, generally for the purpose
    # of sending to a master logserver, e.g.
    #   master::service::rsyslog::module_imfile: true
    #   master::service::rsyslog::imfiles:
    #     httpd-access:
    #       file: 'path/to/log/file'
    #       severity: info
    #       facility: local7
    $imfiles = false,

    # ### rotate_syslog
    # How many times to rotate /var/log/syslog
    $rotate_syslog = 7,

    # ### rotate_syslog_freq
    # Frequency of rotation of /var/log/syslog
    $rotate_syslog_freq = 'daily',

    # ### rotate_logs
    # How many times to rotate other log files
    $rotate_logs = 4,

    # ### rotate_logs_freq
    # frequency of rotation of other log files
    $rotate_logs_freq = 'weekly',

    # ### rotate_extra_logs
    # Array of additional files to rotate along with the standard list
    # of files
    $rotate_extra_logs = undef,

    # Fine-Tuning Parameters
    # ----------------------
    #
    # These parameters ONLY have any effect if you did not replace
    # global_templates and rules_templates, above, or if your
    # replacements specifically make use of them
    #
    # If you are making extensive use of these parameters, it may be
    # faster for you to simply replace the default rules with your
    # own template fragments above.

    # MaxMessageSize
    # useful for modsecurity, tomcat, etc
    $maxmessagesize = '8192',

    # ### fileowner
    # ### filegroup
    # Owner and group of config files
    $fileowner = 'root',
    $filegroup = $::osfamily ? {
        'Debian' => 'adm',
        'RedHat' => 'adm',
        default  => 'root',
    },

    # ### traditional_timestamps
    # To enable high precision timestamps, set this false
    $traditional_timestamps = true,

    # ### facility_auth
    # ### facility_cron
    # ### facility_daemon
    # ### facility_kern
    # ### facility_mail
    # ### facility_user
    # Logging by facility (auth includes authpriv)
    $facility_auth = $::osfamily ? {
        'Debian' => '-/var/log/auth.log',
        'RedHat' => '-/var/log/secure',
        default  => '-/var/log/auth.log',
    },
    $facility_cron = false,
    $facility_daemon = '-/var/log/daemon.log',
    $facility_kern = '-/var/log/kern.log',
    $facility_lpr = '-/var/log/lpr.log',
    $facility_mail = '-/var/log/mail.log',
    $facility_user = '-/var/log/user.log',

    # ### mailinfo
    # ### mailwarn
    # ### mailerr
    # Split mail log files for easier parsing
    $mailinfo = '-/var/log/mail.info',
    $mailwarn = '-/var/log/mail.warn',
    $mailerr = '/var/log/mail.err',

    # ### unlogged_debug
    # ### unlogged_messages
    # ### unlogged_syslog
    # Facilities to NOT log in /var/log/{debug,messages,syslog}
    # Each array entry will show up on a separate line
    # (with .none automatically appended)
    $unlogged_debug = [ 'auth,authpriv', 'mail,news' ],
    $unlogged_messages = [ 'auth,authpriv', 'cron,daemon', 'mail,news' ],
    $unlogged_syslog = [ 'auth,authpriv' ],

    # ### emerg
    # Where emergencies are sent
    $emerg = ':omusrmsg:*',

    # ### work_directory
    # Where spool and state files go
    $work_directory = '/var/spool/rsyslog',

    # ### legacy_syntax
    # Force legacy syntax on or off?
    $legacy_syntax = undef,

    # ### repeatedmsgreduction
    # Repeated message reduction
    $repeatedmsgreduction = undef,


    # Module Parameters
    # -----------------
    #
    # ### module_imfile
    # ### module_imfile_mode
    # File import
    $module_imfile = false,
    $module_imfile_mode = 'inotify',

    # ### module_imjournal
    # SystemD journal support (can replace imklog on SystemD servers)
    # This is potentially very buggy -- do not use without strong need
    # See: http://www.rsyslog.com/doc/v8-stable/configuration/modules/imjournal.html
    $module_imjournal = false,

    # ### module_imklog
    # Kernel logging support
    $module_imklog = true,

    # ### module_immark
    # Mark file support
    $module_immark = false,

    # ### module_impstats
    # ### module_impstats_config
    # Periodic output of rsyslog internal counters
    #
    # Detailed configuration is available via the config hash.  Values
    # that are false (or undef) will not output any configuration
    # lines at all and will use the rsyslog default value.
    #
    # Only interval, facility, and severity can be specified in legacy
    # format.
    #
    # Example:
    #   master::service::rsyslog::module_impstats_config:
    #     interval => '600'
    #     severity => '7'
    $module_impstats = false,
    $module_impstats_config = hiera_hash('master::service::rsyslog::module_impstats_config',
    {
        bracketing    => false,
        facility      => false,
        format        => false,
        interval      => false,
        log_syslog    => false,
        log_file      => false,
        resetcounters => false,
        ruleset       => false,
        severity      => false,
    }
    ),

    # ### module_imrelp
    # ### module_imrelp_port
    # ### module_imrelp_ssl
    # Receive RELP logs from other servers
    $module_imrelp = false,
    $module_imrelp_port = '2514',
    $module_imrelp_ssl = 'off',

    # ### module_imudp
    # ### module_imudp_port
    # Receive UDP logs from other servers
    $module_imudp = false,
    $module_imudp_port = '514',

    # ### module_imtcp
    # ### module_imtcp_port
    # Receive TCP logs from other servers
    $module_imtcp = false,
    $module_imtcp_port = '514',

    # ### module_omrelp
    # Send RELP logs to other servers
    $module_omrelp = false
)
{
    # Code
    # ----

    package { 'rsyslog': ensure => installed, }

    $rsyslog_service = $::osfamily ? {
        'Suse'  => $::operatingsystemmajrelease ? {
            '11'    => 'syslog',
            default => 'rsyslog',
        },
        default => 'rsyslog',
    }

    service { 'rsyslog':
        ensure => running,
        enable => true,
        name   => $rsyslog_service,
    }

    # Ensure the default $work_directory exists, but don't force
    # ownership of $work_directory as a file, as it may be pointed to
    # a directory controlled elsewhere.
    file { '/var/spool/rsyslog':
        ensure  => directory,
        owner   => 'root',
        group   => 'root',
        mode    => '0700',
        require => Package['rsyslog'],
    }

    if $legacy_syntax == undef {
        # Determine whether we need legacy syntax
        case $::operatingsystem {
            'debian','ubuntu': {
                if versioncmp($::operatingsystemrelease, '8.0') >= 0 {
                    $legacy = false
                }
                else {
                    $legacy = true
                }
            }
            'redhat','centos': {
                if versioncmp($::operatingsystemrelease, '7.0') >= 0 {
                    $legacy = false
                }
                else {
                    $legacy = true
                }
            }
            'sles','suse': {
                if versioncmp($::operatingsystemrelease, '12.0') >= 0 {
                    $legacy = false
                }
                else {
                    $legacy = true
                }
            }
            default: {
                $legacy = false
            }
        }
    }
    else {
        $legacy = $legacy_syntax
    }

    # Main configuration file
    templatelayer { '/etc/rsyslog.conf':
        notify => Service['rsyslog']
    }

    # Set the correct postrotate command by operating system
    $postrotate = $::osfamily ? {
        'Debian' => 'invoke-rc.d rsyslog rotate > /dev/null',
        'RedHat' => 'service rsyslog restart',
        default  => "service ${rsyslog_service} restart"
    }
    templatelayer { '/etc/logrotate.d/rsyslog': }

    # Parameter-based general configuration files
    if $configfiles {
        if is_hash($configfiles) {
            create_resources(master::rsyslog_config,$configfiles)
        }
        else {
            notify { "${title}-configfiles-not-hash":
                message => "WARNING: master::service::rsyslog::configfiles is not a hash!",
                loglevel => warning,
            }
        }
    }

    # Parameter-based imfile configuration
    if $imfiles {
        if is_hash($imfiles) {
            create_resources(master::rsyslog_imfile,$imfiles)
        }
        else {
            notify { "${title}-imfiles-not-hash":
                message => "WARNING: master::service::rsyslog::imfiles is not a hash!",
                loglevel => warning,
            }
        }
    }

    # Activate any file/templatelayer resources tagged in other active
    # classes or defines
    File <| tag == 'rsyslog' |>
    Templatelayer <| tag == 'rsyslog' |>
}
