#
# class master::common::hwclock
# =============================
#
# Fix the hardware clock on buggy hardware systems (currently just the
# Dell PowerEdge 1850)
#
class master::common::hwclock {
    include master::common::base
    case $::productname {
        'PowerEdge 1850': {
            exec { 'fix-dell-clock':
                path => '/bin:/usr/bin',
                command => "sed -i -e 's/^HWCLOCKPARS=.*/HWCLOCKPARS=--directisa/' /etc/init.d/hwclock.sh",
                require => Package['util-linux']
            }
        }
        default: {
            notice("Don't need to fix hwclock.sh")
        }
    }
}
