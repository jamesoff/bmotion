#
#
# vim: fdm=indent fdn=1

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2008
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

proc bMotion_plugin_complex_techs { nick host handle channel text } {
  if [bMotion_interbot_me_next $channel] {
    bMotionDoAction $channel $nick "%%: %VAR{tech_answer}"
		return 1
  }
  return 2
}

bMotion_plugin_add_complex "techsup" "^!techsupport$" 100 bMotion_plugin_complex_techs "en"

# abstracts

bMotion_abstract_register "tech_software"
bMotion_abstract_batchadd "tech_software" {
  "windows"
  "xml spy"
  "installshield"
  "notepad"
  "media player"
  "wise for windows"
  "goldmine"
  "gmClass"
  "vmware"
  "the internet"
}

bMotion_abstract_register "tech_answer"
bMotion_abstract_batchadd "tech_answer" {
  "I just bought %VAR{tech_software} and I can't get it to %VAR{tech_problem}, I've tried %VAR{tech_tries} and it still won't work"
  "I've just got %VAR{tech_software}, and it won't %VAR{tech_problem}. I've tried everything including %VAR{tech_tries} but nothing helps"
  "I hear you do books by %VAR{answerWhos}, can you sell me one?"
  "I need a bit of software to %VAR{tech_functions} %VAR{sillyThings}"
}

bMotion_abstract_register "tech_problem"
bMotion_abstract_batchadd "tech_problem" {
  "install"
  "work"
  "stop being purple"
  "stop rendering pictures of %VAR{sillyThings}"
  "connect to the network"
  "stop telling me 'you are too stupid to use this software'"
  "make the tea"
  "download pornography"
  "connect"
}

bMotion_abstract_register "tech_tries"
bMotion_abstract_batchadd "tech_tries" {
  "sacrificing my boss"
  "reinstalling it"
  "going to a voodoo witch doctor"
  "covering it in honey"
  "putting the CD in the other way up"
  "putting the CD in the floppy drive"
  "smearing it with mud"
  "running it on my Mac"
  "rebooting"
}

bMotion_abstract_register "tech_functions"
bMotion_abstract_batchadd "tech_functions" {
  "virus-scan"
  "validate"
  "manage"
  "install"
  "clean"
  "update"
  "audit"
}
