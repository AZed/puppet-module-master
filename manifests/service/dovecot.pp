#
# class master::service::dovecot
# ==============================
#
# Installs a Dovecot 1.x IMAP server that by default allows access to
# both pop3d and imapd on localhost only.
#
# This is long obsolete and you probably want
# master::service::dovecot2 instead
#

class master::service::dovecot (
    # Parameters
    # ----------

    # ### dovecot_listen
    # What should Dovecot (IMAP) listen on?  Usual values are "*" or "127.0.0.1"
    $dovecot_listen = "127.0.0.1",

    # ### dovecot_protocols
    # What protocols should Dovecot (IMAP) allow?
    # All protocols would be "imap imaps pop3 pop3s"
    # Default is just SSL
    $dovecot_protocols = "imaps pop3s"
)
{
    package { [ "dovecot-imapd", "dovecot-pop3d",
                "dovecot-common", "dovecot-dev" ]:
        ensure => latest,
    }

    file { "/etc/dovecot": ensure => directory,
        owner => 'root', group => 'root', mode => '0755',
    }
    templatelayer { "/etc/dovecot/dovecot.conf":
        owner => 'root', group => 'root', mode => '0444',
        require => File["/etc/dovecot"]
    }
    file { "/etc/dovecot/dovecot-ldap.conf":
        owner => 'root', group => 'root', mode => '0400',
        require => File["/etc/dovecot"]
    }
    file { "/etc/dovecot/dovecot-sql.conf":
        owner => 'root', group => 'root', mode => '0400',
        require => File["/etc/dovecot"]
    }
}
