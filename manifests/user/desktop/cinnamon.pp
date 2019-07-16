#
# class master::user::desktop::cinnamon
# =====================================
#
# Sets up a Cinnamon desktop environment
#
class master::user::desktop::cinnamon (
){
    include master::user::x11

    case $::osfamily {
        'Debian': {
            package { 'task-cinnamon-desktop': }
        }
        default: {
        }
    }
}
