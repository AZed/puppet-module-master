#
# class master::common::vmware
# ============================
#
# Automatic installation of appropriate VMware modules and tools when
# run on a virtual machine
#

class master::common::vmware (
    # Parameters
    # ----------
    #
    # ### vmware_packages
    # Set this to false to disable use of vmware packages even on
    # operating systems where they are available (e.g. because you will
    # be doing a manual install of the VMWare Tools)
    $vmware_packages = true
)
{
    # Code
    # ----

    if $vmware_packages {
        case $::virtual {
            'vmware': {
                case $::operatingsystem {
                    'Debian': {
                        package { "open-vm-tools": }
                        # The open-vm-modules was replaced by DKMS in Wheezy
                        # and the package name changed in Jessie
                        if versioncmp($::operatingsystemrelease, "7.0") < 0 {
                            if $::kernelrelease {
                                package { "open-vm-modules":
                                    name => "open-vm-modules-$::kernelrelease",
                                }
                            }
                            else {
                                err("Could not detect kernel release to install open-vm-modules!")
                            }
                        }
                        elsif versioncmp($::operatingsystemrelease, "8.0") < 0 {
                            package { "open-vm-dkms": }
                        }
                        else {
                            package { "open-vm-tools-dkms": }
                        }
                        # ### Exec['vmware-timesync-disable']
                        # VMware is actually now recommending NOT to run timesync, but
                        # instead to use NTP where possible.
                        exec { "vmware-timesync-disable":
                            command => "vmware-toolbox-cmd timesync disable",
                            path => "/bin:/usr/bin",
                            unless => "test `vmware-toolbox-cmd timesync status` = 'Disabled'",
                            require => Package["open-vm-tools"]
                        }
                    }
                    default: {
                        notice("Automatic VMware Tools installation not yet available on $::operatingsystem")
                    }
                }
            }
            default: {
                notice("$::fqdn is not a VMware guest")
            }
        }
    }
}
