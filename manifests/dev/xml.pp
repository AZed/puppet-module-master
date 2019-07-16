#
# master::dev::xml
#
# Development packages related to XML
#

class master::dev::xml {

    case $::operatingsystem {
        'centos','redhat': {
            package { 'libxml2-devel': }
            package { 'libxslt-devel': }
        }
        'debian': {
            package { 'libxml2-dev': }
            package { 'libxslt1-dev': }
        }
        default: { }
    }
}
