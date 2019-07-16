#
# class master::service::postfix::chroot
#
# Forces setup of a chroot in environments where the package manager
# does not get it right by default.
#
class master::service::postfix::chroot {
    include master::service::postfix
    include master::service::postfix::dirs
    Package['postfix'] -> Class[$name]

    exec { 'postfix-create-lib64-chroot-dir':
        cwd => '/var/spool/postfix',
        command => 'install -d -m 0755 lib64',
        creates => '/var/spool/postfix/lib64',
        onlyif => 'test -d /lib64',
        require => File['/var/spool/postfix'],
    }
    exec { 'postfix-populate-chroot-etc':
        cwd => '/etc',
        command => 'cp -a services resolv.conf nsswitch.conf host.conf hosts passwd localtime /var/spool/postfix/etc/',
        creates => [ '/var/spool/postfix/etc/services',
                     '/var/spool/postfix/etc/resolv.conf',
                     '/var/spool/postfix/etc/nsswitch.conf',
                     '/var/spool/postfix/etc/host.conf',
                     '/var/spool/postfix/etc/hosts',
                     '/var/spool/postfix/etc/passwd',
                     '/var/spool/postfix/etc/localtime',
                     ],
        require => File['/var/spool/postfix/etc'],
        notify => Service['postfix'],
    }
    exec { 'postfix-populate-chroot-lib':
        cwd => '/lib',
        command => 'cp -a libnss_*.so* libresolv*.so* /var/spool/postfix/lib',
        creates => [ '/var/spool/postfix/lib/libnss_compat.so.2',
                     '/var/spool/postfix/lib/libnss_dns.so.2',
                     '/var/spool/postfix/lib/libnss_files.so.2',
                     '/var/spool/postfix/lib/libnss_nis.so.2',
                     '/var/spool/postfix/lib/libresolv.so.2',
                     ],
        onlyif => 'test -f /lib/libnss_compat.so.2',
        require => File['/var/spool/postfix/lib'],
        notify => Service['postfix'],
    }
    exec { 'postfix-populate-chroot-lib64':
        cwd => '/lib64',
        command => 'cp -a libnss_*.so* libresolv*.so* /var/spool/postfix/lib64',
        creates => [ '/var/spool/postfix/lib64/libnss_compat.so.2',
                     '/var/spool/postfix/lib64/libnss_dns.so.2',
                     '/var/spool/postfix/lib64/libnss_files.so.2',
                     '/var/spool/postfix/lib64/libnss_nis.so.2',
                     '/var/spool/postfix/lib64/libresolv.so.2',
                     ],
        require => Exec['postfix-create-lib64-chroot-dir'],
        onlyif => 'test -d /lib64',
        notify => Service['postfix'],
    }
    file { '/var/spool/postfix/usr/lib/zoneinfo/localtime':
        ensure => '/etc/localtime',
        require => [ File['/var/spool/postfix/usr/lib/zoneinfo'],
                     Exec['postfix-populate-chroot-etc'],
                     ],
        notify => Service['postfix'],
    }
}
