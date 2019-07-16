#
# class master::service::apache::packages
#
# Installs the actual base packages for Apache and any requested modules
#
# This class is called by master::service::apache and probably should
# not be invoked separately.
#

class master::service::apache::packages
{
    include master::service::apache
    require master::common::package_management

    $install_modules = $master::service::apache::install_modules
    $mpm = $master::service::apache::mpm

    case $::osfamily {
        'RedHat': {
            package { 'apache': name => 'httpd', }
            package { 'httpd-tools': }
        }
        'Debian': {
            if versioncmp($::operatingsystemrelease, '9.0') >= 0 {
                package { 'apache':
                    name  => 'apache2',
                    alias => 'httpd',
                }
            }
            else {
                package { 'apache':
                    name  => "apache2-mpm-${mpm}",
                    alias => 'httpd',
                }
            }
            package { 'apache2-utils': }
            package { 'apachetop': }
            package { 'javascript-common': }
        }
        'SuSE': {
            package { 'apache': name   => 'apache2' }
        }
        default: {
        }
    }

    if $install_modules {
        apache2_install_module { $install_modules: }
    }
}

define apache2_install_module {
    $a2modprefix = $::osfamily ? {
        'Debian' => 'libapache2-mod-',
        'RedHat' => 'mod_',
        'Suse'   => 'apache2-mod_',
        default  => 'mod_',
    }
    package { "$a2modprefix$title": ensure => latest, }
}
