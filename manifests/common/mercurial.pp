#
# class master::common::mercurial
# ===============================
#
# Install the mercurial version control system and set up the
# repository base and associated rc files.
#
# This also includes a helper script `/usr/local/bin/hg-autocommit`
# for one-pass commits of all changes inside a repository.
#

class master::common::mercurial (
    # Parameters
    # ----------
    #
    # ### hg_repo_base
    # Mercurial Repository Base (where the /hg symlink points)
    # This should not have a leading slash, and if
    # master::service::apache::hgweb is used, the parameter of the same
    # name there MUST have an identical value to work.
    $hg_repo_base = 'var/vc/hg',

    # ### hgrc_trusted_groups
    # An array of groups that should always be trusted when evaluating hgrc files
    $hgrc_trusted_groups = false
)
{
    package { 'mercurial':
        ensure => latest,
    }
    case $::operatingsystem {
        'debian': {
            if versioncmp($::operatingsystemrelease, '9.0') >= 0 {
                $hgversion = '4'
            }
        }
        'centos','redhat': {
            package { 'mercurial-hgk': ensure => latest }
        }
        default: { }
    }

    file { [ '/etc/mercurial', '/etc/mercurial/hgrc.d' ]:
        ensure => directory,
        owner => root, group => root, mode => '0755'
    }

    templatelayer { '/etc/mercurial/hgrc': }
    templatelayer { '/etc/mercurial/hgrc.d/hgext.rc': suffix => $hgversion }
    templatelayer { '/etc/mercurial/hgrc.d/mergetools.rc': }

    file { '/usr/local/bin/hg-autocommit':
        owner => 'root', group => 'root', mode  => '0555',
        source => 'puppet:///modules/master/usr/local/bin/hg-autocommit'
    }

    if $hg_repo_base {
        file { '/hg': ensure => $hg_repo_base }
        file { "/${hg_repo_base}": ensure => directory }
    }
}
