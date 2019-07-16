#
# efi.rb
#
# Detect if a system boots via EFI
#
# This is a somewhat primitive check that simply tests for the
# existence of /sys/firmware/efi, and returns a boolean true if found
# and false if not.
#
# Note: due to boolean problems in older versions; nil is returned
#   in place of false for versions older than 4.0.0.
#
require 'facter'
Facter.add(:efi) do
    confine :kernel => "Linux"
    setcode do
        if File.directory?('/sys/firmware/efi')
            true
        else
            puppet_ver = Facter.value("puppetversion")
            if Gem::Version.new(puppet_ver) >= Gem::Version.new('4.0.0')
                false
            else
                nil
            end
        end
    end
end
