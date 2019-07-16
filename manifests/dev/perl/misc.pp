#
# master::dev::perl::misc
# =======================
#
# DO NOT CALL THIS CLASS DIRECTLY
#
# This is a dumping ground for legacy Debian-specific Perl packages
# that were never refactored into cross-OS, category-specific classes,
# and should only be include from master::dev::perl.
#
# If you need something listed here and don't want the entire Perl
# development environment, it's your responsibility to refactor it out
# first, because packages here WILL be refactored out eventually
# without any attempt at retaining backwards compatibility.
#

class master::dev::perl::misc {
    Package { ensure => installed }

    include master::dev::perl::data_compare

    case $::operatingsystem {
        'debian': {
            package { 'libalgorithm-c3-perl': }
            package { 'libalgorithm-dependency-perl': }
            package { 'libalgorithm-diff-perl': }
            package { 'libanydata-perl': }
            package { 'libarchive-zip-perl': }
            package { 'libarray-compare-perl': }
            package { 'libarray-refelem-perl': }
            package { 'libb-keywords-perl': }
            package { 'libb-utils-perl': }
            package { 'libbit-vector-perl': }
            package { 'libcache-cache-perl': }
            package { 'libcache-fastmmap-perl': }
            package { 'libcache-memcached-perl': }
            package { 'libcache-perl': }
            package { 'libcache-simple-timedexpiry-perl': }
            package { 'libcalendar-simple-perl': }
            package { 'libcarp-assert-more-perl': }
            package { 'libcarp-assert-perl': }
            package { 'libcarp-clan-perl': }
            package { 'libchart-perl': }
            package { 'libclass-accessor-chained-perl': }
            package { 'libclass-accessor-grouped-perl': }
            package { 'libclass-accessor-perl': }
            package { 'libclass-autouse-perl': }
            package { 'libclass-base-perl': }
            package { 'libclass-c3-componentised-perl': }
            package { 'libclass-c3-perl': }
            package { 'libclass-c3-xs-perl': }
            package { 'libclass-container-perl': }
            package { 'libclass-data-accessor-perl': }
            package { 'libclass-data-inheritable-perl': }
            package { 'libclass-errorhandler-perl': }
            package { 'libclass-factory-perl': }
            package { 'libclass-factory-util-perl': }
            package { 'libclass-inner-perl': }
            package { 'libclass-inspector-perl': }
            package { 'libclass-makemethods-perl': }
            package { 'libclass-meta-perl': }
            package { 'libclass-methodmaker-perl': }
            package { 'libclass-returnvalue-perl': }
            package { 'libclass-singleton-perl': }
            package { 'libclass-spiffy-perl': }
            package { 'libclass-std-perl': }
            package { 'libclass-throwable-perl': }
            package { 'libclass-trigger-perl': }
            package { 'libclone-perl': }
            package { 'libconvert-asn1-perl': }
            package { 'libconvert-ber-perl': }
            package { 'libconvert-binhex-perl': }
            package { 'libconvert-tnef-perl': }
            package { 'libconvert-units-perl': }
            package { 'libconvert-uulib-perl': }
            package { 'libcurses-perl': }
            package { 'libcurses-ui-perl': }
            package { 'libcurses-widgets-perl': }
            package { 'libdata-buffer-perl': }
            package { 'libdata-dump-perl': }
            package { 'libdata-dump-streamer-perl': }
            package { 'libdata-dumper-simple-perl': }
            package { 'libdata-formvalidator-perl': }
            package { 'libdata-optlist-perl': }
            package { 'libdata-page-perl': }
            package { 'libdata-password-perl': }
            package { 'libdata-random-perl': }
            package { 'libdata-serializer-perl': }
            package { 'libdata-sorting-perl': }
            package { 'libdata-types-perl': }
            package { 'libdata-validate-domain-perl': }
            package { 'libdata-validate-ip-perl': }
            package { 'libdata-visitor-perl': }
            package { 'libdata-walk-perl': }
            package { 'libdelimmatch-perl': }
            package { 'libdevel-caller-perl': }
            package { 'libdevel-cover-perl': }
            package { 'libdevel-profile-perl': }
            package { 'libdevel-size-perl': }
            package { 'libdevel-stacktrace-perl': }
            package { 'libdevel-symdump-perl': }
            package { 'liberror-perl': }
            package { 'libexception-class-perl': }
            package { 'libexpect-perl': }
            package { 'libexpect-simple-perl': }
            package { 'libexporter-lite-perl': }
            package { 'libextutils-autoinstall-perl': }
            package { 'libfeed-find-perl': }
            package { 'libfilter-perl': }
            package { 'libfont-afm-perl': }
            package { 'libformvalidator-simple-perl': }
            package { 'libfreezethaw-perl': }
            package { 'libgeo-coordinates-utm-perl': }
            package { 'libgeo-ip-perl': }
            package { 'libgeo-ipfree-perl': }
            package { 'libgeo-metar-perl': }
            package { 'libgetargs-long-perl': }
            package { 'libgetopt-argvfile-perl': }
            package { 'libgetopt-declare-perl': }
            package { 'libgetopt-long-descriptive-perl': }
            package { 'libgetopt-mixed-perl': }
            package { 'libglib-perl': }
            package { 'libgnupg-interface-perl': }
            package { 'libgraph-perl': }
            package { 'libgraphviz-perl': }
            package { 'libgssapi-perl': }
            package { 'libheap-perl': }
            package { 'libhook-lexwrap-perl': }
            package { 'libhttp-body-perl': }
            package { 'libhttp-server-simple-perl': }
            package { 'libi18n-charset-perl': }
            package { 'libimap-admin-perl': }
            package { 'libinline-perl': }
            package { 'libipc-run-perl': }
            package { 'libipc-shareable-perl': }
            package { 'libipc-sharedcache-perl': }
            package { 'libipc-sharelite-perl': }
            package { 'libjcode-pm-perl': }
            package { 'liblingua-en-inflect-number-perl': }
            package { 'liblingua-en-inflect-perl': }
            package { 'liblingua-en-numbers-ordinate-perl': }
            package { 'liblist-moreutils-perl': }
            package { 'liblockfile-simple-perl': }
            package { 'liblog-agent-logger-perl': }
            package { 'liblog-agent-perl': }
            package { 'liblog-agent-rotate-perl': }
            package { 'liblog-dispatch-perl': }
            package { 'liblog-log4perl-perl': }
            package { 'liblog-trace-perl': }
            package { 'liblogfile-rotate-perl': }
            package { 'libmail-box-perl': }
            package { 'libmail-gnupg-perl': }
            package { 'libmail-sendmail-perl': }
            package { 'libmailtools-perl': }
            package { 'libmath-basecalc-perl': }
            package { 'libmath-bigint-gmp-perl': }
            package { 'libmath-gmp-perl': }
            package { 'libmath-numbercruncher-perl': }
            package { 'libmime-base64-urlsafe-perl': }
            package { 'libmime-lite-perl': }
            package { 'libmime-tools-perl': }
            package { 'libmime-types-perl': }
            package { 'libmro-compat-perl': }
            package { 'libnumber-compare-perl': }
            package { 'libobject-realize-later-perl': }
            package { 'libobject-signature-perl': }
            package { 'libole-storage-lite-perl': }
            package { 'libpadwalker-perl': }
            package { 'libpar-dist-perl': }
            package { 'libparams-util-perl': }
            package { 'libparams-validate-perl': }
            package { 'libparse-debcontrol-perl': }
            package { 'libparse-debianchangelog-perl': }
            package { 'libparse-recdescent-perl': }
            package { 'libpath-class-perl': }
            package { 'libperl6-junction-perl': }
            package { 'libpg-perl': }
            package { 'libpgp-sign-perl': }
            package { 'libphp-serialization-perl': }
            package { 'libpod-simple-perl': }
            package { 'libpod-spell-perl': }
            package { 'libpod-tests-perl': }
            package { 'libppi-perl': }
            package { 'libprefork-perl': }
            package { 'libproc-fork-perl': }
            package { 'libreadonly-perl': }
            package { 'libreadonly-xs-perl': }
            package { 'libregexp-common-perl': }
            package { 'libscalar-properties-perl': }
            package { 'libscope-guard-perl': }
            package { 'libset-object-perl': }
            package { 'libsoap-lite-perl': }
            package { 'libspiffy-perl': }
            package { 'libspreadsheet-parseexcel-perl': }
            package { 'libspreadsheet-writeexcel-perl': }
            package { 'libsql-abstract-limit-perl': }
            package { 'libsql-abstract-perl': }
            package { 'libsql-statement-perl': }
            package { 'libsql-translator-perl': }
            package { 'libstring-approx-perl': }
            package { 'libstring-crc32-perl': }
            package { 'libstring-escape-perl': }
            package { 'libstring-format-perl': }
            package { 'libstring-random-perl': }
            package { 'libstring-shellquote-perl': }
            package { 'libsub-exporter-perl': }
            package { 'libsub-identify-perl': }
            package { 'libsub-install-perl': }
            package { 'libsub-name-perl': }
            package { 'libsub-uplevel-perl': }
            package { 'libsys-hostname-long-perl': }
            package { 'libtask-weaken-perl': }
            package { 'libtie-ixhash-perl': }
            package { 'libtie-toobject-perl': }
            package { 'libtime-piece-mysql-perl': }
            package { 'libtree-dagnode-perl': }
            package { 'libtree-simple-perl': }
            package { 'libtree-simple-visitorfactory-perl': }
            package { 'libuniversal-can-perl': }
            package { 'libuniversal-exports-perl': }
            package { 'libuniversal-isa-perl': }
            package { 'libuniversal-moniker-perl': }
            package { 'libuniversal-require-perl': }
            package { 'liburi-fetch-perl': }
            package { 'liburi-perl': }
            package { 'libuser-identity-perl': }
            package { 'libuser-perl': }
            package { 'libvcs-lite-perl': }
            package { 'libwant-perl': }
            package { 'libyaml-perl': }
            package { 'libyaml-syck-perl': }
            package { 'libyaml-tiny-perl': }
        }
        default: {
        }
    }
}
