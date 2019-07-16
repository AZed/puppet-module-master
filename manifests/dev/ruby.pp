#
# class master::dev::ruby
# =======================
#
# Installs a Ruby development environment
#
# (Warning: package lists are no longer comprehensive)
#

class master::dev::ruby {
    include master::common::ruby

    case $::operatingsystem {
        'Debian': {
            package { 'librdf-ruby': }
            package { 'libruby': }
            package { 'rails': }
            package { 'rake': }
            package { 'ruby-activeldap': }
            package { 'ruby-bsearch': }
            package { 'ruby-builder': }
            package { 'ruby-cmdparse': }
            package { 'ruby-color-tools': }
            package { 'ruby-diff-lcs': }
            package { 'ruby-erubis': }
            package { 'ruby-exif': }
            package { 'ruby-extlib': }
            package { 'ruby-facets': }
            package { 'ruby-gettext': }
            package { 'ruby-git': }
            package { 'ruby-gstreamer': }
            package { 'ruby-htmlentities': }
            package { 'ruby-image-science': }
            package { 'ruby-inline': }
            package { 'ruby-libxml': }
            package { 'ruby-mechanize': }
            package { 'ruby-mocha': }
            package { 'ruby-ncurses': }
            package { 'ruby-openid': }
            package { 'ruby-pg': }
            package { 'ruby-progressbar': }
            package { 'ruby-rack': }
            package { 'ruby-redcloth': }
            package { 'ruby-rubymail': }
            package { 'ruby-sequel': }
            package { 'ruby-sqlite3': }
            package { 'ruby-text-format': }
            package { 'ruby-validatable': }
            package { 'ruby-xml-simple': }
            package { 'ruby-yajl': }
            package { 'universalindentgui': }

            if versioncmp($::operatingsystemrelease, '9.0') < 0 {
                package { 'libtcltk-ruby': }
                package { 'ruby-algorithm-diff': }
                package { 'ruby-dbd-mysql': }
                package { 'ruby-dbd-pg': }
                package { 'ruby-dbi': }
                package { 'ruby-mysql': }
                package { 'ruby-transaction-simple': }
            }
            else {
                package { 'ruby-mysql2': }
                package { 'ruby-tcltk': }
            }
            if versioncmp($::operatingsystemrelease, '8.0') >= 0 {
                package { 'ruby-buftok': }
                package { 'ruby-commander': }
                package { 'ruby-diffy': }
                package { 'ruby-fcgi': }
                package { 'ruby-jwt': }
                package { 'ruby-rainbow': }
                package { 'ruby-rrd': }
                package { 'ruby-zip': }
            }
        }
        'centos','redhat': {
            package { 'rubygem-rake': }
        }
    }
}
