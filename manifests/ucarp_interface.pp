# a class to configure ucarp nominally on debian, and more extensively on centos.
# debian, alas, handles ucarp more sanely. centos/rhel need extra help.
# master::util;:ucarp::interface is a define to try and handle ucarp for centos-types using systemd
#
# For debian systems, ucarp directives can be controlled directly in the /etc/network/interfaces or interfaces.d/ files
#such as:
# ucarp-vid 1
# ucarp-vip 333.222.111
# ucarp-password mypass32
# ucarp-advskew 1
# ucarp-advbase 1
# ucarp-master no
#
# for centos, I've made this parameterized and controllable via hiera.
# Something like the following in an appropriate heira file:
#master::util::ucarp::interfaces:
#  vip061:
#    id : 61 # a unique CARP ID. Required, and needs to be unique on the subnet
#    vip_address : 10.1.254.9 # the virtual shared IP address. Required.
#    bind_interface : bond0.061 # the interface on the system holding the virtual VIP. Required.
#    source_address : 10.1.254.31 # the "real" address on the interface for CARP control traffic. Required.
#    password : foo # The CARP sync password. Needs to be generated. Should be unique. Approx 16 characters, be careful of special characters. Required.
#    advskew : 20 # how fast/often the system tries to become master. In a CARP pair, one should have a lower advskew than the other. Required for puppet manifest.
#  vip062:
#    id : 62
#    vip_address : 10.2.254.9
#    bind_interface : bond0.062
#    source_address : 10.2.254.31
#    password : foo2
#    advskew : 20
#

define master::ucarp_interface (
   $id=undef, 
   $bind_interface=undef, 
   $vip_address=undef, 
   $source_address=undef, 
   $password=undef, 
   $advskew=undef ) 
{
   # work: check values for existence

   unless $id {  fail("master:;util::ucarp::interface needs a VHID id passed to it as a parameter.") }
   unless $bind_interface  {  fail("master:;util::ucarp::interface needs a VHID bind_interface passed to it as a parameter.") }
   unless $vip_address {  fail("master:;util::ucarp::interface needs a VHID vip_address passed to it as a parameter.") }
   unless $source_address {  fail("master:;util::ucarp::interface needs a VHID source_address passed to it as a parameter.") }
   unless $password {  fail("master:;util::ucarp::interface needs a VHID password passed to it as a parameter.") }
   unless $advskew {  fail("master:;util::ucarp::interface needs a VHID advskew passed to it as a parameter.") }
   $ucarp_conf_file="/etc/ucarp/vip-${id}.conf"
   $ucarp_pwd_file="/etc/ucarp/vip-${id}.pwd"
   $ucarp_systemd_service="ucarp@${id}"
   file {$ucarp_conf_file: 
       content => template('master/etc/ucarp/vip-template.conf'),
       ensure => file,
       mode => '0600',
       require => File['/etc/ucarp']
   }

   file {$ucarp_pwd_file: 
       content => template('master/etc/ucarp/vip-template.pwd'),
       ensure => file,
       mode => '0600',
       require => File['/etc/ucarp']
   }

   # work: enable service ucarp@$id via systemctl
   service { $ucarp_systemd_service:
      enable => true,
   }

}
