#
# class master::dev::perl::graphics
# =================================
#
# Install Perl packages related to graphics and image manipulation
#

class master::dev::perl::graphics {
    include master::dev::perl::base

    case $::operatingsystem {
        'debian': {
            package { 'libgd-graph-perl': }
            package { 'libgd-graph3d-perl': }
            package { 'libgd-securityimage-perl': }
            package { 'libgd-text-perl': }
            package { 'libgraphics-magick-perl': }
            package { 'libimage-base-bundle-perl': }
            package { 'libimage-exiftool-perl': }
            package { 'libimage-info-perl': }
            package { 'libimage-size-perl': }
            package { 'perlmagick': }

            if versioncmp($::operatingsystemrelease, '8.0') < 0 {
                package { 'libgd-gd2-perl': }
            }
            else {
                package { 'libgd-perl': }
            }
        }
        'centos','redhat': {
            package { 'perl-GD': }
            package { 'perl-GD-Barcode': }
            package { 'perl-GDGraph': }
            package { 'perl-GDGraph3d': }
            package { 'perl-GDTextUtil': }
            package { 'perl-Image-Base': }
            package { 'perl-Image-ExifTool': }
            package { 'perl-Image-Info': }
            package { 'perl-Image-Xbm': }
            package { 'perl-Image-Xpm': }
        }
        default: {
            notify { "${title}-unknown-os":
                message => "WARNING: ${title} is not configured for ${::operatingsystem}!",
                loglevel => warning,
            }
        }
    }
}
