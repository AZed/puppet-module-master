#
# class master::dev::graphics
# ===========================
#
# Development packages related to graphics manipulation
#

class master::dev::graphics {

    case $::operatingsystem {
        'centos','redhat': {
            $packages =
            [ 'libjpeg-turbo-devel',
              'libmng-devel',
              'libpng-devel',
              'librsvg2-devel',
              'libXt-devel',
              'libXtst-devel',
              'mesa-libEGL-devel',
              'vtk-devel',
              'vtk-java',
              'vtk-qt',
            ]
        }
        'debian': {
            $packages =
            [ 'libegl1-mesa-dev',
              'libmng-dev',
              'libpng12-dev',
              'librsvg2-dev',
              'libxt-dev',
              'libxtst-dev',
            ]

            if versioncmp($::operatingsystemrelease, '8.0') < 0 {
                package { 'libjpeg8-dev': }
                package { 'libvtk5-dev': }
                package { 'libvtk5-qt4-dev': }
            }
            else {
                package { 'libjpeg62-turbo-dev': }
                package { 'libvtk6-dev': }
            }
        }
        default: { }
    }
    ensure_packages($packages)
}
