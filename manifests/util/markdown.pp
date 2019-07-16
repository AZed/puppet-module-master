#
# class master::util::markdown
# ============================
#
# Installs packages related to manipulating Markdown documentation
#

class master::util::markdown
{
    case $::osfamily {
        'Debian': {
            package { 'markdown': }
            if versioncmp($::operatingsystemrelease, '8.0') >= 0 {
                package { 'go-md2man': }
            }
        }
        'RedHat': {
            if versioncmp($::operatingsystemrelease, '7.0') >= 0 {
                package { 'libmarkdown': }
            }
        }
        'Suse': {
        }
        default: {}
    }
}
