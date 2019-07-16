#
# master::util::pdf
#
# Postscript and PDF handlers
#
# Note that this does NOT include KDE/Gnome-specific viewers such as
# Okular to prevent including a large library chain.
#

class master::util::pdf {
  package { 'ghostscript': }
  package { 'poppler-utils': }
  package { 'xpdf': }

  case $::operatingsystem {
    'debian': {
      package { 'gsfonts': }
    }
    default: { }
  }
}
