#
# class master::common
# ====================
#
# Baseline environment meta-class
#
# This is a meta-class that simply includes the classes in
# master::common::* that are universally useful and safe to include on
# any system because they don't make any changes that are likely to
# break existing functionality.  It also includes the bare baseline
# perl, python and ruby packages to ensure most common scripts can run.
#
# Notably absent:
#   master::common::etckeeper (requires nonstandard repo for Suse)
#   master::common::ipmitool (clears BMC lan config by default)
#   master::common::login_shells (sets a restrictive umask by default)
#   master::common::mail_aliases (pulls master::common::mta)
#   master::common::mta (changes to a minimal MTA by default)
#   master::common::network (can remove unmanaged interfaces.d files)
#   master::common::pam (could affect ability to log in)
#   master::common::root (locks the root account by default)
#   master::common::selinux (missing full cross-os support)
#   master::common::ssh (starts a listening service under Suse)
#   master::common::sysctl (could cause surprises)
#   master::common::xfs (may require a nonstandard repository)
#

class master::common {
    include master::common::admin
    include master::common::backup
    include master::common::base
    include master::common::editors
    include master::common::git
    include master::common::gpg
    include master::common::hwclock
    include master::common::mercurial
    include master::common::package_management
    include master::common::passwd
    include master::common::puppet
    include master::common::rpm
    include master::common::ruby
    include master::common::ssl
    include master::common::sudo
    include master::common::vmware
    include master::common::xfs
    include master::dev::perl::base
    include master::dev::python::base
}
