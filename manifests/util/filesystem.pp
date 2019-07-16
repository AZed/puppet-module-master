#
# master::util::filesystem
# ========================
#
# Filesystem manipulation packages not expected to be on all systems
#

class master::util::filesystem {
    Package { ensure => latest }
    package { "autofs": }
}
