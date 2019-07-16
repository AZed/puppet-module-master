#
# master::network_config
#
# This is a shortcut helper define to manage a network configuration
# file in a consistent way between operating systems.
#
# The title of this define should always be the name of the network
# interface.
#
# If no parameters are specified, this will attempt to load a nodefile
# for the default configuration file for that interface for the
# current OS.
#
# The configuration directory can be overridden via the $configdir
# parameter (e.g. because you want Puppet to create network files for
# inspection, but want manual administrator intervention before they
# become live), otherwise that directory will be autodetected by os
# family.
#
# If the $config parameter is specified, and the $template parameter
# is not, a default template will be used to generate the interface
# from the values in the $config hash.  Details will vary by OS, but
# as a general rule if it is a keyword in a network configuration
# file, it's a hash key to $config.
#
# The 'ipaddr' and 'address' keys are synonyms valid on CentOS
# and Debian to support interoperability.  If $config is set to a
# hash, but 'netmask' key is not specified, it will default to
# '255.255.255.0'.
#
# On Suse, where the common model is to specify a prefixlength as part
# of the ipaddr string, no automatic netmask/prefixlen detection is
# done at all, and all variables must be specified.  Suse systems will
# also allow two extra arrays:
#    ipaddr_extra
#    netmask_extra
#    prefixlen_extra
# These will generate IPADDR_0 and PREFIXLEN_0 lines for the first
# entry, incrementing for each additional entry to match the array
# index position.
#
# If both $config and $template are specified, the $config hash will
# simply be made available to the specified template.
#
# If the $suffix parameter is specified, it will be appended after a
# hyphen, so if you are keeping all your templates by FQDN in the
# nodefile directory for the first of a list of symlinked nodefile
# directories, then all you need is:
#   suffix => $::fqdn
#
# If you want an arbitrary template, you can specify it via the
# $template parameter ($suffix will also be appended if both are
# specified)
#
# Owner, group, and mode can also all be specified if needed.
#

define master::network_config (
    $owner     = 'root',
    $group     = 'root',
    $mode      = '0444',
    $suffix    = false,
    $config    = false,
    $configdir = $::osfamily ? {
        'Debian' => '/etc/network/interfaces.d',
        'RedHat' => '/etc/sysconfig/network-scripts',
        'Suse'   => '/etc/sysconfig/network',
        default  => '/etc/sysconfig/network-scripts',
    },
    $template  = false
)
{
    if $suffix {
        $suffix_real = "-${suffix}"
    }
    else {
        $suffix_real = ''
    }

    case $::osfamily {
        'Debian': {
            $configfile = "${configdir}/${title}"
            $template_default = "nodefiles/${::fqdn}${configfile}${suffix_real}"
        }
        'RedHat': {
            $configfile = "${configdir}/ifcfg-${title}"
            $template_default = "nodefiles/${::fqdn}${configfile}${suffix_real}"
        }
        'Suse': {
            $configfile = "${configdir}/ifcfg-${title}"
            $template_default = "nodefiles/${::fqdn}${configfile}${suffix_real}"
        }
        default: {
            fail("master::network_config does not know how to deal with ${::operatingsystem}")
        }
    }

    if $template {
        $template_real = "${template}${suffix_real}"
    }
    elsif $config {
        case $::osfamily {
            'Debian': {
                $template_real = 'master/etc/network/interfaces.d/interface-template.erb'
            }
            'RedHat': {
                $template_real = 'master/etc/sysconfig/network-scripts/ifcfg-template.erb'
            }
            'Suse': {
                $template_real = 'master/etc/sysconfig/network/ifcfg-template.erb'
            }
            default: {
                fail("master::network_config does not know how to autoconfigure ${::operatingsystem}")
            }
        }
    }
    else {
        $template_real = $template_default
    }

    file { $configfile:
        owner   => $owner,
        group   => $group,
        mode    => $mode,
        content => template($template_real),
    }
}
