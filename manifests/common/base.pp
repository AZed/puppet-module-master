#
# class master::common::base
# ==========================
#
# Base packages, files, and directories upon which multiple other
# classes may depend
#

class master::common::base (
    # Parameters
    # ----------

    # ### admins
    # System administrators will be automatically added to cron.allow
    #
    # This loads from the global Hiera value 'admins' by default, as
    # that value is used in multiple classes.
    $admins = hiera('admins',[]),

    # ### cron_allow_all
    # If cron_allow_all is set to true, then /etc/cron.allow will be deleted.
    # Otherwise, root and admins will have entries but no one else will
    $cron_allow_all = false,

    # ### cron_allow_users
    # If $cron_allow_all above is false, then $cron_allow_users can be
    # made an array of users in addition to the sysadmins for the machine
    # that will be allowed to generate personal crontabs.
    $cron_allow_users = [ ],

    # ### fstab_file
    # If fstab_templates is true, fstab_file will be managed by Puppet.
    #
    # WARNING: setting this to '/etc/fstab' has the potential to
    # render the system unbootable if anything goes wrong.  USE WITH
    # CAUTION.
    $fstab_file = '/etc/fstab-puppet',

    # ### fstab_templates
    # An array of template fragments to transclude into the managed
    # fstab file If this is false, the file will not be managed at
    # all.
    $fstab_templates = false,

    # ### hosts_templates
    # Template fragments to transclude into /etc/hosts
    # If this is false, /etc/hosts will not be managed at all
    # If this is [ ], however, /etc/hosts will be replaced with an empty file
    # For a simple default, use [ 'master/etc/hosts-self' ]
    $hosts_templates = false,

    # ### hosts_allow_templates
    # Template fragments to transclude into /etc/hosts.allow
    # If this is false, /etc/hosts.allow will not be managed at all
    # If this is [ ], a default template will allow requests from
    # localhost and deny all other requests
    # To enable sshd from anywhere, use
    #   $hosts_allow_templates = [ 'master/etc/hosts.allow-sshd_all' ]
    $hosts_allow_templates = false,

    # ### hosts_allow_custom_lines
    # An array containing custom lines to be added to hosts.allow
    # This will only be used if $hosts_allow_templates is true
    $hosts_allow_custom_lines = false,

    # ### limit_core_hard
    # ### limit_core_soft
    # CISecurity Benchmark 8.11 requires that core files be disabled,
    # but this can be overridden here.
    $limit_core_hard = '0',
    $limit_core_soft = '0',

    # ### limits_conf_custom_lines
    # An array containing custom lines to be added to limits.conf
    $limits_conf_custom_lines = false,

    # ### mailname
    # Name of the system used when sending mail.  Defaults to FQDN
    $mailname = $::fqdn,

    # ### motd_templates
    # Array of template fragments to insert into /etc/motd
    $motd_templates = [ ],

    # ### runlevel
    # Default runlevel at boot
    # For Debian this defaults to 2, for CentOS it defaults to 3
    # The variable actually used in the template is defaultrunlevel
    $runlevel = false,

    # ### services_templates
    # Array of template fragments to transclude into the end of /etc/services
    $services_templates = false,

    # ### tty_templates
    # Array of template fragments to transclude into /etc/inittab on
    # Debian/SLES, or into /etc/init/tty.override on CentOS.
    $tty_templates = [ ]
)
{
    # Code
    # ----
    include master::common::base::dir
    include master::common::package_management
    include master::dev::perl::base

    # Handle default runlevel
    if $runlevel {
        $defaultrunlevel = $runlevel
    }
    else {
        case $::osfamily {
            'Debian': { $defaultrunlevel = 2 }
            'RedHat': { $defaultrunlevel = 3 }
            'SuSE':   { $defaultrunlevel = 3 }
            default: {
                fail("Default run level not known for OS family ${::osfamily}")
            }
        }
    }

    case $::operatingsystem {
        'debian': { $procps = 'procps' }
        'sles'  : { $procps = 'procps' }
        'centos': {
            if versioncmp($::operatingsystemrelease, '7.0') < 0 {
                $procps = 'procps'
            }
            else {
                $procps = 'procps-ng'
            }
        }
    }
    package { 'procps': name => $procps }

    $common_packages = [
        'bzip2',
        'curl',
        'enscript',
        'file',
        'gzip',
        'less',
        'parted',
        'quota',
        'tar',
        'unzip',
        'wget',
        'zip'
    ]

    # Family-specific packages and templates
    case $::osfamily {
        'Debian': {
            $family_packages = [
                'bind9-host',
                'cfv',
                'cron',
                'lsb-release',
                'mailutils',
                'mmv',
                'ncurses-base','ncurses-term',
                'pbzip2',
                'p7zip','p7zip-full',
                'symlinks',
                'time',
                'util-linux',
                'uuid-runtime',
                'vlan',
                'xml-core',
            ]

            templatelayer { '/etc/inittab': suffix => $::operatingsystem }
            file { '/etc/modules': ensure => file,
                mode => '0644', owner => root, group => root,
            }
        }
        'RedHat': {
            $family_packages = [
                'bind-utils',
                'crontabs',
                'deltarpm',
                'mailx',
                'ncurses',
                'pbzip2',
                'p7zip','p7zip-plugins',
                'redhat-lsb',
                'symlinks',
                'time',
                'vconfig',
                'yum',
                'yum-utils',
            ]

            # /etc/inittab is no longer valid in CentOS 7
            # Instead, runlevels are managed via SystemD symlink
            if versioncmp($::operatingsystemrelease, '7.0') >= 0 {
                # We only manage this if runlevel is actually set, since
                # we aren't managing the contents of a file.
                if $runlevel {
                    file { '/etc/systemd/system/default.target':
                        ensure => link,
                        target => "/lib/systemd/system/runlevel${runlevel}.target",
                    }
                }
                templatelayer { '/etc/inittab': suffix => 'RedHat-7' }
            }
            else {
                templatelayer { '/etc/inittab': suffix => $::operatingsystem }
            }
        }
        'Suse': {
            $family_packages = [
                'cron',
                'lsb-release',
                'mailx',
                'ncurses-utils',
                'vlan',
                'xml-commons'
            ]
            templatelayer { '/etc/inittab': suffix => $::operatingsystem }
        }
        default: {
            $family_packages = []
            templatelayer { '/etc/inittab': suffix => $::operatingsystem }
        }
    }
    $all_packages = concat($common_packages,$family_packages)
    ensure_packages($all_packages)

    templatelayer { '/etc/enscript.cfg': }

    # OS-specific base packages and templates
    case $::operatingsystem {
        'Debian': {
            if versioncmp($::operatingsystemrelease, '9.0') >= 0 {
                package { 'pavuk': }
            }

            case $::hardwaremodel {
                'i686': {
                    package { 'libc6-i686': }
                }
                'x86_64': {
                    package { 'libc6-i386': }
                }
                default: { }
            }

            # Grub package changed from 'grub' (in Debian 6/Squeeze) to:
            #   'grub-pc' (standard boot)
            #   'grub-efi-amd64' (64-bit EFI)
            #   'grub-efi-ia32'  (32-bit EFI)
            # As installation in versions 6 or later will always
            # include the correct one, and installing the wrong one
            # can be disastrous, we don't actually manage the package,
            # though we leave the logic to detect it here as an
            # example
            #
            if versioncmp($::operatingsystemrelease, '6.0') < 0 {
                $grubpackage = 'grub'
            }
            else {
                $grubpackage = $::efi ? {
                    true => $::architecture ? {
                        'i386'  => 'grub-efi-ia32',
                        'amd64' => 'grub-efi-amd64',
                        default => 'grub-pc'
                    },
                    default => 'grub-pc'
                }
            }

            exec { 'update-grub':
                path => '/bin:/usr/bin:/usr/sbin',
                refreshonly => true
            }
        }
        'CentOS','RedHat': {
            if versioncmp($::operatingsystemrelease, '7.0') < 0 {
               templatelayer { '/etc/init/tty.override': }
            }
            templatelayer { '/etc/yum/pluginconf.d/priorities.conf': }

            file { '/etc/rc.modules': ensure => file,
                mode => '0644', owner => root, group => root,
            }
        }
        default: { }
    }

    if $cron_allow_all {
        file { '/etc/cron.allow': ensure => absent, }
    }
    else {
        templatelayer { '/etc/cron.allow': }
    }

    if $fstab_templates {
        # This is a stub to allow other parameters or detected values
        # to modify the array list in the future (e.g. automatic
        # nodefile detection of /etc/fstab)
        #
        # For now, no modification is done.
        $fstab_templates_real = $fstab_templates
        templatelayer { $fstab_file:
            template => 'master/etc/fstab',
        }
    }

    templatelayer { '/etc/hostname': }
    if $hosts_templates {
        templatelayer { '/etc/hosts': }
    }
    if $hosts_allow_templates {
        templatelayer { '/etc/hosts.allow': }
    }
    templatelayer { '/etc/mailname': }
    templatelayer { '/etc/motd': }
    templatelayer { '/etc/security/limits.conf': }
    templatelayer { '/etc/services':
        suffix => $::osfamily,
        backup => false,
    }

    file { '/etc/security/opasswd': ensure => present,
        owner => root, group => root, mode => '0400',
    }
}
