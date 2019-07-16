#
# class master::dev::perl::test
# =============================
#
# Install Perl packages related to code testing
#

class master::dev::perl::test {
    include master::dev::perl::base

    case $::operatingsystem {
        'Debian': {
            package { 'libpod-coverage-perl': }
            package { 'libtest-assertions-perl': }
            package { 'libtest-base-perl': }
            package { 'libtest-carp-perl': }
            package { 'libtest-class-perl': }
            package { 'libtest-classapi-perl': }
            package { 'libtest-cmd-perl': }
            package { 'libtest-command-perl': }
            package { 'libtest-deep-perl': }
            package { 'libtest-differences-perl': }
            package { 'libtest-distribution-perl': }
            package { 'libtest-exception-perl': }
            package { 'libtest-expect-perl': }
            package { 'libtest-inline-perl': }
            package { 'libtest-leaktrace-perl': }
            package { 'libtest-log4perl-perl': }
            package { 'libtest-longstring-perl': }
            package { 'libtest-manifest-perl': }
            package { 'libtest-memory-cycle-perl': }
            package { 'libtest-mockmodule-perl': }
            package { 'libtest-mockobject-perl': }
            package { 'libtest-mocktime-perl': }
            package { 'libtest-nowarnings-perl': }
            package { 'libtest-number-delta-perl': }
            package { 'libtest-object-perl': }
            package { 'libtest-perl-critic-perl': }
            package { 'libtest-pod-coverage-perl': }
            package { 'libtest-pod-perl': }
            package { 'libtest-simple-perl': }
            package { 'libtest-unit-perl': }
            package { 'libtest-valgrind-perl': }
            package { 'libtest-warn-perl': }
        }
        'centos','redhat': {
            package { 'perl-Pod-Coverage': }
            package { 'perl-Pod-Coverage-TrustPod': }
            package { 'perl-Test-Assert': }
            package { 'perl-Test-Base': }
            package { 'perl-Test-Carp': }
            package { 'perl-Test-Class': }
            if versioncmp($::operatingsystemrelease,'7.0') < 0 {
                package { 'perl-Test-Cmd': }
            }
            else {
                package { 'perl-Test-Command': }
            }
            package { 'perl-Test-Deep': }
            package { 'perl-Test-Differences': }
            package { 'perl-Test-Distribution': }
            package { 'perl-Test-Exception': }
            if versioncmp($::operatingsystemrelease,'7.0') >= 0 {
                package { 'perl-Test-Inline': }
            }
            package { 'perl-Test-LeakTrace': }
            package { 'perl-Test-LongString': }
            package { 'perl-Test-Memory-Cycle': }
            package { 'perl-Test-MockModule': }
            package { 'perl-Test-MockObject': }
            package { 'perl-Test-MockTime': }
            package { 'perl-Test-Moose': }
            package { 'perl-Test-Most': }
            package { 'perl-Test-NoWarnings': }
            package { 'perl-Test-Number-Delta': }
            package { 'perl-Test-Object': }
            package { 'perl-Test-Perl-Critic': }
            package { 'perl-Test-Pod': }
            package { 'perl-Test-Pod-Coverage': }
            package { 'perl-Test-Simple': }
            package { 'perl-Test-Tester': }
            package { 'perl-Test-Unit': }
            package { 'perl-Test-use-ok': }
            package { 'perl-Test-Valgrind': }
            if versioncmp($::operatingsystemrelease,'7.0') < 0 {
                package { 'perl-Test-Warn': }
            }
            else {
                package { 'perl-Test-Warnings': }
            }
        }
        default: {
            notify { "${name}-nopackages":
                message => "WARNING: no packages were defined for ${name} on ${::operatingsystem}.",
                loglevel => warning,
            }
        }
    }
}
