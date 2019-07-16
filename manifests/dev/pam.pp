#
# master::dev::pam
#
# Packages required to build libpam-radius-auth, CVS, and any other
# packages that make direct use of PAM authentication.
#

class master::dev::pam {
  include master::dev::base
  include master::dev::debian
  package { "libpam0g-dev": ensure => latest }
}
