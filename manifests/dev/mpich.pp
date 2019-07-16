#
# master::dev::mpich
# ==================
#
# Packages for MPI parallel processing
#

class master::dev::mpich {
    Package { ensure => latest }

    case $::operatingsystem {
        'centos','redhat': {
            package { 'openmpi-1.10-devel': }
        }
        'debian': {
            package { 'mpi-default-bin': }
            package { 'mpi-default-dev': }
            package { 'libmpich2-dev': }
        }
    }
}
