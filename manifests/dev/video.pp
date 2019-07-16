#
# master::dev::video
# ==================
#
# Packages for video manipulation code development
#

class master::dev::video {
    Package { ensure => latest }

    case $::operatingsystem {
        'centos','redhat': {
            package { 'aalib-devel': }
            package { 'gstreamer-devel': }
        }
        'debian': {
            package { 'libaa-bin': }
            package { 'libaa1-dev': }

            if versioncmp($::operatingsystemrelease, '8.0') < 0 {
                package { 'libgstreamer0.10-dev': }
            }
            else {
                package { 'libgstreamer1.0-dev': }
            }
        }
    }
}
