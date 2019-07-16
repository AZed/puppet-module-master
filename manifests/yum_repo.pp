#
# master::yum_repo
#
# Sets up a Yum repository for CentOS/RedHat
#
# Unlike the Apt and Zypper equivalents, Yum repositories are mostly
# set up from a configuration RPM that gets installed, though it is
# technically possible to set up yum.repos.d files separately.
#
# TODO: allow manual configuration of .repo files
#

define master::yum_repo (
    $repofile_url = false,
    $rpmurl       = false
)
{
    include master::common::base

    $primary_mirror = $master::common::package_management::primary_mirror

    # If $rpmurl is specified, bypass automatic keyword detection
    if !$rpmurl and !$repofile_url {
        ## Attempt autodetection of parameters for common keywords
        case $title {
            'atrpms-6': {
                $rpmurl_real = "http://dl.atrpms.net/all/atrpms-repo-6-7.el6.${architecture}.rpm"
                $repofile = 'atrpms.repo'
            }
            'epel': {
                $rpmurl_real = "http://dl.fedoraproject.org/pub/epel/epel-release-latest-${::operatingsystemmajrelease}.noarch.rpm"
                $repofile = 'epel.repo'
            }
            'opennode-tools-6': {
                # OpenNodeCloud Tools for CentOS 6
                # This includes git-buildpackage-rpm
                $rpmurl_real = 'http://opennodecloud.com/centos/6/tools-release.rpm'
                $repofile = 'opennode-tools.repo'
            }
            'passenger': {
                $rpmurl_real = false
                $repofile = 'passenger.repo'
                $repofile_url_real = 'https://oss-binaries.phusionpassenger.com/yum/definitions/el-passenger.repo'
            }
            'postgres92-6': {
                $rpmurl_real = 'http://yum.postgresql.org/9.2/redhat/rhel-6-x86_64/pgdg-centos92-9.2-6.noarch.rpm'
                $repofile = 'pgdg-92-centos.repo'
            }
            'postgres92': {
                $rpmurl_real = 'http://download.postgresql.org/pub/repos/yum/9.2/redhat/rhel-6-x86_64/pgdg-redhat92-9.2-9.noarch.rpm'
                $repofile = 'pgdg-92-centos.repo'
            }
            'postgres93-6': {
                $rpmurl_real = 'http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/pgdg-centos93-9.3-1.noarch.rpm'
                $repofile = 'pgdg-93-centos.repo'
            }
            'postgres95': {
                $rpmurl_real = 'http://download.postgresql.org/pub/repos/yum/9.5/redhat/rhel-6-x86_64/pgdg-redhat95-9.5-3.noarch.rpm'
                $repofile = 'pgdg-95-centos.repo'
            }
            'rpmfusion-6': {
                $rpmurl_real = 'http://download1.rpmfusion.org/free/el/updates/6/i386/rpmfusion-free-release-6-1.noarch.rpm'
                $repofile = 'rpmfusion-free-updates.repo'
            }
            'rpmfusion-6-nonfree': {
                $rpmurl_real = 'http://download1.rpmfusion.org/nonfree/el/updates/6/i386/rpmfusion-nonfree-release-6-1.noarch.rpm'
                $repofile = 'rpmfusion-nonfree-updates.repo'
            }
            'rsyslog-v8': {
                $rpmurl_real = false
                $repofile = 'rsyslog.repo'
                $repofile_url_real = 'http://rpms.adiscon.com/v8-stable/rsyslog.repo'
            }
            'ovirt-3-6-epel': {
                $rpmurl_real = 'http://plain.resources.ovirt.org/pub/yum-repo/ovirt-release36.rpm'
                $repofile    = 'ovirt-3.6.repo'
            }
            default: {
                fail("master::yum_repo (${title}) called with no rpmurl specified")
            }
        }
    }
    elsif $rpmurl {
        $rpmurl_real = $rpmurl
    }
    elsif $repofile_url {
        $repofile_url_real = $repofile_url
    }

    $reponame = $title

    if $rpmurl_real {
        exec { "rpminstall-${title}":
            path    => '/sbin:/bin:/usr/sbin:/usr/bin',
            command => "yum install -y --nogpgcheck ${rpmurl_real}",
            creates => "/etc/yum.repos.d/${repofile}",
            notify  => Exec['yum-clean-metadata'],
            require => Package['wget'],
        }
    }
    elsif $repofile_url_real {
        exec { "repofile-fetch-${title}":
            path    => '/sbin:/bin:/usr/sbin:/usr/bin',
            command => "wget -O /etc/yum.repos.d/${repofile} ${repofile_url_real}",
            creates => "/etc/yum.repos.d/${repofile}",
            notify  => Exec['yum-clean-metadata'],
            require => Package['wget'],
        }
    }
}
