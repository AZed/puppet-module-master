# return the set of active interfaces as an array
# taken from http://git.black.co.at
# modified by nico <nico@gcu.info> to add FreeBSD & Solaris support

Facter.add("interfaces_active") do
  setcode do
    # linux
    if Facter.value('kernel') == "Linux" then
      `ip -o link show`.split(/\n/).collect do |line|
        value = nil
        matches = line.match(/^\d*: ([^:]*): <(.*,)?UP(,.*)?>/)
        if !matches.nil?
          value = matches[1]
          value.gsub!(/@.*/, '')
        end
        value
      end.compact.sort.join(" ")
      #end
      
    # freebsd
    elsif Facter.value('kernel') == "FreeBSD" then
      Facter.value('interfaces').split(/,/).collect do |interface|
        status = `ifconfig #{interface} | grep status`
        if status != "" then
          status=status.strip!.split(":")[1].strip!
          if status == "active" then # I CAN HAZ LINK ?
            interface.to_a
          end
        end
      end.compact.sort.join(" ")
      #end
      
    # solaris
    elsif Facter.value('kernel') == "SunOS" then
      Facter.value('interfaces').split(/,/).collect do |interface|
        if interface != "lo0" then # /dev/lo0 does not exists
          status = `ndd -get /dev/#{interface} link_status`.strip!
          if status == "1" # ndd returns 1 for link up, 0 for down
            interface.to_a
          end
        end
      end.compact.sort.join(" ")
    end
  end
end
