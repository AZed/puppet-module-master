#
# class master::dev::perl::module
#
# Installs perl packages related to module building/detection
#

class master::dev::perl::module {
    include master::dev::perl::base

    case $::operatingsystem {
        'debian','ubuntu': {
            package { 'libmodule-build-perl': }
            package { 'libmodule-corelist-perl': }
            package { 'libmodule-extractuse-perl': }
            package { 'libmodule-find-perl': }
            package { 'libmodule-install-perl': }
            package { 'libmodule-pluggable-fast-perl': }
            package { 'libmodule-scandeps-perl': }
            package { 'libmodule-versions-report-perl': }
        }
        'centos','redhat': {
            package { 'perl-ExtUtils-Embed': }
            package { 'perl-ExtUtils-MakeMaker': }
            package { 'perl-Module-Build': }
            package { 'perl-Module-CoreList': }
            package { 'perl-Module-ExtractUse': }
            package { 'perl-Module-Find': }
            package { 'perl-Module-Install': }
            package { 'perl-Module-Pluggable': }
            package { 'perl-Module-ScanDeps': }
            package { 'perl-Module-Versions-Report': }
        }
        default: { }
    }
}
