# a class to configure ucarp nominally on debian, and more extensively on centos.
# debian, alas, handles ucarp more sanely. centos/rhel need extra help.
# master::util;:ucarp::interface is a define to try and handle ucarp for centos-types using systemd
#
# For debian systems, ucarp directives can be controlled directly in the /etc/network/interfaces or interfaces.d/ files
#such as:
# ucarp-vid 1
# ucarp-vip 333.222.111
# ucarp-password mypass32
# ucarp-advskew 1
# ucarp-advbase 1
# ucarp-master no
#
# for centos, I've made this parameterized and controllable via hiera.
# Something like the following in an appropriate heira file:
#master::util::ucarp::interfaces:
#  061:
#    id : 61
#    vip_address : 10.1.254.9
#    bind_interface : bond0.061
#    source_address : 10.1.254.31
#    password : foo
#    advskew : 20
#  062:
#    id : 62
#    vip_address : 10.2.254.9
#    bind_interface : bond0.062
#    source_address : 10.2.254.31
#    password : foo2
#    advskew : 20
#
class master::util::ucarp (
   $interfaces=undef,
)
{
    package { "ucarp": ensure => latest }

    case $::operatingsystem {
        'centos': { 
            file { '/etc/ucarp':
               ensure => directory,
               owner  => 'root',
               group  => 'root',
               mode   => '0750',
               require => Package['ucarp']
            }
            if $interfaces {
               if is_hash($interfaces) {
                  create_resources(master::ucarp_interface,$interfaces)
               }
            } 

        }
        'debian': {
            package { "iputils-arping": ensure => latest }
        }
        default: {
            fail("$::module not configured for $::operatingsystem")
        }
    }
    master::nagios_check { '20_Proc_ucarp': }

}
