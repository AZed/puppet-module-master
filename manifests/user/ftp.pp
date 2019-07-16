#
# master::user::ftp
#
# Commonly used end-user FTP clients
#

class master::user::ftp {
    package {
        [
         "ftp",
         "lftp",
         "ncftp",
         "tnftp",
         ]: ensure => latest
    }
}
