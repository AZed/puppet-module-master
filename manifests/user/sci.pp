#
# master::user::sci
#
# Science/Math packages
#

class master::user::sci {
    include master::common::editors
    include master::user::sci::octave

    case $::operatingsystem {
        'centos','redhat': {
            package { 'gnuplot': }
            package { 'grace': }
            package { 'grads': }
            package { 'ncl-devel': }
            package { 'ncview': }
            package { 'wgrib': }
            package { 'wgrib2': }

        }
        'debian': {
            package { 'cdo': }
            package { 'gnuplot-x11': }
            package { 'grace': }
            package { 'grads': }
            package { 'libgrib-api-tools': }
            package { 'pari-doc': }
            package { 'pari-gp': }
            package { 'pari-gp2c': }
            package { 'ncview': }
            package { 'scilab': }
            package { 'scilab-doc': }

            # In Debian Jessie or later:
            if versioncmp($::operatingsystemrelease, '8.0') >= 0 {
                package { 'ncl-ncarg': }
            }
        }
        default: { }
    }
}
