#
# class master::common::admin
# ===========================
#
# Administration/Debugging Tools
#
# These are packages or files that a sysadmin in the course of usual
# duties might be surprised or annoyed to find missing.
#

class master::common::admin (
    # Parameters
    # ----------

    # ### admins
    # Only system administrators will be entered in at.allow
    #
    # This loads from the global Hiera value 'admins' by default, as
    # that value is used in multiple classes.
    $admins = hiera('admins',[]),
){
    # Code
    # ----
    include master::common::base
    include master::common::editors
    include master::common::locate
    include master::common::package_management
    include master::common::sudo
    include master::util::account
    require master::common::base
    require master::common::editors
    require master::common::package_management
    require master::common::sudo

    $sysadmin_packages = [
        'acl',
        'at',
        'ethtool',
        'expect',
        'hdparm',
        'iftop',
        'lsof',
        'patch',
        'pciutils',
        'screen',
        'strace',
        'tree',
        'usbutils',
        'w3m',
    ]
    ensure_packages($sysadmin_packages)

    case $::osfamily {
        'Debian': {
            $osfamily_packages = [
                'discover',
                'dlocate',
                'dmidecode',
                'dnsutils',
                'dstat',
                'links',
                'iotop',
                'man-db',
                'manpages',
                'netcat',
                'pktstat',
                'procinfo',
                'read-edid',
                'scsitools',
                'tmux',
                'whois',
            ]

            # mpt-status is autoinstalled on Debian Squeeze, but is
            # abandoned upstream, specific to LSI controllers, and buggy on
            # VMware installs.
            #
            package { 'mpt-status': ensure => absent }
        }
        'RedHat': {
            $rh_base_packages = [
                'dmidecode',
                'dstat',
                'links',
                'iotop',
                'man-pages',
                'sg3_utils',
                'tmux',
                'yum-plugin-versionlock',
            ]
            if versioncmp($::operatingsystemrelease, '7.0') < 0 {
                $osfamily_packages = concat($rh_base_packages,'man','nc')
            }
            else {
                $osfamily_packages = concat($rh_base_packages,
                                            'man-db','nmap-ncat',
                                            'yum-plugin-post-transaction-actions',
                                            'yum-plugin-pre-transaction-actions')
            }
        }
        'Suse': {
            $osfamily_packages = [
                'man',
                'man-pages',
                'netcat-openbsd',
                'sles-manuals_en',
            ]
        }
        default: {
            $osfamily_packages = []
        }
    }
    ensure_packages($osfamily_packages)

    templatelayer { '/etc/at.allow': }

    # Miscellaneous Git hooks
    file { '/usr/local/etc/git': ensure => directory,
        owner => root, group => root, mode => '0755',
    }
    file { '/usr/local/etc/git/hooks': ensure => directory,
        owner => root, group => root, mode => '0555',
        recurse => true,
        source => 'puppet:///modules/master/usr/local/etc/git/hooks',
    }

    # Miscellaneous shell script helpers
    file { '/usr/local/etc/shell': ensure => directory,
        owner => root, group => root, mode => '0444',
        recurse => true,
        source => 'puppet:///modules/master/usr/local/etc/shell',
    }

    # Git helper scripts (requires helpers above)
    file { '/usr/local/bin/gitinc': ensure => present,
        owner => root, group => root, mode => '0555',
        source => 'puppet:///modules/master/usr/local/bin/gitinc',
    }
    file { '/usr/local/bin/gitout': ensure => present,
        owner => root, group => root, mode => '0555',
        source => 'puppet:///modules/master/usr/local/bin/gitout',
    }

    # SSH Agent Environment Initialization
    file { '/usr/local/etc/sagent.env': ensure => present,
        owner => root, group => root, mode => '0444',
        source => 'puppet:///modules/master/usr/local/etc/sagent.env',
    }
}
