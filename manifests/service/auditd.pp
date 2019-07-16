#
# master::service::auditd
# =======================
#
# Configure the Linux Kernel Audit subsystem
#
# Audit rules are managed by inserting templates from other modules
#
# For the sake of simplicity, auditd.conf itself is not currently
# managed and will be left with system defaults
#
# This class is a wrapper to nccs::service;:auditd. As more site specific configurations were added,
# this class needed to move.
#
# DEV note: when this class is removed, the links from nccs/etc/audit to master/etc/audit should also be removed

class master::service::auditd (
    # Parameters
    # ----------

    # ### audit_rules_templates
    # Templates to insert into /etc/audit/audit.rules
    # e.g. [ 'mymodule/etc/audit/set1.rules', 'mymodule/etc/audit/set2.rules' ]
    $audit_rules_templates =
    [ 'nccs/etc/audit/base.rules',
      'nccs/etc/audit/setuid.rules',
      'nccs/etc/audit/aide.rules',
    ],

    # ### auditd_buffers
    # Max number of outstanding audit buffers
    $auditd_buffers = '320',

    # ### auditd_clean_stop
    # Delete rules & watches on shutdown?  Valid values are 'yes' and 'no'
    $auditd_clean_stop = 'yes',

    # ### auditd_disable_contexts
    # Disable syscall auditing by default?  Valid values are 'yes' and 'no'
    # This option is only used on SLES
    $auditd_disable_contexts = 'yes',

    # ### auditd_extraoptions
    # Extra options to pass to auditctl
    $auditd_extraoptions = '',

    # ### auditd_ignore_rules_errors
    # Ignore errors when reading rules from a file.  This causes auditctl
    # to always return a success exit code.
    $auditd_ignore_rules_errors = false,

    # ### auditd_lang
    # Locale for auditd.  To remove all locale information set to 'none'
    $auditd_lang = 'en_US',

    # ### auditd_log_handler
    $auditd_log_handler = 'audisp',

    # ### audisp_syslog
    # The arguments to the audisp syslog plugin, normally used to set
    # the priority and facility.  If this is set to false, the audisp
    # syslog plugin will be completely disabled (e.g. because you are
    # planning to use rsyslog imfile instead).
    #
    # Unfortunately the available options vary quite widely by
    # version, so the default is the lowest common denominator
    # supported by the oldest version still being shipped by a
    # supported OS.
    $audisp_syslog = 'LOG_INFO'
)
{

   notify { "master-service-audit-is-dead":
      message => "WARNING: master::service;:audit is slated for removal. This is a shell to redirect to nccs::service::audit. Please update your host definitions accordingly. WARNING: master::service::audit is slated for removal.",
      loglevel => warning,
   }

   class { "nccs::service::auditd":
      audisp_syslog => $audisp_syslog,
      auditd_log_handler => $auditd_log_handler,
      auditd_lang => $auditd_lang,
      auditd_ignore_rules_errors => $auditd_ignore_rules_errors,
      auditd_extraoptions => $auditd_extraoptions,
      auditd_disable_contexts => $auditd_disable_contexts,
      auditd_clean_stop => $auditd_clean_stop,
      auditd_buffers => $auditd_buffers,
      audit_rules_templates => $audit_rules_templates,
   }


}
