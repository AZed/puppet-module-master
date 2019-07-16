#
# master::service::sysstat
#
# Install and configure system performance tools
#

class master::service::sysstat (
    # How long to keep log files (in days)
    $history = '28',

    # Compress sa and sar files older than this in days
    $compressafter = '10',

    # Parameters for sa1 for sysstat v8 or earlier
    $sa1_options = '-d',

    # Parameters for the system activity data collector for v9+
    # Set this to '-S XALL' to collect all available statistics
    $sadc_options = '-S DISK',

    # Where sa and sar files are saved
    $sa_dir = '/var/log/sysstat',

    # Compression program to use (v10.1+ only)
    $zip = 'xz'
)
{
    package { 'sysstat': }

    case $::osfamily {
        'Debian': {
            case $::operatingsystemmajrelease {
                '7': {
                    $sysstat_version = '10'
                }
                '8': {
                    $sysstat_version = '11'
                }
                '9': {
                    $sysstat_version = '11.4'
                }
                default: {
                    $sysstat_version = '11'
                }
            }
            templatelayer { '/etc/sysstat/sysstat':
                suffix => $sysstat_version,
            }
        }
        'RedHat': {
            case $::operatingsystemmajrelease {
                '6': {
                    $sysstat_version = '9'
                }
                '7': {
                    $sysstat_version = '10'
                }
                default: {
                    $sysstat_version = '10'
                }
            }
            templatelayer { '/etc/sysconfig/sysstat':
                suffix => $sysstat_version
            }
        }
        default: { }
    }
    templatelayer { '/etc/cron.d/sysstat':
        suffix => $::osfamily,
    }
}
