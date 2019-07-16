#
# master::common::editors
# =======================
#
# Standard text editors and plugins to be found on all systems
#
# This list is currently emacs, vim, and nano, plus key associated
# addons
#

class master::common::editors {
    require master::common::package_management

    package { 'emacs': }

    case $::osfamily {
        'Debian': {
            package { 'crypt++el': }
            package { 'emacs-goodies-el': }
            package { 'mmm-mode': }
            package { 'nano': }
            package { 'nvi': }
            package { 'php-elisp': }
            package { 'vim-addon-manager': }
            package { 'vim-gtk': }
            package { 'vim-scripts': }
            package { 'yaml-mode': }
        }
        'RedHat': {
            package { 'emacs-color-theme': }
            package { 'emacs-yaml-mode': }
            package { 'nano': }
            package { 'vim-enhanced': }
            package { 'vim-X11': }
        }
        'Suse': {
            package { 'gvim': }
        }
        default: { }
    }
}
