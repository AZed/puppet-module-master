#
# class master::service::nscd
# ===========================
#
# Ensure that the NSCD service is enabled and running, and invalidate
# the passwd and group caches
#

class master::service::nscd {
    # NSCD can fail if resolv.conf is broken or /etc/hosts is
    # misconfigured, but we're not making the associated classes hard
    # requirements at this time to better support interoperability
    # with other modules.
    #require master::common::base
    #require master::common::network

    package { 'nscd': ensure => installed }

    service { 'nscd':
        enable     => true,
        ensure     => running,
        hasrestart => true,
        notify     => [ Exec['nscd-invalidate-passwd'],
                        Exec['nscd-invalidate-group'] ],
        require    => [ Package['nscd'], File['/etc/nscd.conf'] ],
    }

    file { '/etc/nscd.conf':
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
        notify => Service['nscd'],
    }

    exec { 'nscd-invalidate-passwd':
        path        => '/usr/bin:/bin:/usr/sbin:/sbin',
        command     => 'nscd -i passwd',
        refreshonly => true,
        require     => Service['nscd'],
    }
    exec { 'nscd-invalidate-group':
        path        => '/usr/bin:/bin:/usr/sbin:/sbin',
        command     => 'nscd -i group',
        refreshonly => true,
        require     => Service['nscd'],
    }
    exec { 'nscd-restart':
        path        => '/usr/bin:/bin:/usr/sbin:/sbin',
        command     => 'service nscd restart',
        refreshonly => true,
    }
}
