<?php
define('DB_HOST', '<%= @mysql_host %>');
define('DB_NAME', '<%= @mysql_db %>');
define('DB_PASSWORD', '<%= @mysql_pass %>');
define('DB_USER', '<%= @mysql_user %>');
<% if @config_lines -%>

<%   @config_lines.each do |line| -%>
<%= line %>
<%   end -%>
<% end -%>
?>
