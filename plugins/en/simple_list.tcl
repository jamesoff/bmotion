#
#

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2008
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################


bMotion_plugin_add_simple "list-1" {^ftp\?\? } 100 "%VAR{list1}" "en"
bMotion_plugin_add_simple "list-2" {^\?msg %botnicks ftp} 100 "%VAR{list2}" "en"


# abstracts
bMotion_abstract_register "list1"
bMotion_abstract_batchadd "list1" {
  "No. Try \002/msg NoTopic ftp?? ...\002 instead of saying it in the channel. Sheesh."
}

bMotion_abstract_register "list2"
bMotion_abstract_batchadd "list2" {
  "Heh, idiot."
  "Fool."
}
