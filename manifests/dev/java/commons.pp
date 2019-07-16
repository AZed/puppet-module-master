#
# master::dev::java::commons
# ==========================
#
# Install the Jakarta Commons packages
#

class master::dev::java::commons {
    include master::dev::java::base
    Class['master::dev::java::base'] -> Class[$name]

    Package { ensure => latest }

    case $::operatingsystem {
        'centos','redhat': {
            if versioncmp($::operatingsystemrelease, '7.0') < 0 {
                package { 'jakarta-commons-beanutils': }
                package { 'jakarta-commons-beanutils-javadoc': }
                package { 'jakarta-commons-collections': }
                package { 'jakarta-commons-collections-javadoc': }
                package { 'jakarta-commons-dbcp': }
                package { 'jakarta-commons-dbcp-javadoc': }
                package { 'jakarta-commons-digester': }
                package { 'jakarta-commons-digester-javadoc': }
                package { 'jakarta-commons-el': }
                package { 'jakarta-commons-el-javadoc': }
                package { 'jakarta-commons-io': }
                package { 'jakarta-commons-io-javadoc': }
                package { 'jakarta-commons-logging': }
                package { 'jakarta-commons-logging-javadoc': }
                package { 'jakarta-commons-pool': }
                package { 'jakarta-commons-pool-javadoc': }
            }
            else {
                package { 'apache-commons-beanutils': }
                package { 'apache-commons-beanutils-javadoc': }
                package { 'apache-commons-collections': }
                package { 'apache-commons-collections-javadoc': }
                package { 'apache-commons-dbcp': }
                package { 'apache-commons-dbcp-javadoc': }
                package { 'apache-commons-digester': }
                package { 'apache-commons-digester-javadoc': }
                package { 'apache-commons-io': }
                package { 'apache-commons-io-javadoc': }
                package { 'apache-commons-logging': }
                package { 'apache-commons-logging-javadoc': }
                package { 'apache-commons-pool': }
                package { 'apache-commons-pool-javadoc': }
            }
        }
        'debian': {
            # libcommons-collections-java became
            # libcommons-collections4-java in Debian 8
            if versioncmp($::operatingsystemrelease, '8.0') >= 0 {
                package { 'libcommons-collections4-java': }
            }
            else {
                package { 'libcommons-collections-java': }
            }
            package { 'libcommons-beanutils-java': }
            package { 'libcommons-daemon-java': }
            package { 'libcommons-dbcp-java': }
            package { 'libcommons-digester-java': }
            package { 'libcommons-el-java': }
            package { 'libcommons-fileupload-java': }
            package { 'libcommons-io-java': }
            package { 'libcommons-launcher-java': }
            package { 'libcommons-logging-java': }
            package { 'libcommons-modeler-java': }
            package { 'libcommons-net-java': }
            package { 'libcommons-pool-java': }
            package { 'libcommons-validator-java': }
            package { 'libxml-commons-resolver1.1-java': }
        }
        default: {
        }
    }
}
