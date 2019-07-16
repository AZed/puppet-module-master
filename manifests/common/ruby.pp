#
# class master::common::ruby
# ==========================
#
# Minimal Ruby install needed to ensure basic scripts (and Puppet)
# will run properly
#

class master::common::ruby {
    # Code
    # ----
    package { 'ruby': ensure => installed }

    case $::operatingsystem {
        'Debian': {
            if versioncmp($::operatingsystemrelease, '7.0') >= 0 {
                package { 'ruby-json': }
            }
            # rubygems was folded into ruby in Debian 8
            if versioncmp($::operatingsystemrelease, '8.0') < 0 {
                package { 'rubygems': }
            }
        }
        'RedHat','CentOS': {
            package { 'rubygem-json': }
            package { 'rubygems': }
        }
        'SLES': {
            # rubygems was folded into ruby in SLES12
            if versioncmp($::operatingsystemrelease, '12.0') < 0 {
                package { 'rubygems': }
            }
        }
        default: {
            package { 'rubygems': }
        }
    }

    file { '/usr/local/lib/site_ruby':
        ensure => directory,
        mode   => '0755',
    }

    # Ensure that $rubysitedir is valid before proceeding
    case $rubysitedir {
        '': {
            fail('rubysitedir not defined!')
        }
        default: {
            # Ensure that $rubysitedir/facter exists
            if $::operatingsystem == 'centos' and versioncmp($::operatingsystemrelease, '7.0') >= 0 {
                file { '/usr/local/share/ruby':
                    ensure => directory,
                    mode   => '0755',
                    notify => File[$rubysitedir],
                }
            }
            file { $rubysitedir:
                ensure => directory,
                mode   => '0755',
            }
            file { "$rubysitedir/facter":
                ensure => directory,
                mode   => '0755',
            }
        }
    }
}
