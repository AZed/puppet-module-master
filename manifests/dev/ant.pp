#
# master::dev::ant
# ================
#
# Packages related to the Ant build tools and the Antlr language
# recognition tools
#

class master::dev::ant {
    include master::dev::base

    case $::operatingsystem {
        "centos","redhat": {
            $ant_packages =
            [
                ant,
                ant-antlr,
                ant-javadoc,
                ant-junit,
                ant-manual,
                antlr-javadoc,
                antlr-manual,
            ]
        }
        'debian': {
            $ant_packages =
            [
                ant,
                ant-doc,
                ant-optional,
                antlr3,
                antlr-doc,
            ]
        }
        default: { $ant_packages = [ ] }
    }
    package { $ant_packages: ensure => latest }
}
