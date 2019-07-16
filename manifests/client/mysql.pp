class master::client::mysql {
    package { "mysql-client": ensure => latest }
}
