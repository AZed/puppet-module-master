#
# master::dev::perl::db
# =====================
#
# Install packages used for Perl database handling
#

class master::dev::perl::db {
    include master::dev::perl::base

    case $::osfamily {
        'RedHat': {
            package { 'perl-DBD-MySQL': }
            package { 'perl-DBD-Pg': }
            package { 'perl-DBD-CSV': }
            package { 'perl-DBD-ODBC': }
            package { 'perl-DBD-SQLite': }
            package { 'perl-DBI': }
            package { 'perl-DBIx-Simple': }
        }
        'Debian': {
            package { 'libclass-dbi-abstractsearch-perl': }
            package { 'libclass-dbi-loader-perl': }
            package { 'libclass-dbi-mysql-perl': }
            package { 'libclass-dbi-perl': }
            package { 'libclass-dbi-pg-perl': }
            package { 'libclass-dbi-sqlite-perl': }
            package { 'libdatetime-format-db2-perl': }
            package { 'libdb-file-lock-perl': }
            package { 'libdbd-csv-perl': }
            package { 'libdbd-excel-perl': }
            package { 'libdbd-ldap-perl': }
            package { 'libdbd-mysql-perl': }
            package { 'libdbd-odbc-perl': }
            package { 'libdbd-pg-perl': }
            package { 'libdbd-sqlite3-perl': }
            package { 'libdbi-perl': }
            package { 'libdbix-abstract-perl': }
            package { 'libdbix-class-datetime-epoch-perl': }
            package { 'libdbix-class-perl': }
            package { 'libdbix-class-schema-loader-perl': }
            package { 'libdbix-contextualfetch-perl': }
            package { 'libdbix-datasource-perl': }
            package { 'libdbix-dbschema-perl': }
            package { 'libdbix-easy-perl': }
            package { 'libdbix-fulltextsearch-perl': }
            package { 'libdbix-password-perl': }
            package { 'libdbix-profile-perl': }
            package { 'libdbix-recordset-perl': }
            package { 'libdbix-searchbuilder-perl': }
            package { 'libdbix-sequence-perl': }
            package { 'libima-dbi-perl': }
            package { 'libmldbm-perl': }
            package { 'libmldbm-sync-perl': }
            package { 'libtemplate-plugin-dbi-perl': }
        }
        default: { }
    }
}
