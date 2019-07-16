#
# class master::common::systemd
# =============================
#
# This class only exists to ensure the existence of
# /etc/systemd/system and to provide
#
#     Exec['systemd-cleanup']
#     Exec['systemd-reload']
#
# to be notified by any other class that could potentially change the
# contents of /etc/systemd and needs those changes to be seen.
#

class master::common::systemd {
    # Code
    # ----

    include master::common::base
    include master::common::base::dir

    $systemd_lib = $::osfamily ? {
        'Debian' => '/lib/systemd',
        'RedHat' => '/usr/lib/systemd',
        'Suse'   => '/usr/lib/systemd',
        default  => undef,
    }

    file { '/etc/systemd': ensure => directory,
        owner => 'root', group => 'root', mode => '0755',
    }
    file { '/etc/systemd/system': ensure => directory,
        owner => 'root', group => 'root', mode => '0755',
    }

    # ### Exec['systemd-cleanup']
    exec { 'systemd-cleanup':
        # Remove dangling symlinks in the /lib/systemd/system and
        # /etc/systemd/system areas
        path        => '/sbin:/usr/sbin:/bin:/usr/bin',
        command     =>
        "find /etc/systemd/system -xtype l -exec rm {} \\+ && find ${systemd_lib}/system -xtype l -exec rm {} \\+",
        notify      => Exec['systemd-reload'],
        refreshonly => true,
    }
    # ### Exec['systemd-reload']
    exec { 'systemd-reload':
        # Let SystemD know about changes to its own configuration
        path        => '/sbin:/usr/sbin:/bin:/usr/bin',
        command     => 'systemctl daemon-reload',
        refreshonly => true,
    }
}
