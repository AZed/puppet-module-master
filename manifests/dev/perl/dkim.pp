#
# class master::dev::perl::dkim
# =====================================
#
# Installs the email filter package.  This class is currently only
# valid on Debian-derived systems.
#

class master::dev::perl::dkim {
    package { "libmail-dkim-perl": ensure => latest }
}
