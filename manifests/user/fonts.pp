#
# class master::user::fonts
# =========================
#
# End-user font packages, including the base X11 fonts
#

class master::user::fonts {
    case $::operatingsystem {
        'CentOS','RedHat': {
            package { 'dejavu-fonts-common': }
            package { 'dejavu-sans-fonts': }
            package { 'dejavu-sans-mono-fonts': }
            package { 'dejavu-serif-fonts': }
            package { 'xorg-x11-fonts-100dpi': }
            package { 'xorg-x11-fonts-75dpi': }
            package { 'xorg-x11-fonts-ISO8859-1-100dpi': }
            package { 'xorg-x11-fonts-ISO8859-1-75dpi': }
            package { 'xorg-x11-fonts-Type1': }
            package { 'xorg-x11-fonts-cyrillic': }
            package { 'xorg-x11-fonts-ethiopic': }
            package { 'xorg-x11-fonts-misc': }
        }
        'Debian': {
            package { 'fontconfig': }
            package { 'fonts-dustin': }
            package { 'fonts-f500': }
            package { 'fonts-lao': }
            package { 'fonts-mathjax': }
            package { 'fonts-ocr-a': }
            package { 'fonts-opensymbol': }
            package { 'fonts-sil-ezra': }
            package { 'fonts-sil-gentium': }
            package { 'fonts-vlgothic': }
            package { 'ttf-bitstream-vera': }
            package { 'ttf-dejavu': }
            package { 'ttf-engadget': }
            package { 'ttf-essays1743': }
            package { 'ttf-freefont': }
            package { 'ttf-goudybookletter': }
            package { 'ttf-isabella': }
            package { 'ttf-liberation': }
            package { 'ttf-opensymbol': }
            package { 'ttf-radisnoir': }
            package { 'ttf-staypuft': }
            package { 'ttf-summersby': }
            package { 'xfonts-cyrillic': }
            package { 'xfonts-intl-arabic': }
            package { 'xfonts-intl-chinese': }
            package { 'xfonts-intl-chinese-big': }
            package { 'xfonts-intl-european': }
            package { 'xfonts-intl-japanese': }
            package { 'xfonts-intl-japanese-big': }
            package { 'xfonts-nexus': }
            package { 'xfonts-scalable': }
            package { 'xfonts-terminus': }
            package { 'xfonts-terminus-dos': }

            # In Debian Wheezy or later:
            if versioncmp($::operatingsystemrelease, '7.0') >= 0 {
                package { 'fonts-cantarell': }
            }

            # In Debian Jessie or later:
            if versioncmp($::operatingsystemrelease, '8.0') >= 0 {
                package { 'fonts-crosextra-caladea': }
                package { 'fonts-crosextra-carlito': }
                package { 'ttf-aenigma': }
            }

            # In Debian Stretch or later:
            if versioncmp($::operatingsystemrelease, '9.0') >= 0 {
                package { 'fonts-hack-otf': }
                package { 'fonts-hack-ttf': }
                package { 'fonts-hack-web': }
                package { 'fonts-symbola': }
            }
        }
        default: { }
    }
}
