#
# master::dev::gui
# ================
#
# Packages for developing on or with Graphical User Interfaces
#

class master::dev::gui {
    include master::dev::base
    Package { ensure => latest }

    package { 'ddd': }

    case $::operatingsystem {
        'centos','redhat': {
            package { 'dbus-devel': }
            package { 'enchant-devel': }
            package { 'fltk': }
            package { 'fontconfig-devel': }
            package { 'freeglut-devel': }
            package { 'freetype-devel': }
            package { 'glib-devel': }
            package { 'gtk2-devel': }
            package { 'gtkspell-devel': }
            package { 'libXaw-devel': }
            package { 'meanwhile-devel': }
            package { 'Xaw3d-devel': }
        }
        'debian': {
            package { 'ddd-doc': }
            package { 'freeglut3-dev': }
            package { 'libenchant-dev': }
            package { 'libdbus-1-dev': }
            package { 'libdbus-glib-1-dev': }
            package { 'libfltk1.1-dev': }
            package { 'libfontconfig1-dev': }
            package { 'libfreetype6-dev': }
            package { 'libglib2.0-0-dbg': }
            package { 'libglib2.0-dev': }
            package { 'libgtk2.0-0-dbg': }
            package { 'libgtk2.0-dev': }
            package { 'libgtkspell-dev': }
            package { 'libmeanwhile-dev': }
            package { 'libqt4-dev': }
            package { 'libstartup-notification0-dev': }
            package { 'libxss-dev': }
            package { 'xaw3dg-dev': }
        }
        default: {
        }
    }
}
