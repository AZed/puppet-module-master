#
# class master::service::mirror::debian
# =====================================
#
# Sets up a Debian mirror
#
# This will almost certainly only work on a Debian host
#

class master::service::mirror::debian (
    # Parameters
    # ----------

    # ### basedir
    # Where on the filesystem to put the mirror
    $basedir              = '/var/www/mirror',

    # ### mirror_arch
    # Array of architectures to mirror
    $mirror_arch          = [ 'amd64' ],

    # ### mirror_archive
    # Releases to mirror from archive.debian.org
    $mirror_archive       = [ ],

    # ### mirror_installer
    # Include installer packages?
    $mirror_installer     = true,

    # ### mirror_lts
    # Releases to mirror from long-term support archive
    $mirror_lts           = [ ],

    # ### mirror_release
    # Standard releases to mirror
    $mirror_release       = [ 'wheezy','jessie','stretch' ],

    # ### mirror_server
    # Hostname of the server to mirror from
    $mirror_server        = 'http.us.debian.org',

    # ### mirror_src
    # Mirror source packages?
    $mirror_src           = true,

    # ### nonfree
    # Mirrornon-free packages?
    $nonfree              = $master::common::package_management::nonfree,

    # ### postmirror_templates
    # ### postmirror_lines
    # Arrays of template fragments and lines to append to the end of mirror.list
    $postmirror_templates = [ ],
    $postmirror_lines     = [ ]
)
{
    # Code Comments
    # -------------
    require master::common::base
    require master::common::package_management
    require master::service::apache

    file { $basedir: ensure => directory }

    if $mirror_installer {
        $installer_component = ' main/debian-installer'
    }
    else {
        $installer_component = ''
    }
    if $nonfree {
        $nonfree_component = ' contrib non-free'
    }
    else {
        $nonfree_component = ''
    }

    package { 'apt-mirror': }
    templatelayer { '/etc/apt/mirror.list': }
    templatelayer { '/etc/cron.d/apt-mirror': }

    # The cron file will run as user apt-mirror, so we need to ensure
    # that failure mail is routed appropriately.
    mailalias { 'apt-mirror': ensure => present,
        recipient => 'admin',
    }

    $aptmirror_basedir = "${basedir}/apt-mirror"
    file { ["${aptmirror_basedir}","${aptmirror_basedir}/var"]:
        ensure => directory,
        owner => 'apt-mirror', group => 'apt-mirror', mode => '2775'
    }
    templatelayer { "${aptmirror_basedir}/var/postmirror.sh":
        template => 'master/var/www/mirror/apt-mirror/var/postmirror.sh',
    }
    file { [ "${aptmirror_basedir}/mirror","${aptmirror_basedir}/skel",]:
        ensure => directory,
        owner => 'apt-mirror', group => 'apt-mirror', mode => '2755',
    }
    file { "/var/spool/apt-mirror":
        ensure => $aptmirror_basedir }
    file { "${basedir}/debian":
        ensure => "${aptmirror_basedir}/mirror/${mirror_server}/debian",
    }
    file { "${basedir}/debian-security":
        ensure => "${aptmirror_basedir}/mirror/security.debian.org/debian-security",
    }
}
