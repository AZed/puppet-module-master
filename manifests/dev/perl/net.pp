#
# class master::dev::perl::net
# ============================
#
# Install Perl packages related to network handling
#

class master::dev::perl::net {
    include master::dev::perl::ldap

    case $::operatingsystem {
        'Debian': {
            package { 'liblwp-authen-oauth-perl': }
            package { 'liblwp-authen-wsse-perl': }
            package { 'liblwp-protocol-https-perl': }
            package { 'libnet-cidr-lite-perl': }
            package { 'libnet-cidr-perl': }
            package { 'libnet-daemon-perl': }
            package { 'libnet-dns-perl': }
            package { 'libnet-domain-tld-perl': }
            package { 'libnet-ident-perl': }
            package { 'libnet-ip-perl': }
            package { 'libnet-ipv6addr-perl': }
            package { 'libnet-google-authsub-perl': }
            package { 'libnet-jabber-loudmouth-perl': }
            package { 'libnet-jabber-perl': }
            package { 'libnet-libidn-perl': }
            package { 'libnet-netmask-perl': }
            package { 'libnet-rblclient-perl': }
            package { 'libnet-smtp-server-perl': }
            package { 'libnet-smtp-ssl-perl': }
            package { 'libnet-smtp-tls-perl': }
            package { 'libnet-ssleay-perl': }
            package { 'libnet-xmpp-perl': }
            package { 'libnet-xwhois-perl': }
            package { 'libnetpacket-perl': }
            package { 'libnetwork-ipv4addr-perl': }
        }
        'centos','redhat': {
            if versioncmp($::operatingsystemrelease, '7.0') >= 0 {
                package { 'perl-LWP-Protocol-https': }
            }
            package { 'perl-Net-CIDR': }
            package { 'perl-Net-DNS': }
            package { 'perl-Net-Daemon': }
            package { 'perl-Net-Domain-TLD': }
            package { 'perl-Net-IP': }
            package { 'perl-Net-IP-CMatch': }
            package { 'perl-Net-IP-Match-Regexp': }
            package { 'perl-Net-IPv4Addr': }
            package { 'perl-Net-Jabber': }
            package { 'perl-Net-LibIDN': }
            package { 'perl-Net-Netmask': }
            package { 'perl-Net-SMTP-SSL': }
            package { 'perl-Net-SMTPS': }
            package { 'perl-Net-SSLeay': }
            package { 'perl-Net-Whois-IP': }
            package { 'perl-Net-Whois-Raw': }
            package { 'perl-Net-XMPP': }
            package { 'perl-NetAddr-IP': }
            package { 'perl-NetPacket': }
        }
        default: {
            notify { "${name}-nopackages":
                message => "WARNING: no packages were defined for ${name} on ${::operatingsystem}.",
                loglevel => warning,
            }
        }
    }
}
