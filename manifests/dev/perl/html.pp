#
# master::dev::perl::html
# =======================
#
# Installs packages related to Perl HTML parsing
#
# Excludes the Mason framework, which is in master::dev::perl::web
# Excludes templating, which is in master::dev::perl::template
#
# Included from master::dev::perl::web
#

class master::dev::perl::html {
    include master::dev::perl::base

    case $::operatingsystem {
        'centos','redhat': {
            package { 'perl-HTML-Entities-Numbered': }
            package { 'perl-HTML-Format': }
            package { 'perl-HTML-Parser': }
            package { 'perl-HTML-Scrubber': }
            package { 'perl-HTML-StripScripts': }
            package { 'perl-HTML-StripScripts-Parser': }
            package { 'perl-HTML-TableExtract': }
            package { 'perl-HTML-Tagset': }
            package { 'perl-HTML-Tidy': }
            package { 'perl-HTML-Tree': }
        }
        'debian': {
            package { 'libdbix-class-htmlwidget-perl': }
            package { 'libhtml-calendarmonth-perl': }
            package { 'libhtml-calendarmonthsimple-perl': }
            package { 'libhtml-clean-perl': }
            package { 'libhtml-display-perl': }
            package { 'libhtml-element-extended-perl': }
            package { 'libhtml-entities-numbered-perl': }
            package { 'libhtml-fillinform-perl': }
            package { 'libhtml-format-perl': }
            package { 'libhtml-fromtext-perl': }
            package { 'libhtml-lint-perl': }
            package { 'libhtml-parser-perl': }
            package { 'libhtml-prototype-perl': }
            package { 'libhtml-simpleparse-perl': }
            package { 'libhtml-table-perl': }
            package { 'libhtml-tableextract-perl': }
            package { 'libhtml-tagset-perl': }
            package { 'libhtml-tidy-perl': }
            package { 'libhtml-tiny-perl': }
            package { 'libhtml-tokeparser-simple-perl': }
            package { 'libhtml-tree-perl': }
            package { 'libhtml-treebuilder-xpath-perl': }
            package { 'libhtml-widget-perl': }
            package { 'libmojolicious-perl': }
            package { 'libppi-html-perl': }
            package { 'weblint-perl': }

            if versioncmp($::operatingsystemrelease, '7.0') >= 0 {
                package { 'libhtml-scrubber-perl': }
                package { 'libhtml-stripscripts-parser-perl': }
                package { 'libhtml-stripscripts-perl': }
            }
        }
        default: { }
    }
}
