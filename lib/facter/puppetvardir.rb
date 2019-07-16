# puppet_vardir.rb

require 'puppet'

Facter.add("puppetvardir") do
 setcode do
   Puppet.settings[:vardir]
 end
end

