#
# class master::service::tomcat
# =============================
#
# Installs and manages an Apache Tomcat server
#
# This is currently only working under Debian.
#

class master::service::tomcat (
    # Parameters
    # ----------

    # ### groupmembers
    # Array of userids to add to the tomcat group
    $groupmembers = false,

    # ### manager
    # Enable the manager and host manager
    $manager = false
){
    require master::dev::java::base

    case $::operatingsystem {
        'CentOS','RedHat': {
            $tomcatversion = ''
            $tomcatowner = 'tomcat'
            $tomcatgroup = 'tomcat'
        }
        'Debian': {
            case $::operatingsystemmajrelease {
                '6': {
                    $tomcatversion = '6'
                    $tomcatowner = 'tomcat6'
                    $tomcatgroup = 'tomcat6'
                }
                '7': {
                    $tomcatversion = '7'
                    $tomcatowner = 'tomcat7'
                    $tomcatgroup = 'tomcat7'
                }
                '8': {
                    $tomcatversion = '8'
                    $tomcatowner = 'tomcat8'
                    $tomcatgroup = 'tomcat8'
                }
                '9': {
                    $tomcatversion = '8'
                    $tomcatowner = 'tomcat8'
                    $tomcatgroup = 'tomcat8'
                }
                default: { }
            }
        }
        default: { }
    }

    package { ["tomcat${tomcatversion}",
               "tomcat${tomcatversion}-admin", ]:
        ensure => latest,
    }

    file { "/etc/tomcat${tomcatversion}":
        ensure => directory,
        owner => $tomcatowner, group => 'adm', mode => '0750',
        require => Package["tomcat${tomcatversion}"],
    }

    if $groupmembers {
        $groupstring = join($groupmembers,',')
        groupmembers { $tomcatgroup:
            members => $groupstring
        }
    }

    if $manager {
        Templatelayer { owner => 'root', group => $tomcatowner }
        templatelayer { "/etc/tomcat${tomcatversion}/Catalina/localhost/host-manager.xml": }
        templatelayer { "/etc/tomcat${tomcatversion}/Catalina/localhost/manager.xml": }
    }
    else {
        file { "/etc/tomcat${tomcatversion}/Catalina/localhost/host-manager.xml": ensure => absent }
        file { "/etc/tomcat${tomcatversion}/Catalina/localhost/manager.xml": ensure => absent }
    }
}
