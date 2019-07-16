#
# class master::dev::perl::config
# ===============================
#
# Install Perl packages related to configuration file parsing
#
# This class requires Puppetlabs stdlib.
#

class master::dev::perl::config {
    include master::dev::perl::base

    case $::osfamily {
        'RedHat': {
            $packages = [
                'perl-Config-General',
                'perl-Config-IniFiles',
                'perl-Config-Properties',
                'perl-Config-Simple',
                'perl-Config-Tiny',
            ]
        }
        'Debian': {
            $packages = [
                'libappconfig-perl',
                'libconfig-any-perl',
                'libconfig-file-perl',
                'libconfig-general-perl',
                'libconfig-inifiles-perl',
                'libconfig-tiny-perl',
            ]
        }
        'Suse': {
            $packages = [
                'perl-Config-Crontab',
                'perl-Config-General',
                'perl-Config-IniFiles',
            ]
        }
        default: {
            $packages = []
            notify { "${name}-nopackages":
                message => "WARNING: no packages were defined for ${name} on ${::operatingsystem}.",
                loglevel => warning,
            }
        }
    }
    ensure_packages($packages)
}
