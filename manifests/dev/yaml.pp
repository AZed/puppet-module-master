#
# class master::dev::yaml
# =======================
#
# Packages related to writing or debugging yaml files
#
# This doesn't include packages for specific scripting languages
# covered elsewhere in master::dev (e.g. Perl, Python, Ruby)
#

class master::dev::yaml {
    case $::osfamily {
        'Debian': {
            package { 'kwalify': }
            package { 'libyaml-dev': }
            package { 'libyaml-doc': }
            package { 'yamllint': }
        }
        'RedHat': {
            package { 'libyaml-devel': }
            package { 'yamllint': }
        }
        'Suse': {
            package { 'libyaml-devel': }
        }
        default: {
            notify { "${name}-nopackages":
                message  => "WARNING: no packages were defined for ${name} on ${::operatingsystem}.",
                loglevel => warning,
            }
        }
    }
}
