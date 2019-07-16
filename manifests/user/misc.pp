#
# class master::user::misc
# ========================
#
# Miscellaneous end-user packages expected on most user-accessed
# systems but not fitting into any specific category.
#

class master::user::misc {
    package { 'finger': }
}
