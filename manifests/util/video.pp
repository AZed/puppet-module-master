#
# class master::util::video
#
# Packages for command-line manipulation of video
#
# For video players, see packages in master::user.  For video-related
# code development, see master::dev::video
#

class master::util::video (
){
    case $::osfamily {
        'Debian': {
            package { 'ffmpegthumbnailer': }
            package { 'libav-tools': }
        }
        default: { }
    }
}
