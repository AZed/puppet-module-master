#
# class master::dev::perl::email
# ==============================
#
# Install perl packages related to email parsing and sending
#

class master::dev::perl::email {
    include master::dev::perl::base

    case $::osfamily {
        'Debian': {
            $packages = [
                'libemail-abstract-perl',
                'libemail-address-perl',
                'libemail-date-format-perl',
                'libemail-find-perl',
                'libemail-messageid-perl',
                'libemail-mime-contenttype-perl',
                'libemail-mime-encodings-perl',
                'libemail-mime-perl',
                'libemail-sender-perl',
                'libemail-simple-perl',
                'libemail-valid-loose-perl',
                'libemail-valid-perl',
                'libmail-dkim-perl',
            ]
        }
        'RedHat': {
            $packages = [
                'perl-Email-Abstract',
                'perl-Email-Address',
                'perl-Email-Date-Format',
                'perl-Email-MessageID',
                'perl-Email-MIME',
                'perl-Email-MIME-ContentType',
                'perl-Email-MIME-Encodings',
                'perl-Email-Send',
                'perl-Email-Simple',
                'perl-Email-Valid',
                'perl-Mail-DKIM',
            ]
        }
        default: {
            notify { "${name}-nopackages":
                message => "WARNING: no packages were defined for ${name} on ${::operatingsystem}.",
                loglevel => warning,
            }
        }
    }

    if $packages {
        ensure_packages($packages)
    }
}
