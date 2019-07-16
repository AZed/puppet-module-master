#
# class master::service::postfix::dirs
#
# Creates postfix directories for other classes to use even
# when Postfix isn't installed (e.g. SASL)
#
class master::service::postfix::dirs {
    file { [ '/etc/postfix',
             '/var/spool/postfix',
             '/var/spool/postfix/etc',
             '/var/spool/postfix/lib',
             '/var/spool/postfix/pid',
             '/var/spool/postfix/usr',
             '/var/spool/postfix/usr/lib',
             '/var/spool/postfix/usr/lib/zoneinfo',
             '/var/spool/postfix/var',
             '/var/spool/postfix/var/run',
             ]:
        ensure => directory,
        owner => 'root', group => 'root', mode => '0755',
    }
}
