#
# master::dev::perl::authen
# =========================
#
# Perl modules related to authentication
#

class master::dev::perl::authen {
    Package { ensure => installed }
    case $::osfamily {
        'debian': {
            package { 'libauthen-captcha-perl': }
            package { 'libauthen-pam-perl': }
            package { 'libauthen-radius-perl': }
            package { 'libauthen-sasl-perl': }
            package { 'libauthen-simple-pam-perl': }
            package { 'libauthen-simple-perl': }
            package { 'libauthen-simple-radius-perl': }
        }
        'redhat': {
            package { 'perl-Authen-Captcha': }
            package { 'perl-Authen-PAM': }
            package { 'perl-Authen-SASL': }
        }
        'suse': {
            package { 'perl-Authen-SASL': }
        }
        default: {
            notify { "${name}-nopackages":
                message => "WARNING: no packages were defined for ${name} on ${::operatingsystem}.",
                loglevel => warning,
            }
        }
    }
}
