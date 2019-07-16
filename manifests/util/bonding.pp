#
# This class needs to be fixed.
#
class master::util::bonding (
    $bonding_mode = 0,
    $miimon       = 100,
    $downdelay    = 200,
    $updelay      = 200
)
{
    case $::operatingsystem {
        'debian': {
            package { "ifenslave-2.6": ensure => present }
        }
        'centos': {

            # This template probably only needs to define the
            # alias as the other info can be defined in the
            # ifcfg-bondX file.  In fact, this whole template
            # may be unnecessary.
            templatelayer { "/etc/modprobe.d/bonding.conf":
                mode    => '0444',
                notify  => Exec["update-modules"]
            }

            exec { "update-modules":
                command   => "/sbin/modprobe bonding",
                path      => [ "/sbin" ],
               require   => Templatelayer["/etc/modprobe.d/bonding.conf"],
                subscribe => Templatelayer["/etc/modprobe.d/bonding.conf"]
            }
        }
        default: {
            fail("$::module not configured for $::operatingsystem")
        }
    }
}
