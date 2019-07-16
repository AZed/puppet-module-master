#
# master::user::db
# ================
#
# End-user database manipulation packages
#

class master::user::db {
    include master::client::mysql
    include master::client::postgresql

    Package { ensure => latest }

    package { "pgadmin3": }
}
