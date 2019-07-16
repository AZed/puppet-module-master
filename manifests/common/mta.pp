#
# class master::common::mta
# =========================
#
# Sets up the default mail transfer agent and provide a central
# location for standard parameters that can be used as defaults by
# any MTA class
#

class master::common::mta (
    # Parameters
    # ----------
    #
    # ### destinations
    # List of domains delivered by local transport (used in Postfix)
    $destinations = [ $::fqdn, "localhost.${::domain}", 'localhost' ],

    # ### maildomain
    # Domain name used for sending mail (origin in Postfix)
    $maildomain = $::domain,

    # ### relayhost
    # Mail relay server
    $relayhost = "mail.${::domain}",

    # ### interfaces
    # Interfaces on which the MTA will listen (only used for Postfix)
    $interfaces = [ '$myhostname','localhost' ],

    # ### trusted_networks
    # Networks on which the MTA will relay and have other permissions
    # (only used for Postfix)
    $trusted_networks = [ '127.0.0.0/8',
                          '[::ffff:127.0.0.0]/104',
                          '[::1]/128',
                          ],

    # ### inet_protocols
    # This can be 'all', 'ipv4', 'ipv6'
    # Currently only valid for Postfix
    $inet_protocols = 'all',

    # ### mailbox_size_limit
    # ### message_size_limit
    # Mailbox and message size limits in bytes (only used for Postfix)
    $mailbox_size_limit = '0',
    $message_size_limit = '20971520',

    # ### mta
    # Mail Transport Agent package
    # Valid values are currently postfix and ssmtp
    $mta = $::osfamily ? {
        'Suse'  => 'postfix',
        default => 'ssmtp',
    }
){
    case $mta {
        'ssmtp': {
            include master::service::ssmtp
        }
        'postfix': {
            include master::service::postfix
        }
        default: {
            err("Unknown mail transport agent: ${mta}")
        }
    }
}
