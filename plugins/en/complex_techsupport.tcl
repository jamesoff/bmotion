## bMotion complex plugin: techsupport
#
# $Id$
#

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

proc bMotion_plugin_complex_techs { nick host handle channel text } {
  bMotion_flood_undo $nick
  bMotionDoAction $channel $nick "%%: %VAR{tech_answer}"
  return 1
}

bMotion_plugin_add_complex "techsup" "^!techsupport$" 100 bMotion_plugin_complex_techs "en"

# abstracts

set tech_software {
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

set tech_answer {
  "I just bought %VAR{tech_software} and I can't get it to %VAR{tech_problem}, I've tried %VAR{tech_tries} and it still won't work"
  "I've just got %VAR{tech_software}, and it won't %VAR{tech_problem}. I've tried everything including %VAR{tech_tries} but nothing helps"
  "I hear you do books by %VAR{answerWhos}, can you sell me one?"
  "I need a bit of software to %VAR{tech_functions} %VAR{sillyThings}"
}

set tech_problem {
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

set tech_tries {
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

set tech_functions {
  "virus-scan"
  "validate"
  "manage"
  "install"
  "clean"
  "update"
  "audit"
}