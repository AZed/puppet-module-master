#
# Distribute and recompile a postfix table
#
# if templates are specified, they will be concatenated instead of
# using whatever is found from the title
#

define master::postfix_table (
    $owner     = 'root',
    $group     = 'root',
    $mode      = '0444',
    $backup    = undef,
    $dir       = '/etc/postfix',
    $module    = $caller_module_name,
    $templates = false,
    $params    = false
) {
    include master::service::postfix

    $target = "${dir}/${title}"

    if $templates {
        $template = 'master/concat.erb'
    }
    else {
        $template = undef
    }

    @templatelayer { $target:
        owner    => $owner,
        group    => $group,
        mode     => $mode,
        backup   => $backup,
        module   => $module,
        template => $template,
        tag      => 'postfix_table',
    }

    master::postmap { $target: }
}
