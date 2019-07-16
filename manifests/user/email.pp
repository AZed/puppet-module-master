#
# class master::user::email
# =========================
#
# Commonly used non-graphical end-user e-mail clients and tools
#

class master::user::email {
    include master::user::spellcheck

    package { 'alpine': }
    package { 'fetchmail': }
    package { 'procmail': }
    package { 'shared-mime-info': }

    case $::osfamily {
        'Debian': {
            package { 'abook': }
            package { 'fetchmailconf': }
            package { 'grepmail': }
            package { 'lbdb': }
            package { 'maildrop': }
            package { 'mpack': }
            package { 'srs': }
            if versioncmp($::operatingsystemrelease, '9.0') < 0 {
                package { 'mutt-patched': }
            }
            else {
                package { 'mutt': }
            }
        }
        default: {
            package { 'mutt': }
        }
    }

    file { '/etc/Muttrc.d':
        ensure => directory,
        owner => 'root', group => 'root', mode => '0755',
    }
}
