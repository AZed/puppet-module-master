#
# class master::dev::perl::xml
# ============================
#
# Install packages related to XML parsing in Perl
#
# This class requires Puppetlabs stdlib
#

class master::dev::perl::xml {
    include master::dev::perl::base

    case $::osfamily {
        'Debian': {
            $packages = [
                'libdata-dumpxml-perl',
                'librpc-xml-perl',
                'libtemplate-plugin-xml-perl',
                'libtest-xml-simple-perl',
                'libxml-atom-perl',
                'libxml-atom-simplefeed-perl',
                'libxml-csv-perl',
                'libxml-dom-perl',
                'libxml-dom-xpath-perl',
                'libxml-dumper-perl',
                'libxml-feed-perl',
                'libxml-feedpp-perl',
                'libxml-filter-buffertext-perl',
                'libxml-generator-perl',
                'libxml-grove-perl',
                'libxml-libxml-perl',
                'libxml-libxslt-perl',
                'libxml-namespacesupport-perl',
                'libxml-parser-perl',
                'libxml-perl',
                'libxml-regexp-perl',
                'libxml-rss-perl',
                'libxml-rss-simplegen-perl',
                'libxml-sax-expat-perl',
                'libxml-sax-machines-perl',
                'libxml-sax-perl',
                'libxml-sax-writer-perl',
                'libxml-semanticdiff-perl',
                'libxml-simple-perl',
                'libxml-smart-perl',
                'libxml-stream-perl',
                'libxml-tidy-perl',
                'libxml-treebuilder-perl',
                'libxml-treepp-perl',
                'libxml-twig-perl',
                'libxml-writer-perl',
                'libxml-xpath-perl',
                'libxml-xpathengine-perl',
                'libxml-xslt-perl',
                'xml-twig-tools',
            ]
        }
        'RedHat': {
            $packages = [
                'perl-RPC-XML',
                'perl-Test-XML',
                'perl-XML-DOM',
                'perl-XML-Dumper',
                'perl-XML-Filter-BufferText',
                'perl-XML-Generator',
                'perl-XML-Generator-DBI',
                'perl-XML-Grove',
                'perl-XML-LibXML',
                'perl-XML-LibXSLT',
                'perl-XML-NamespaceSupport',
                'perl-XML-Parser',
                'perl-XML-RegExp',
                'perl-XML-SAX',
                'perl-XML-SAX-Writer',
                'perl-XML-SemanticDiff',
                'perl-XML-Simple',
                'perl-XML-Smart',
                'perl-XML-Stream',
                'perl-XML-Tidy',
                'perl-XML-TreeBuilder',
                'perl-XML-TreePP',
                'perl-XML-Twig',
                'perl-XML-Writer',
                'perl-XML-XPath',
                'perl-XML-XPathEngine',
            ]
        }
        'Suse': {
            $packages = [
                'perl-RPC-XML',
                'perl-XML-DOM',
                'perl-XML-Dumper',
                'perl-XML-LibXML',
                'perl-XML-LibXSLT',
                'perl-XML-NamespaceSupport',
                'perl-XML-Parser',
                'perl-XML-RegExp',
                'perl-XML-SAX',
                'perl-XML-Simple',
                'perl-XML-Stream',
                'perl-XML-Twig',
                'perl-XML-Writer',
                'perl-XML-XPath',
            ]
        }
        default: {
            notify { "${name}-nopackages":
                message => "WARNING: no packages were defined for ${name} on ${::operatingsystem}.",
                loglevel => warning,
            }
        }
    }
    ensure_packages($packages)
}
