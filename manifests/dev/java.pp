#
# class master::dev::java
# =======================
#
# Install a Java development environment
#

class master::dev::java {
    require master::common::package_management
    require master::dev::java::base

    include master::dev::base
    include master::dev::ant
    include master::dev::java::commons

    package { 'bsh': }
    package { 'junit': }

    case $::operatingsystem {
        'centos','redhat': {
            package { 'avalon-framework': }
            package { 'avalon-logkit': }
            package { 'avalon-logkit-javadoc': }
            package { 'bsf': }
            package { 'javacc-manual': }
            package { 'junit-manual': }
            package { 'jakarta-oro': }
            package { 'jakarta-oro-javadoc': }
            package { 'java-1.6.0-openjdk-javadoc': }
            package { 'jdepend': }
            package { 'jdepend-javadoc': }
            package { 'jsch': }
            package { 'jsch-javadoc': }
            package { 'xalan-j2': }
            package { 'xalan-j2-javadoc': }
            package { 'xalan-j2-xsltc': }
            package { 'xerces-j2': }
        }
        'debian': {
            if versioncmp($operatingsystemrelease, '9.0') < 0 {
                package { 'libvtk-java': }
            }
            else {
                package { 'libvtk6-java': }
            }

            if versioncmp($operatingsystemrelease, '8.0') < 0 {
                package { 'libservlet2.5-java': }
            }
            else {
                package { 'libservlet3.1-java': }
            }

            package { 'binfmt-support': }
            package { 'bsh-doc': }
            package { 'ecj': }
            package { 'jarwrapper': }
            package { 'libavalon-framework-java': }
            package { 'libbsf-java': }
            package { 'libexcalibur-logkit-java': }
            package { 'libgnumail-java': }
            package { 'libjdepend-java': }
            package { 'libjline-java': }
            package { 'libjsch-java': }
            package { 'libmicroba-java': }
            package { 'liboro-java': }
            package { 'libswing-layout-java': }
            package { 'libxalan2-java': }
            package { 'libxerces2-java': }
            package { 'libxsltc-java': }
            package { 'maven': }
            package { 'substance': }
        }
        default: {
        }
    }
}
