#
# master::util::graphics
# ======================
#
# Graphics manipulation packages
#

class master::util::graphics {
    Package { ensure => installed }

    case $osfamily {
        'RedHat': {
            package { 'ImageMagick': }
            package { 'openjpeg': }
        }
        'Debian': {
            package { 'imagemagick': }
            package { 'jpegpixi': }
            package { 'openjpeg-tools': }
            package { 'optipng': }
            package { 'pngcheck': }
            package { 'pngcrush': }
            package { 'pngtools': }
        }
    }
}
