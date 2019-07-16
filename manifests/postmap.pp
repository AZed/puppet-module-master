#
# define master::postmap
# ======================
#
# Run the Postfix postmap command on a given map/hash
#
define master::postmap {
    include master::service::postfix
    @exec { "postmap-${title}":
        path    => '/sbin:/bin:/usr/sbin:/usr/bin',
        command => "postmap ${title}",
        unless  => "test ${title}.db -nt ${title}",
        notify  => Service['postfix'],
        require => Package['postfix'],
        tag     => 'postfix_table'
    }
}
