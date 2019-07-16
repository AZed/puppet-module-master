#
# class master::dev::perl::text
# =============================
#
# Perl packages for text manipulation
#
class master::dev::perl::text {
    include master::dev::perl::base

    case $::osfamily {
        'Debian': {
            package { 'liblocale-gettext-perl': }
            package { 'liblocale-maketext-lexicon-perl': }
            package { 'libtext-aligner-perl': }
            package { 'libtext-charwidth-perl': }
            package { 'libtext-csv-perl': }
            package { 'libtext-csv-xs-perl': }
            package { 'libtext-diff-perl': }
            package { 'libtext-glob-perl': }
            package { 'libtext-iconv-perl': }
            package { 'libtext-markdown-discount-perl': }
            package { 'libtext-markdown-perl': }
            package { 'libtext-multimarkdown-perl': }
            package { 'libtext-simpletable-perl': }
            package { 'libtext-table-perl': }
            package { 'libtext-template-perl': }
            package { 'libtext-wrapi18n-perl': }
        }
        'RedHat': {
            package { 'perl-Locale-Maketext-Simple': }
            package { 'perl-Text-CharWidth': }
            package { 'perl-Text-CSV': }
            package { 'perl-Text-CSV_XS': }
            package { 'perl-Text-Diff': }
            package { 'perl-Text-Glob': }
            package { 'perl-Text-Iconv': }
            package { 'perl-Text-Markdown': }
            package { 'perl-Text-Table-Tiny': }
            package { 'perl-Text-Template': }
            package { 'perl-Text-WrapI18N': }
        }
        default: {
            notify { "${name}-nopackages":
                message => "WARNING: no packages were defined for ${name} on ${::operatingsystem}.",
                loglevel => warning,
            }
        }
    }
}
