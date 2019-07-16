# Meta-class that includes all user packages
class master::user {
  Class['master::common'] -> Class[$name]

  include master::user::db
  include master::user::desktop
  include master::user::email
  include master::user::fonts
  include master::user::ftp
  include master::user::graphics
  include master::user::misc
  include master::user::office
  include master::user::printing
  include master::user::sci
  include master::user::tex
  include master::user::web
  include master::user::x11
}
