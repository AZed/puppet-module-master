#
# class master::service::acpi
# ===========================
#
# Installs the ACPI daemon and event tools
#
# Using this class by default on virtual systems is recommended if you
# intend to be able to remotely shut down guests.
#

class master::service::acpi {
    case $::operatingsystem {
        'debian','ubuntu': {
            if versioncmp($::operatingsystemrelease, '7.0') >= 0 {
                package { 'acpid': }
                package { 'acpi-support': }
            }
            else {
                package { 'acpid': }
            }
        }
        'SLES': {
            if versioncmp($::operatingsystemrelease, '12.0') < 0 {
                package { 'acpid': }
            }
            else {
                package { 'acpica': }
            }
        }
        default: {
            package { 'acpid': }
        }
    }
}
