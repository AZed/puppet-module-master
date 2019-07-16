#
# master::dev::gnome
# ==================
#
# Packages related to developing in the Gnome/GTK environment
#

class master::dev::gnome {
    include master::dev::base

    case $::operatingsystem {
        'centos','redhat': {
            package { 'atk-devel': }
            package { 'cairo-devel': }
            package { 'libgail-gnome-devel': }
        }
        'debian': {
            package { 'libatk1.0-dev': }
            package { 'libcairo2-dev': }
            if versioncmp($operatingsystemrelease, '7.0') >= 0 {
                package { 'libgail-3-dev': }
            }
            else {
                package { 'libgail-gnome-dev': }
            }
        }
        default: { }
    }
}
