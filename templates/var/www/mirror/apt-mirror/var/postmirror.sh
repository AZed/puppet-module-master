# Apt-Mirror has broken handling for Debian Jessie
find "<%= @mirror_server -%>/debian/dists/jessie" -name "InRelease" -exec rm {} \;
find "<%= @mirror_server -%>/debian/dists/jessie" -name "Packages.bz2" -exec rm {} \;
find "<%= @mirror_server -%>/debian/dists/jessie" -name "Sources.bz2" -exec rm {} \;

<% if @postmirror_templates -%>
<%   @postmirror_templates.each do |template| -%>
<%= scope.function_template(["#{template}"]) -%>

<%   end -%>
<% end -%>
<% if @postmirror_lines -%>
<%   @postmirror_lines.each do |line| -%>
<%= line %>
<%   end -%>
<% end -%>
