#
# class master::service::ssmtp
#
# Sets up an ultra-minimalist MTA, usable only for sending mail
# through a mailhub
#

class master::service::ssmtp (
    $maildomain = $master::common::mta::maildomain,
    $mailhub = $master::common::mta::relayhost
)
{
    include master::common::mta

    package { "ssmtp": ensure => latest, }
    templatelayer { "/etc/ssmtp/ssmtp.conf": }
    templatelayer { "/etc/ssmtp/revaliases": }
}
