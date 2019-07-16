#
# master::user::tex
#
# TeX/LaTeX Typesetting Language Tools
#

class master::user::tex {
  include master::common::editors
  $user_tex_packages =
  [ "auctex",
    "catdvi",
    "dvidvi",
    "dvipng",
    "prosper",
    "texlive",
    ]
  package { $user_tex_packages: ensure => latest }
}
