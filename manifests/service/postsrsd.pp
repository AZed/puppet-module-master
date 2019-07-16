#
# class master::service::postsrsd
# ===============================
#
# PostSRSd provides the Sender Rewriting Scheme (SRS) via TCP-based
# lookup tables for Postfix. SRS is needed if your mail server acts
# as forwarder.
#
# This class will be included from master::service::postfix if
# master::service::postfix::srs is set to any true value.
#
# This class is currently only expected to work on Debian.
#

class master::service::postsrsd (
    # Parameters
    # ----------
    #
    # ### domain
    # Addresses are rewritten to originate from this domain.
    $domain = $::domain,

    # ### exclude_domains
    # Domains not subject to address rewriting
    #
    # If a domain name starts with a dot, it matches all subdomains,
    # but not the domain itself.
    #
    # This parameter can be specified as a string or as an array.  If
    # used as a string, separate multiple domains with a space or
    # comma.  If used as an array, elements will be joined with a
    # comma.
    $exclude_domains = undef,

    # ### secret
    # File containing secret key to sign rewritten addresses.
    $secret = '/etc/postsrsd.secret',

    # ### separator
    # First separator character after SRS0 or SRS1.
    # Can be one of: -+=
    $separator = '=',

    # ### forward_port
    # ### reverse_port
    # These ports are used to bind the TCP list for postfix.
    $forward_port = '10001',
    $reverse_port = '10002',

    # ### run_as
    # Drop root privileges and run as this user
    $run_as = 'postsrsd',

    # ### chroot
    # chroot environment location
    $chroot = '/var/lib/postsrsd',
){
    package { 'postsrsd': }

    service { 'postsrsd':
        ensure  => running,
        enable  => true,
        require => Package['postsrsd'],
    }

    templatelayer { '/etc/default/postsrsd':
        notify => Service['postsrsd'],
    }
}
