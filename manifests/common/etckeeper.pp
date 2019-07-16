#
# class master::common::etckeeper
# ===============================
#
# Sets up a versioned /etc
#
# WARNING: use of this class under SuSE-based systems requires a
# nonstandard repository:
#
# http://download.opensuse.org/repositories/devel:/tools:/scm/
#

class master::common::etckeeper (
    # Parameters
    # ----------
    #
    # ### etckeeper_vcs
    # Version control system to use with etckeeper
    # Valid options are 'hg', 'git', and 'bzr'
    $etckeeper_vcs = 'git',

    # ### gitignore_lines
    # ### gitignore_templates
    # Arrays of lines and template fragments respectively to append to
    # /etc/.gitignore
    #
    # If both lines and templates are specified, templates will show
    # up in .gitignore before lines
    $gitignore_lines = false,
    $gitignore_templates = false,
)
{
    # Code
    # ----
    require master::common::base::dir

    case $etckeeper_vcs {
        'git': {
            require master::common::git
        }
        'hg': {
            require master::common::mercurial
        }
        'bzr': {
            require master::dev::bazaar
        }
        default: {
            fail("Version control system '${etckeeper_vcs}' not supported!")
        }
    }

    # Place standard ignores for both Mercurial and Git on all systems,
    # even when etckeeper itself isn't available.
    templatelayer { '/etc/.gitignore': mode => '0644' }
    templatelayer { '/etc/.hgignore': mode => '0644' }

    case $::osfamily {
        'Debian': {
            $etckeeper_packageman_high = 'apt'
            $etckeeper_packageman_low  = 'dpkg'
        }
        'RedHat': {
            $etckeeper_packageman_high = 'yum'
            $etckeeper_packageman_low = 'rpm'
        }
        'Suse': {
            $etckeeper_packageman_high = 'zypper'
            $etckeeper_packageman_low = 'rpm'
        }
        default: { }
    }

    case $::osfamily {
        'Debian','RedHat': {
            $etckeeper = true
            package { 'etckeeper': }

            file { '/etc/etckeeper':
                ensure => directory,
                owner => root, group => root, mode => '0755'
            }

            templatelayer { '/etc/etckeeper/etckeeper.conf': mode => '0644' }

            exec { 'etckeeper-init':
                command => 'etckeeper init',
                path => '/sbin:/usr/sbin:/bin:/usr/bin',
                creates => "/etc/.${etckeeper_vcs}",
                require => [ Package['etckeeper'],
                             Templatelayer['/etc/etckeeper/etckeeper.conf'],
                             Templatelayer['/etc/.gitignore'],
                             Templatelayer['/etc/.hgignore'],
                           ]
            }
        }
        'Suse': {
            $etckeeper = true
            package { 'etckeeper': }
            package { 'etckeeper-cron': }
            package { 'etckeeper-zypp-plugin': }

            file { '/etc/etckeeper':
                ensure => directory,
                owner => root, group => root, mode => '0755'
            }

            templatelayer { '/etc/etckeeper/etckeeper.conf': mode => '0644' }

            exec { 'etckeeper-init':
                command => 'etckeeper init',
                path => '/sbin:/usr/sbin:/bin:/usr/bin',
                creates => "/etc/.${etckeeper_vcs}",
                require => [ Package['etckeeper'],
                             Templatelayer['/etc/etckeeper/etckeeper.conf'],
                             Templatelayer['/etc/.gitignore'],
                             Templatelayer['/etc/.hgignore'],
                           ]
            }
        }
        default: {
            notice("etckeeper is not available for ${::operatingsystem}.")
        }
    }
}
