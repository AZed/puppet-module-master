#
# master::dev::base
#
# Development packages that should be assumed to be on any machine
# where development happens.
#

class master::dev::base {
    include master::common::admin

    package { 'asciidoc': }
    package { 'autoconf': }
    package { 'automake': }
    package { 'bison': }
    package { 'chrpath': }
    package { 'cmake': }
    package { 'cscope': }
    package { 'diffstat': }
    package { 'flex': }
    package { 'gawk': }
    package { 'gcc': }
    package { 'gdb': }
    package { 'groff': }
    package { 'info': }
    package { 'intltool': }
    package { 'libtool': }
    package { 'm4': }
    package { 'make': }
    package { 'mtools': }
    package { 'patchutils': }
    package { 'quilt': }
    package { 'recode': }
    package { 'sharutils': }
    package { 'texinfo': }
    package { 'xmlto': }
    package { 'xdelta': }
    package { 'yasm': }

    case $::osfamily {
        'RedHat': {
            package { 'boost-devel': }
            package { 'byacc': }
            package { 'bzip2-devel': }
            package { 'ctags': }
            package { 'diffutils': }
            package { 'expat-devel': }
            package { 'gcc-c++': }
            package { 'gcc-gfortran': }
            package { 'gettext': }
            package { 'lapack': }
            package { 'lapack-devel': }
            package { 'librx-devel': }
            package { 'libstdc++-devel': }
            package { 'meld': }
            package { 'ncurses-devel': }
            package { 'oprofile': }
            package { 'pcre-devel': }
            package { 'perf': }
            package { 'pinfo': }
            package { 'readline-devel': }
            package { 'texi2html': }
            package { 'uuid': }
        }
        'Debian': {
            include master::dev::debian

            package { 'build-essential': }
            package { 'byacc': }
            package { 'cmake-curses-gui': }
            package { 'dkms': }
            package { 'doc-base': }
            package { 'exuberant-ctags': }
            package { 'gettext': }
            package { 'hexedit': }
            package { 'libboost-dev': }
            package { 'libbz2-dev': }
            package { 'libexpat1-dev': }
            package { 'liblapack-dev': }
            package { 'libncurses5-dev': }
            package { 'libpcre3-dev': }
            package { 'manpages-dev': }
            package { 'meld': }
            package { 'pinfo': }
            package { 'pkg-config': }
            package { 'pristine-tar': }
            package { 'texi2html': }
            package { 'uuid': }
            package { 'wdiff': }

            # Readline went from v5 to v6 in Debian Squeeze and had a
            # metapackage applied.
            if versioncmp($::operatingsystemrelease, '6.0') < 0 {
                package { 'libreadline5-dev': }
            }
            else {
                package { 'libreadline-dev': }
            }
            # In Debian Wheezy:
            # * diff became diffutils
            # * automake1.7 is removed
            # * linux-tools contains the perf profiler
            if versioncmp($::operatingsystemrelease, '7.0') < 0 {
                package { 'diff': }
                package { 'automake1.7': }
                package { 'diff-doc': }
            }
            else {
                package { 'diffutils': }
                package { 'diffutils-doc': }
                package { 'linux-headers-amd64': }
                package { 'linux-tools': }
            }
        }
        'Suse': {
            package { 'boost-devel': }
            package { 'ctags': }
            package { 'diffutils': }
            package { 'gcc-c++': }
            package { 'gettext-runtime': }
            package { 'gettext-tools': }
            package { 'ncurses-devel': }
            package { 'oprofile': }
            package { 'pcre-devel': }
            package { 'perf': }
            package { 'readline-devel': }
        }
        default: { }
    }
}
