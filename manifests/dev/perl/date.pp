#
# class master::dev::perl::date
# =============================
#
# Perl packages related to date and time manipulation
#

class master::dev::perl::date {
    include master::dev::perl::base

    Package { ensure => latest }

    case $::operatingsystem {
        'debian','ubuntu': {
            package {
                [
                 'libclass-date-perl',
                 'libdate-calc-perl',
                 'libdate-leapyear-perl',
                 'libdate-manip-perl',
                 'libdatetime-format-builder-perl',
                 'libdatetime-format-iso8601-perl',
                 'libdatetime-format-mail-perl',
                 'libdatetime-format-mysql-perl',
                 'libdatetime-format-natural-perl',
                 'libdatetime-format-pg-perl',
                 'libdatetime-format-strptime-perl',
                 'libdatetime-format-w3cdtf-perl',
                 'libdatetime-locale-perl',
                 'libdatetime-perl',
                 'libdatetime-timezone-perl',
                 'libtimedate-perl',
                 ]: }
        }
        'centos','redhat': {
            package {
                [
                 'perl-Date-Calc',
                 'perl-Date-ICal',
                 'perl-Date-Leapyear',
                 'perl-Date-Manip',
                 'perl-DateTime',
                 'perl-DateTime-Format-Builder',
                 'perl-DateTime-Format-ISO8601',
                 'perl-DateTime-Format-Mail',
                 'perl-TimeDate',
                 ]: }
            if versioncmp($::operatingsystemrelease, '7.0') < 0 {
                package { 'perl-Time-modules': }
            }
            else {
                package { 'perl-Time-ParseDate': }
            }
        }
        'sles': {
            package {
                [
                 'perl-Date-Calc',
                 'perl-Date-Manip',
                 'perl-Time-modules',
                 'perl-TimeDate',
                 ]: }
        }
        default: {
            notify { "${name}-nopackages":
                message => "WARNING: no packages were defined for ${name} on ${::operatingsystem}.",
                loglevel => warning,
            }
        }
    }
}
