#
# class master::client::fusioninventory
# =====================================
#
# Sets up a FusionInventory agent
#
# Requires PuppetStdlib on SLES
#
# Debian 9 will require either the 'fusioninventory' or 'stretch'
# repository to be enabled.
#

class master::client::fusioninventory (
    # Server string
    $server = undef,

    # Disable software deployment tasks
    $no_task = 'deploy',

    # Proxy address
    $proxy = '',

    # Proxy username and password, if required
    $proxy_user = '',
    $proxy_password = '',

    # CA Cert Directory
    $ca_cert_dir = '',

    # CA Cert File
    $ca_cert_file = '',

    # Do not check server SSL certificate? ('1' or '0')
    $no_ssl_check = '0',

    # Logger backend ('Stderr', 'File', or 'Syslog')
    $logger = 'Syslog',

    # Log facility (if $logger = 'Syslog')
    $log_facility = 'LOG_USER',

    # Log file (if $logger = 'File')
    $logfile = '/var/log/fusioninventory.log',

    # Log file maximum size
    $logfile_maxsize = '0',

    # Mark the machine with a given tag
    $machine_tag = '',

    # Connection timeout (in seconds)
    $timeout = '180',

    # Debug mode ('0' or '1')
    $debug = '0'
)
{
    require master::common::package_management

    case $::operatingsystem {
        'debian','ubuntu': {
            package { 'fusioninventory-agent': ensure => installed }
            file { '/etc/fusioninventory': ensure => directory }
            templatelayer { '/etc/fusioninventory/agent.cfg': }
        }
        'centos','redhat': {
            package { 'fusioninventory-agent': ensure => installed }
            file { '/etc/fusioninventory': ensure => directory }
            templatelayer { '/etc/fusioninventory/agent.cfg': }
        }
        'sles': {
            # SLES 11 not only doesn't have a package for this, but doesn't
            # have the necessary Perl dependencies, so to get this working
            # is a little convoluted.
            $prebuilt_name = 'fusioninventory-agent_sles-11-x86_64_2.2.7-4'
            $prebuilt_url = "http://prebuilt.fusioninventory.org/stable/sles-11-x86_64/${prebuilt_name}.tar.gz"
            exec { 'wget-prebuilt-tarball':
                cwd     => '/usr/local',
                path    => '/bin:/usr/bin',
                command => "wget ${prebuilt_url}",
                creates => "/usr/local/${prebuilt_name}.tar.gz",
            }
            exec { 'unpack-prebuilt-tarball':
                cwd     => '/usr/local',
                path    => '/bin:/usr/bin',
                command => "tar xzvf /usr/local/${prebuilt_name}.tar.gz",
                creates => "/usr/local/${prebuilt_name}",
                require => Exec['wget-prebuilt-tarball'],
            }
            file { '/usr/local/bin/fusioninventory-agent':
                ensure  => link,
                target  => "/usr/local/${prebuilt_name}/fusioninventory-agent",
                require => Exec['unpack-prebuilt-tarball'],
            }
            exec { 'fix-agent-location':
                cwd     => "/usr/local/${prebuilt_name}",
                path    => '/bin:/usr/bin',
                command => 'perl -pi -e \'s/^MYPWD=.*$/MYPWD=\$(dirname \$(readlink -f \$0))/\' fusioninventory-agent',
                unless  => 'grep \'MYPWD=$(dirname $(readlink -f $0))\' fusioninventory-agent',
                require => Exec['unpack-prebuilt-tarball'],
            }
            templatelayer { "/usr/local/${prebuilt_name}/agent.cfg":
                template => 'master/etc/fusioninventory/agent.cfg',
                alias    => '/etc/fusioninventory/agent.cfg',
                require  => Exec['unpack-prebuilt-tarball'],
            }

            # The prebuilt package contains a perl that was originally
            # built in /root/fusion/tmp.  This doesn't break operation
            # in normal circumstances, but it does make it impossible
            # to install additional libraries for that perl, so we fix
            # the location.
            file_line { 'config_pm_sitearchexp':
                ensure  => present,
                path    =>
                "/usr/local/${prebuilt_name}/perl/lib/5.12.1/x86_64-linux-thread-multi/Config.pm",
                line    =>
                "    sitearchexp => '/usr/local/${prebuilt_name}/perl/lib/site_perl/5.12.1/x86_64-linux-thread-multi',",
                match   => '^    sitearchexp => ',
                require => Exec['unpack-prebuilt-tarball'],
            }
            file_line { 'config_pm_sitelibexp':
                ensure  => present,
                path    =>
                "/usr/local/${prebuilt_name}/perl/lib/5.12.1/x86_64-linux-thread-multi/Config.pm",
                line    =>
                "    sitelibexp => '/usr/local/${prebuilt_name}/perl/lib/site_perl/5.12.1',",
                match   => '^    sitelibexp => ',
                require => Exec['unpack-prebuilt-tarball'],
            }
            exec { 'config_heavy_perl_fix':
                cwd     => "/usr/local/${prebuilt_name}/perl/lib/5.12.1/x86_64-linux-thread-multi",
                command =>
                "perl -pi -e 's#/root/fusion/fusioninventory-agent-base/tmp/perl#/usr/local/${prebuilt_name}/perl#g' Config_heavy.pl",
                path    => '/usr/local/bin:/usr/bin:/bin',
                onlyif  => 'grep /root/fusion Config_heavy.pl',
                require => Exec['unpack-prebuilt-tarball'],
            }
        }
        default: {
            fail("FusionInventory not supported under $::operatingsystem")
        }
    }

    templatelayer { '/etc/cron.daily/fusioninventory-agent':
        require => Templatelayer['/etc/fusioninventory/agent.cfg'],
        suffix  => $::osfamily,
        mode    => '0555',
    }
}
