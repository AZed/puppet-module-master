#
# class master::dev::perl::term
# =============================
#
# Install Perl packages related to terminals
#

class master::dev::perl::term {
    include master::dev::perl::base
    case $::osfamily {
        'Debian': {
            package { 'libterm-encoding-perl': }
            package { 'libterm-progressbar-perl': }
            package { 'libterm-prompt-perl': }
            package { 'libterm-readkey-perl': }
            package { 'libterm-readline-gnu-perl': }
            package { 'libterm-readline-perl-perl': }
            package { 'libterm-readpassword-perl': }
            package { 'libterm-shell-perl': }
            package { 'libterm-size-perl': }
            package { 'libterm-slang-perl': }
        }
        'RedHat': {
            package { 'perl-Term-Encoding': }
            package { 'perl-Term-ProgressBar': }
            package { 'perl-Term-ReadLine-Gnu': }
            package { 'perl-Term-ShellUI': }
            package { 'perl-Term-Size': }
        }
        default: {
            notify { "${name}-nopackages":
                message => "WARNING: no packages were defined for ${name} on ${::operatingsystem}.",
                loglevel => warning,
            }
        }
    }
}
