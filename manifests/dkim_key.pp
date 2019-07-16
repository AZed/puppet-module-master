#
# define master::dkim_key
# =======================
#
# This is a shortcut helper define to create file resources for both a
# DKIM private key and a reference txt entry to be placed on a DNS
# server.
#
# Normally, it will be simpler to pass a $dkim_keys hash as a
# parameter to master::service::opendkim than to use this define
# directly.
#

define master::dkim_key (
    # Parameters
    # ----------
    #
    # ### privatekey
    # Contents of private key file
    $privatekey = undef,

    # ### txt
    # Contents of DNS txt record
    $txt = undef,
)
{
    include master::service::opendkim

    if ! $privatekey {
        fail("No private key specified for dkim_key ${title}")
    }
    if ! $txt {
        fail("No TXT record specified for dkim_key ${title}")
    }

    file { "/etc/dkimkeys/${title}.private":
        owner    => 'opendkim',
        group    => 'opendkim',
        mode     => '0600',
        notify   => Service['opendkim'],
        require  => [ Package['opendkim'], File['/etc/dkimkeys'] ],
        content  => $privatekey,
        tag      => 'dkim_key',
    }
    file { "/etc/dkimkeys/${title}.txt":
        owner    => 'opendkim',
        group    => 'opendkim',
        mode     => '0600',
        notify   => Service['opendkim'],
        require  => [ Package['opendkim'], File['/etc/dkimkeys'] ],
        content  => $txt,
        tag      => 'dkim_key',
    }
}
