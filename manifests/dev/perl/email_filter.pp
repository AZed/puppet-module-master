#
# class master::dev::perl::email_filter
# =====================================
#
# Installs the email filter package.  This class is currently only
# valid on Debian-derived systems.
#

class master::dev::perl::email_filter {
    package { "libemail-filter-perl": ensure => latest }
}
