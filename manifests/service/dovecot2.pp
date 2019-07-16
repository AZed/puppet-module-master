#
# class master::service::dovecot2
# ===============================
#
# Installs Dovecot 2.x for both IMAPS and POP3S that listens by
# default on localhost only
#
# Unencrypted IMAP and POP3 access is always disabled.
#
# By default, users will get mbox served from /var/mail/<username> and
# ~/mail and maildir served in the Maildir/ namespace from ~/Maildir
#

class master::service::dovecot2 (
    # What interface should Dovecot (IMAP) listen on?
    # Usual values are '*', '::', or '127.0.0.1'
    $listen = '127.0.0.1',

    # Log file to use for error messages. "syslog" logs to syslog,
    # /dev/stderr logs to stderr.  If left undefined, this will default
    # to syslog.
    $log_path = 'syslog',

    # Prefix for each line written to log file. % codes are in strftime(3)
    # format and should probably end with whitespace
    $log_timestamp = "%Y-%m-%d %H:%M:%S ",

    # Support (encrypted) IMAP (i.e. IMAPS)?
    $imap = true,

    # Enable encrypted POP3? (i.e. POP3S)?
    $pop3 = true,

    # Authentication mechanisms
    $auth_mechanisms = [ 'plain','login' ],

    # Log unsuccessful authentication attempts and the reasons why they failed.
    $auth_verbose = false,

    # Enable mail process debugging
    $mail_debug = false,

    # Allow full filesystem access to clients, bounded only by
    # filesystem permissions.  USE WITH CAUTION.
    $mail_full_filesystem_access = false,

    # Global mail location string.  If left false/undefined, this will
    # be commented out in the configuration file.
    $mail_location = 'mbox:~/mail:INBOX=/var/mail/%u',

    # Group to enable temporarily for privileged operations.
    $mail_privileged_group = 'mail',

    # Locking order
    #
    # The Dovecot default for mbox_write_locks is 'dotlock fcntl', but
    # the order 'fcntl dotlock' is safer over NFS, so that is the
    # default here.
    $mbox_read_locks = undef,
    $mbox_write_locks = 'fcntl dotlock',


    ### Inbox namespace configuration
    # Hide the inbox namespace?
    $inbox_hidden = undef,

    # Show mailboxes for inbox namespace (false/undefined defaults to
    # the dovecot default which is yes)
    # Valid values other than undef are 'yes', 'no', 'children'
    $inbox_list = undef,

    # Inbox namespace mail location string
    $inbox_location = undef,

    # Inbox namespace prefix (false/undefined defaults to no prefix)
    $inbox_prefix = undef,

    # Inbox hierarchy separator
    $inbox_separator = undef,

    # Inbox handles its own subscriptions (false/undef defaults to the
    # dovecot default which is yes)
    $inbox_subscriptions = undef,

    ### Maildir user folder namespace configuration
    # Set up a Maildir/ namespace for users?  Note that Dovecot will
    # only serve maildir folders that begin with a dot.
    $maildir_namespace = true,

    # if $maildir_namespace is true, what location string to use
    $maildir_namespace_location = 'maildir:~/Maildir',

    # if $maildir_namespace is true, what prefix to use
    $maildir_namespace_prefix = 'Maildir/',

    # Enable Postfix SASL authentication?
    $postfix_auth = true,

    # SSL certificate location
    $ssl_cert = $master::common::ssl::cert_file ? {
        /.+/    => $master::common::ssl::cert_file,
        default => '/etc/dovecot/dovecot.pem',
    },

    # SSL private key location
    $ssl_key = $master::common::ssl::key_file ? {
        /.+/    => $master::common::ssl::key_file,
        default => '/etc/dovecot/private/dovecot.pem',
    }
)
{
    include master::common::ssl
    if $postfix_auth {
        include master::service::postfix
    }

    case $::osfamily {
        'Debian': {
            package { 'dovecot-core': }
            package { 'dovecot-dev': }
            package { 'dovecot-ldap': }

            if $imap {
                package { 'dovecot-imapd': ensure => latest }
            }
            else {
                package { 'dovecot-imapd': ensure => absent }
            }
            if $pop3 {
                package { 'dovecot-pop3d': ensure => latest }
            }
            else {
                package { 'dovecot-pop3d': ensure => absent }
            }
        }
        'RedHat': {
            package { 'dovecot': }
        }
        default: {
            notify { "${name}-nopackages":
                message => "WARNING: Dovecot will have to be installed manually on ${::operatingsystem}.",
                loglevel => warning,
            }
        }
    }

    file { '/etc/dovecot': ensure => directory,
        owner => 'root', group => 'root', mode => '0755',
    }
    file { '/etc/dovecot/conf.d': ensure => directory,
        owner => 'root', group => 'root', mode => '0755',
    }
    Templatelayer { notify => Service['dovecot'] }
    templatelayer { '/etc/dovecot/dovecot.conf': suffix => '2' }
    templatelayer { '/etc/dovecot/local.conf': }
    templatelayer { '/etc/dovecot/conf.d/10-auth.conf': }
    templatelayer { '/etc/dovecot/conf.d/10-logging.conf': }
    templatelayer { '/etc/dovecot/conf.d/10-mail.conf': }
    templatelayer { '/etc/dovecot/conf.d/10-master.conf': }
    templatelayer { '/etc/dovecot/conf.d/10-ssl.conf': }

    # Search for per-machine SSL certs and use them if found
    nodefile { '/etc/dovecot/dovecot.pem': defaultensure => ignore }
    nodefile { '/etc/dovecot/private/dovecot.pem': defaultensure => ignore }

    service { 'dovecot':
        enable => true,
        ensure => running,
    }
}
