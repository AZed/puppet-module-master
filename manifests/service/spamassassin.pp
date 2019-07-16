#
# master::service::spamassassin
#
# Install and configure the SpamAssassin spam filter
#

class master::service::spamassassin (
    # Rewrite header of spam mail, e.g.:
    #   $rewrite_header = 'Subject *****SPAM*****'
    $rewrite_header = false,

    # Save spam messages as a message/rfc822 MIME attachment instead
    # of modifying the original message
    $report_safe = true,

    # Array of trusted CIDR ranges
    $trusted_networks = false,

    # Spam threshhold
    $required_score = '5.0',

    # Enable Bayesian classifier
    $use_bayes = true,

    # Bayesian classifier auto-learning
    $bayes_auto_learn = true,

    # Under Debian, start the spamd service
    $service = true,

    # Template fragments containing shortcircuit rules
    $templates_shortcircuit = [ 'master/etc/spamassassin/local.cf-shortcircuit' ],

    # Template fragments to transclude into the end of local.cf
    $templates_final = [ ]
) {
    # Installation of spamassassin can break if PAM is partially or
    # mis-configured.
    include master::common::pam
    Class['master::common::pam'] -> Class[$name]

    package { 'spamassassin': }

    templatelayer { '/etc/spamassassin/local.cf':
        require => Package['spamassassin'],
    }

    case $::osfamily {
        'Debian': {
            templatelayer { '/etc/default/spamassassin': }

            if $service {
                service { 'spamassassin':
                    ensure    => running,
                    enable    => true,
                    require   => Package['spamassassin'],
                    subscribe => Templatelayer['/etc/spamassassin/local.cf'],
                }
            }
            else {
                service { 'spamd':
                    ensure  => stopped,
                    enable  => false,
                    require => Package['spamassassin'],
                }
            }
        }
        default: { }
    }
}
