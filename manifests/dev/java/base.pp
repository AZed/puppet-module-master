#
# class master::dev::java::base
# =============================
#
# Core Java packages (both JDK and JRE)
#

class master::dev::java::base {
    require master::common::package_management

    package { 'javacc': }

    case $::operatingsystem {
        'centos','redhat': {
            package { 'java-1.8.0-openjdk': }
            package { 'java-1.8.0-openjdk-devel': }
        }
        'debian': {
            package { 'default-jdk': }
            package { 'default-jre': }

            # Sun Java is no longer available in Debian Wheezy
            if versioncmp($::operatingsystemrelease, '8.0') < 0 {
                # On Wheezy we ensure that openjdk 7 is available,
                # though 6 is the default
                package { 'openjdk-7-jdk': }
                package { 'openjdk-7-jre': }
            }
        }
        default: {
        }
    }
}
