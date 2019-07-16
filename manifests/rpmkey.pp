#
# define master::rpmkey
# =====================
#
# Import a RPM GPG key from a template
#
# By default, '.pub' is appended to the title when generating the
# output filename
#

define master::rpmkey (
    # Parameters
    # ----------
    #
    # ### dir
    # Directory in which to put the key
    $dir = '/root/.gnupg/keys',
    #
    # ### module
    # module in which to find the GPG key template
    # If $template is specified, this is ignored.
    $module = undef,
    #
    # ### suffix
    # Suffix to append to the key name
    $suffix = '.pub',
    #
    # ### template
    # Template containing the GPG key
    $template = undef,
){
    include master::common::rpm

    $filepath = "${dir}/${title}${suffix}"
    templatelayer { $filepath:
        module   => $module,
        template => $template,
        notify   => Exec["rpmkey-import-${title}"],
    }

    case $::osfamily {
        'RedHat': {
            if versioncmp($::operatingsystemrelease, '7.0') < 0 {
                # CentOS/RedHat 6 doesn't have the rpmkeys command
                exec { "rpmkey-import-${title}":
                    command     => "rpm --import ${filepath}",
                    cwd         => $dir,
                    path        => "/usr/bin:/bin:/usr/sbin:/sbin",
                    refreshonly => true,
                    require     => Package['rpm'],
                }
            }
            else {
                exec { "rpmkey-import-${title}":
                    command     => "rpmkeys --import ${filepath}",
                    cwd         => $dir,
                    path        => "/usr/bin:/bin:/usr/sbin:/sbin",
                    refreshonly => true,
                    require     => Package['rpm'],
                }
            }
        }
        default: {
            exec { "rpmkey-import-${title}":
                command     => "rpmkeys --import ${filepath}",
                cwd         => $dir,
                path        => "/usr/bin:/bin:/usr/sbin:/sbin",
                refreshonly => true,
                require     => Package['rpm'],
            }
        }
    }
}
