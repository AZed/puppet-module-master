#
# class master::common::aide
# ==========================
#
# Configure the AIDE tripwire
#

class master::common::aide (
    # Parameters
    # ----------
    #
    # ### aide_misc_custom_lines
    # Lines automatically added to aide.conf.d/90_misc on supported systems
    $aide_misc_custom_lines = [ ]
)
{
    # Code
    # ----
    package { 'aide': ensure => latest, }

    file { '/etc/aide': ensure => directory,
        owner => root, group => root, mode => '0755',
    }

    # On Debian operating systems, helper scripts are available to
    # initialize and manage AIDE databases.
    case $::operatingsystem {
        'Debian': {
            package { 'aide-common': ensure => latest }
            file { '/etc/aide/aide.conf.d': ensure => directory,
                owner => root, group => root, mode => '0755',
            }

            Templatelayer { before => Exec['aideinit'] }
            templatelayer { '/etc/aide/aide.conf': suffix => $::release_majornum, }
            templatelayer { '/etc/aide/aide.conf.d/31_aide_aide': }
            templatelayer { '/etc/aide/aide.conf.d/31_aide_apt': mode => '0555' }
            templatelayer { '/etc/aide/aide.conf.d/31_aide_cacti': }
            templatelayer { '/etc/aide/aide.conf.d/31_aide_dhelp': }
            templatelayer { '/etc/aide/aide.conf.d/31_aide_dpkg': }
            templatelayer { '/etc/aide/aide.conf.d/31_aide_freeradius': }
            templatelayer { '/etc/aide/aide.conf.d/31_aide_mysql': }
            templatelayer { '/etc/aide/aide.conf.d/31_aide_ntop': }
            templatelayer { '/etc/aide/aide.conf.d/31_aide_nscd': }
            templatelayer { '/etc/aide/aide.conf.d/31_aide_ntp': }
            templatelayer { '/etc/aide/aide.conf.d/31_aide_rancid': }
            templatelayer { '/etc/aide/aide.conf.d/31_aide_rsyslog': }
            templatelayer { '/etc/aide/aide.conf.d/31_aide_syslog': }
            templatelayer { '/etc/aide/aide.conf.d/31_aide_tac_plus': }
            templatelayer { '/etc/aide/aide.conf.d/31_aide_apt_translations': }
            templatelayer { '/etc/aide/aide.conf.d/90_misc': }
            templatelayer { '/etc/default/aide': }

            exec { 'aideinit':
                command => 'aideinit',
                path => '/sbin:/usr/sbin:/bin:/usr/bin',
                creates => '/var/lib/aide/aide.db',
                timeout => 900,
                require => [ Templatelayer['/etc/aide/aide.conf'],
                             Templatelayer['/etc/default/aide'],
                             ],
            }

            exec { 'aidedbupdate':
                command => 'mv -f /var/lib/aide/aide.db.new /var/lib/aide/aide.db',
                path => '/sbin:/usr/sbin:/bin:/usr/bin',
                onlyif => 'test -f /var/lib/aide/aide.db.new',
                require => Exec['aideinit'],
            }
        }
        default: { }
    }
}
