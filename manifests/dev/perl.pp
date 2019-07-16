#
# master::dev::perl
#
# This is a meta-class that simply includes all other perl classes at once.
#

class master::dev::perl {
    include master::dev::perl::authen
    include master::dev::perl::base
    include master::dev::perl::config
    include master::dev::perl::crypt
    include master::dev::perl::date
    include master::dev::perl::db
    include master::dev::perl::digest
    include master::dev::perl::email
    include master::dev::perl::file
    include master::dev::perl::graphics
    include master::dev::perl::io
    include master::dev::perl::json
    include master::dev::perl::ldap
    include master::dev::perl::misc	# THIS WILL GO AWAY EVENTUALLY!
    include master::dev::perl::module
    include master::dev::perl::net
    include master::dev::perl::sort
    include master::dev::perl::oo
    include master::dev::perl::template
    include master::dev::perl::term
    include master::dev::perl::test
    include master::dev::perl::text
    include master::dev::perl::unicode
    include master::dev::perl::utils
    include master::dev::perl::uuid
    include master::dev::perl::web
    include master::dev::perl::xml
}
