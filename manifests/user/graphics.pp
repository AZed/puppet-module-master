#
# master::user::graphics
# ======================
#
# End-user packages related to graphics viewing/editing
#

class master::user::graphics {
    $global_packages = [
        "dia",
        "gimp",
        "gimp-help-en",
        "gimp-data-extras",
        "liblcms-utils",
        "gqview",
        "qiv",
        "transfig",
        "xfig","xfig-doc","xfig-libs",
    ]
    ensure_packages($global_packages)

    case $::osfamily {
        'Debian': {
            $os_packages = [
                'caca-utils',
                'figlet',
            ]
        }
        'RedHat': {
            $os_packages = [
                'caca-utils',
                'figlet',
            ]
        }
        default: { $os_packages = [] }
    }
    ensure_packages($os_packages)
}
