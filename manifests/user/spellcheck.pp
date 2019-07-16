#
# master::user::spellcheck
#
# End-user spelling-checker software
#
# On Debian, this also includes the dict client (but not the service)
#

class master::user::spellcheck (
    # STUB: which wordlists to install
    $languages = false,
)
{
    Package { ensure => latest }

    package { 'aspell': }
    package { 'hunspell': }

    case $::osfamily {
        'Debian': {
            package { 'dict': }
            package { 'ispell': }
            package { 'spell': }
        }
        'RedHat': {
        }
    }
}
