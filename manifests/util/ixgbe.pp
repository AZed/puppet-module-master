#
# class master::util::ixgbe
# =========================
#
# WARNING: this class is extremely old and likely to be nonfunctional
# now.  It needs to be examined for removal.
#
# This class is for installing the Intel 10Gb drivers ONLY
#
class master::util::ixgbe {

    case $::operatingsystem {
        'Debian': {
            case $::architecture {
                'amd64': {
                    # 10Gb module (compiled for 64bit!)
                    file { "/lib/modules/${kernelrelease}/kernel/drivers/net/ixgbe/ixgbe.ko":
                        source => "puppet:///modules/master/lib/modules/${kernelrelease}/kernel/drivers/net/ixgbe/ixgbe.ko",
                        notify => Exec["/sbin/depmod -a"]
                    }

                    # Custom modules file to use 10Gb driver
                    master::kernel_module { "ixgbe": }
                    #          nodefile { "/etc/modules":
                    #            notify => Exec["/sbin/depmod -a"]
                    #          }

                    # Reload the modules if something has changed
                    exec { "/sbin/depmod -a":
                        path        => [ "/sbin"],
                        refreshonly => true,
                        require     => [ File["/lib/modules/${::kernelrelease}/kernel/drivers/net/ixgbe/ixgbe.ko"],
                                         Master::Kernel_module["ixgbe"],
                                         ]
                    }
                }
                default: { fail("ixgbe module not configured for ${::operatingsystem} ${::architecture}") }
            }
        }
        default: { fail("ixgbe module not configured for ${::operatingsystem}") }
    }
}
