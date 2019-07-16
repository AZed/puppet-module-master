# Show a reasonable default value of JAVA_HOME for the installed system java

Facter.add('java_home_default') do
    setcode do
        # linux
        if Facter.value('kernel') == "Linux" then
            javahome = `dirname $(dirname $(readlink -f /etc/alternatives/java))`
        end

        # /usr is a possible outcome of having /etc/alternatives/java
        # point at some java alternatives such as gij, so we discard
        # it
        if javahome == '/usr'
            false
        else
            javahome
        end
    end
end
