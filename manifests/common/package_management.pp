#
# class master::common::package_management
# ========================================
#
# Definitions and variables related to package management
#
# Note that the mirror defaults can be set in Hiera on a
# per-operatingsystem basis.
#

class master::common::package_management (
    # Parameters
    # ----------
    #
    # ### primary_mirror
    # overrides the autodetected URL for the main mirror for the
    # distribution.
    $primary_mirror = hiera("master::common::package_management::primary_mirror_${::operatingsystem}",false),

    # ### security_mirror
    # overrides the autodetected URL for the security updates mirror
    # for the distribution, if applicable.
    $security_mirror = hiera("master::common::package_management::security_mirror_${::operatingsystem}",false),

    # ### backports_mirror
    # overrides the autodetected URL for the backports mirror for the
    # distribution, if applicable
    $backports_mirror = hiera("master::common::package_management::backports_mirror_${::operatingsystem}",false),

    # ### archive_mirror
    # overrides the autodetected URL for the end-of-life archive
    # mirror for the distribution, if applicable.
    $archive_mirror = hiera("master::common::package_management::archive_mirror_${::operatingsystem}",false),

    # ### extra_repos
    # Extra repositories to install, as an array.  The permissible
    # keywords in this array will vary by distribution and release.
    $extra_repos = hiera("master::common::package_management::extra_repos_${::operatingsystem}",[ ]),

    # ### install_recommends
    # Treat recommended packages as hard dependencies (currently only
    # used in Debian, where the default system behavior is to do this)
    $install_recommends = true,

    # ### nonfree
    # Use non-free sources when available?
    $nonfree = false,

    # ### refresh
    # Automatically refresh repository information
    #
    # On Debian, this enforces that aptitude update has been run
    # within the last 12 hours
    #
    # On Suse, this will set the default state of autorefresh for
    # repositories installed via extra_repos.  Note that the default
    # of 'true' here is the opposite of the default 'false' of the
    # autorefresh parameter in master::zypper_repo.
    $refresh = true,
)
{
    include master::dev::python::base

    schedule { "${name}-oncedaily":
        period => daily,
        repeat => 1
    }

    case $::operatingsystem {
        'centos','redhat': {
            file { '/etc/yum.repos.d': ensure => directory, mode => '0755', }
            master::yum_repo { $extra_repos: }

            exec { 'yum-clean-metadata':
                path        => '/usr/bin',
                command     => 'yum clean metadata',
                refreshonly => true
            }
        }
        'debian': {
            if $primary_mirror {
                $debian_mirror = $primary_mirror
            }
            else {
                $debian_mirror = 'http://http.us.debian.org/debian'
            }

            if $security_mirror {
                $debian_security_mirror = $security_mirror
            }
            else {
                $debian_security_mirror = 'http://security.debian.org/debian-security'
            }

            if $backports_mirror {
                $debian_backports_mirror = $backports_mirror
            }
            else {
                $debian_backports_mirror = 'http://http.us.debian.org/debian'
            }

            if $archive_mirror {
                $debian_archive_mirror = $archive_mirror
            }
            else {
                $debian_archive_mirror = 'http://archive.debian.org/debian'
            }

            $debconf_responsedir = '/usr/local/share/debconf'
            file { $debconf_responsedir: ensure => directory,
                owner => root, group => root, mode => '0444',
                recurse => true,
                source => 'puppet:///modules/master/debconf',
            }

            package { 'dpkg': }
            package { 'apt': }
            package { 'apt-xapian-index':
                require => Package['apt'],
            }
            package { 'aptitude': require => Package['apt'] }
            package { 'dbconfig-common':
                responsefile => "${debconf_responsedir}/dbconfig-common",
                require => File[$debconf_responsedir]
            }
            package { 'debian-archive-keyring': }
            package { 'debsums':  }
            package { 'debtags':  }

            file { '/etc/apt': ensure => directory, mode => '0755', }
            file { '/etc/apt/apt.conf.d': ensure => directory, mode => '0755', }
            file { '/etc/apt/preferences.d':
                ensure  => directory,
                mode    => '0755',
                purge   => true,
                recurse => true,
            }
            file { '/etc/apt/sources.list.d':
                ensure  => directory,
                mode    => '0755',
                purge   => true,
                recurse => true,
            }

            templatelayer { '/etc/apt/sources.list':
                require => File['/etc/apt']
            }
            templatelayer { '/etc/apt/preferences':
                suffix => $::operatingsystemmajrelease,
                require => File['/etc/apt']
            }
            templatelayer { '/etc/apt/apt.conf.d/00recommends':
                require => File['/etc/apt/apt.conf.d'],
            }
            templatelayer { '/etc/apt/apt.conf.d/11periodic':
                require => File['/etc/apt/apt.conf.d']
            }
            templatelayer { '/etc/cron.daily/debsums':
                mode => '0555',
                require => [ File['/etc/cron.daily'], Package['debsums'] ]
            }

            # Install additional repos
            master::apt_repo { $extra_repos:
                before => Exec['aptitude-update'],
            }

            if $refresh {
                # Ensure that Apt has been updated within the last 12 hours
                exec { 'aptitude-update':
                    path    => '/bin:/usr/bin',
                    command => 'aptitude -q2 update',
                    require => [ Package['aptitude'],
                                 Package['debian-archive-keyring'],
                                 Templatelayer['/etc/apt/sources.list'],
                                 Templatelayer['/etc/apt/preferences']
                               ],
                    onlyif  => 'test `stat --format=%Y /var/cache/apt/pkgcache.bin` -ge $(( `date +%s` - 12*60*60 ))',
                    timeout => 180
                }
            }
        }
        'sles','suse': {
            file { '/etc/zypp': ensure => directory, mode => '0755', }
            file { '/etc/zypp/repos.d': ensure => directory, mode => '0755', }

            # Install additional repos
            master::zypper_repo { $extra_repos: autorefresh => $refresh }
        }
        default: {
            notice('Package management not handled for this operating system.')
            notice("${::fqdn} runs ${::operatingsystem}.")

            # Stub entry to satisfy dependencies in other classes
            exec { 'aptitude-update':
                path => '/bin:/usr/bin',
                command => '/bin/true',
                schedule => "${name}-oncedaily",
            }
        }
    }
}
