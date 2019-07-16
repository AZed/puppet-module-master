#
# master::dev::science
# ====================
#
# Packages related to development of scientific tools or working with
# common scientific data formats
#

class master::dev::science {
    include master::dev::base

    case $::osfamily {
        'redhat': {
            package { 'atlas-devel': }
            package { 'g2clib-devel': }
            package { 'gdal-devel': }
            package { 'geos-devel': }
            package { 'gsl-devel': }
            package { 'hdf-devel': }
            package { 'hdf5-devel': }
            package { 'libdap-devel': }
            package { 'nco-devel': }
            package { 'netcdf': }
            package { 'netcdf-devel': }
            package { 'proj-devel': }
            package { 'udunits-devel': }
            package { 'udunits2-devel': }
        }
        'debian': {
            package { 'gsl-bin': }
            package { 'libatlas-dev': }
            package { 'libcmor-dev': }
            package { 'libdap-dev': }
            package { 'libgdal-dev': }
            package { 'libgeos-dev': }
            package { 'libgrib2c-dev': }
            package { 'libgsl0-dev': }
            package { 'libhdf5-dev': }
            package { 'libnetcdf-dev': }
            package { 'libproj-dev': }
            package { 'libudunits2-dev': }
            package { 'nco': }
            package { 'netcdf-bin': }
            package { 'paraview-dev': }
            package { 'r-base-dev': }
        }
        default: { }
    }
}
