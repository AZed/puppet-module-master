#
# master::user::sci::octave::base
# ===============================
#
# Base Octave packages
#
# For advanced functionality, also include class
# master::user::sci::octave::forge
#

class master::user::sci::octave::base {
    package { 'octave': }
    package { 'octave-doc': }

    case $::osfamily {
        'RedHat': {
        }
        'Debian': {
            package { 'octave-htmldoc': }
            package { 'octave-info': }
        }
        default: { }
    }
}
