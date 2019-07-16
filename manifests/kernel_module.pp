# master::kernel_module - Handle the loading and unloading of kernel modules.
#
# usage:
#   master::kernel_module { "some-module": }
#   master::kernel_module { "bad-module": ensure => absent }
#   master::kernel_module { "centos-module": module_file => "/etc/rc.modules" }
###############################################################################
define master::kernel_module (
    $ensure      = "present",
    $module_file = "/etc/modules"
)
{
    case $ensure {
        'present': {
            # Ensure the module loads at boot
            exec { "insert_module_${name}":
                command => $::operatingsystem ? {
                    "debian" => "/bin/echo '${name}' >> '${module_file}'",
                    "redhat" => "/bin/echo '/sbin/modprobe ${name}' >> '${module_file}'",
                    "centos" => "/bin/echo '/sbin/modprobe ${name}' >> '${module_file}'",
                },
                unless => $::operatingsystem ? {
                    "debian" => "/bin/grep -qFx '${name}' '${module_file}'",
                    "redhat" => "/bin/grep -qFx '^/sbin/modprobe ${name}\$' '${module_file}'",
                    "centos" => "/bin/grep -qF '/sbin/modprobe ${name}' '${module_file}'",
                },
                require => File["${module_file}"],
            }

            # Ensure the module is loaded
            exec { "load_module_${name}":
                command => "/sbin/modprobe ${name}",
                unless  => "/sbin/lsmod | /bin/grep -q '^${name} '",
            }
        }
        'absent': {
            # Ensure the module is not loaded
            exec { "unload_module_${name}":
                command => "/sbin/rmmod ${name}",
                onlyif  => "/sbin/lsmod | /bin/grep -q '^${name} '",
            }

            # Ensure the module does not load at boot
            exec { "remove_module_${name}":
                command => $::operatingsystem ? {
                    "debian" => "/bin/grep -vFx '${name}' '${module_file}' | /usr//bin/tee '${module_file}'",
                    "redhat" => "/bin/grep -vFx '/sbin/modprobe ${name}' '${module_file}' | /usr//bin/tee '${module_file}'",
                    "centos" => "/bin/grep -vFx '/sbin/modprobe ${name}' '${module_file}' | /usr//bin/tee '${module_file}'",
                },
                onlyif => $::operatingsystem ? {
                    "debian" => "/bin/grep -qFx '${name}' '${module_file}'",
                    "redhat" => "/bin/grep -qFx '/sbin/modprobe ${name}' '${module_file}'",
                    "centos" => "/bin/grep -qFx '/sbin/modprobe ${name}' '${module_file}'",
                },
                require => File["${module_file}"],
            }
        }
        default: { fail( "kernel_module: unknown value ensure=${ensure}" ) }
    }
}
