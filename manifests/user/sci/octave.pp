#
# master::user::sci::octave
#
# Octave packages (including Octave-Forge)
#

class master::user::sci::octave {
    include master::user::sci::octave::base

    case $::osfamily {
        'Debian': {
            if versioncmp($::operatingsystemrelease, '8.0') >= 0 {
                include master::user::sci::octave::forge
            }
        }
        default: {
            include master::user::sci::octave::forge
        }
    }
}
