#
# fact initsystem
# ===============
#
# Returns the content of /proc/1/comm, usually 'systemd' or 'init'
#
Facter.add(:initsystem) do
    confine :kernel => "Linux"
    setcode do
        File.open('/proc/1/comm', 'r') do |file|
            file.gets
        end
    end
end
