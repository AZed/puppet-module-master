#
# master::user::multimedia
# ========================
#
# End-user packages related to playing multimedia (audio/video) files
#

class master::user::multimedia {
    Package { ensure => latest }
    
    package { 'audacity': }
    package { 'ffmpeg': }
    package { 'flac': }
    package { 'mplayer': }
    package { 'mplayer-doc': }
    package { 'smplayer': }

    case $osfamily {
        'RedHat': {
            package { 'ffmpeg-libpostproc': }
        }
        'Debian': {
            package { 'mencoder': }
            package { 'vlc': }
        }
        default: {
        }
    }
}
