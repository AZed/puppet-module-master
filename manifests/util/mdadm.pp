class master::util::mdadm (
  # DEVICE and MAILADDR lines in mdadm.conf
  $device = 'partitions',
  $mailaddr = false
)
{
  package { "mdadm": ensure => installed }
  templatelayer { "/etc/mdadm.conf": parsenodefile => true }
}
