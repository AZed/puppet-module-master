#
# class master::service::apache::perl
#
# Installs integrated Perl support for Apache servers
#
# This class assumes that master::service::apache has been configured
# such that $install_modules contains 'perl2' and $enable_modules
# contains 'perl'
#
#
class master::service::apache::perl (
    # Use these variables to insert content (either individual lines
    # or template fragments) into a perl.conf file to be read by
    # Apache.
    #
    # If you are setting up a Catalyst instance, you probably need
    # something like the following in $conf_lines:
    #   'PerlSwitches -wT -I/path/to/my/catalyst/module/lib'
    $conf_lines = [ ],
    $conf_templates = [ ]
)
{
    include master::dev::perl::base
    include master::dev::perl::cgi
    include master::dev::perl::css
    include master::dev::perl::html
    include master::dev::perl::module
    include master::dev::perl::template
    include master::dev::perl::web

    if versioncmp($master::service::apache::apacheversion, '2.4') < 0 {
        templatelayer { '/etc/apache2/conf.d/perl.conf':
            template => 'master/etc/apache2/conf-available/perl.conf',
        }
    }
    else {
        templatelayer { '/etc/apache2/conf-available/perl.conf': }
        file { '/etc/apache2/conf-enabled/perl.conf':
            ensure => link,
            target => '../conf-available/perl.conf',
        }
    }

    case $::operatingsystem {
        'centos','redhat': {
            package { 'perl-Catalyst-Devel': }
            package { 'perl-HTML-Mason': }
        }
        'debian': {
            package { 'libapache-asp-perl': }
            package { 'libapache-authznetldap-perl': }
            package { 'libapache2-reload-perl': }
            package { 'libbsd-resource-perl': }
            package { 'libcatalyst-engine-apache-perl': }
            package { 'libcatalyst-model-cdbi-perl': }
            package { 'libcatalyst-modules-extra-perl': }
            package { 'libcatalyst-modules-perl': }
            package { 'libcatalyst-perl': }
            package { 'libcatalyst-view-tt-perl': }
            package { 'libhtml-mason-perl': }
            package { 'libhtml-mason-perl-doc': }
        }
        default: { }
    }
}
