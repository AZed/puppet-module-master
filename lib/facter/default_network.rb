#
# Adds facts for default_gateway and default_interface based upon the
# output of 'ip route list'
#
# WARNING: not tested with multiple default routes!
#

Facter.add("default_gateway") do
    gateway=''
    setcode do
        if can_ip then
            `ip route list`.split(/\n/).collect do |line|
                if line =~ /^default via ([0-9.]+) dev (\w+)/
                    interface = $1
                end
            end
        end
        gateway
    end
end

Facter.add('default_interface') do
    interface=''
    setcode do
        if can_ip then
            `ip route list`.split(/\n/).collect do |line|
                if line =~ /^default via ([0-9.]+) dev (\w+)/
                    interface = $2
                end
            end
        end
        interface
    end
end

def can_ip
    ENV['PATH'].split(File::PATH_SEPARATOR).any? do |directory|
        File.executable?(File.join(directory, 'ip'))
    end
end
