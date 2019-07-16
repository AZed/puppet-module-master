#
# master::dev::cuda
# =================
#
# Packages related to development on the NVidia CUDA platform
#

class master::dev::cuda {
    include master::dev::base

    case $::operatingsystem {
        'centos','redhat': {
            $cuda_packages =
            [
            ]
        }
        'debian': {
            $cuda_packages =
            [
                'libnvidia-compiler',
                'libvdpau-dev',
                'nvidia-cuda-dev',
                'nvidia-cuda-doc',
                'nvidia-cuda-gdb',
                'nvidia-cuda-toolkit',
                'nvidia-opencl-icd',
                'nvidia-smi',
                'nvidia-visual-profiler',
            ]
        }
        default: { $cuda_packages = [ ] }
    }
    package { $cuda_packages: ensure => latest }
}
