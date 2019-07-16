# Note that this specifically excludes:
#  master::dev::perl::apache
#  master::dev::php
# as these would pull Apache
#
class master::dev {
  include master::dev::audio
  include master::dev::base
  include master::dev::crypt
  include master::dev::cvs
  include master::dev::db
  include master::dev::debian
  include master::dev::git
  include master::dev::graph
  include master::dev::graphics
  include master::dev::gnome
  include master::dev::gui
  include master::dev::java
  include master::dev::net
  include master::dev::pam
  include master::dev::perl
  include master::dev::python
  include master::dev::ruby
  include master::dev::subversion
  include master::dev::tcl
  include master::dev::video
  include master::dev::xml
}
