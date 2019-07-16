#
# master::user::web
# =================
#
# End-user web browsing packages
#

class master::user::web {
    include master::user::fonts
    include master::user::x11

    case $operatingsystem {
        'CentOS','RedHat': {
            if versioncmp($::operatingsystemrelease, '7.0') >= 0 {
                package { 'chromium': }
            }
            $os_packages = [
                'firefox',
                'lynx',
            ]
        }
        'Debian','Ubuntu': {
            package { 'lynx-cur': alias => 'lynx' }
            $os_packages = [
                'chromium',
                'iceweasel',
                'links',
                'xul-ext-dom-inspector',
                'xul-ext-firebug',
                'xul-ext-flashgot',
                'xul-ext-greasemonkey',
                'xul-ext-itsalltext',
                'xul-ext-livehttpheaders',
                'xul-ext-openinbrowser',
                'xul-ext-refcontrol',
                'xul-ext-scrapbook',
                'xul-ext-tabmixplus',
                'xul-ext-useragentswitcher',
            ]
        }
        default: { $os_packages = [] }
    }
    ensure_packages($os_packages)
}
