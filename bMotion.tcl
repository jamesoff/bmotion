#bMotion core
#
# $Id$
#

#
# #5270 +(28)- [X]
#
# <Procyan> is there like 1 person on earth that knows tcl/tk and is writing all of the apps?
# <unSlider> procyan: no, there are a bunch of people who dont know tcl/tk but are writing apps for it anyway
#						(www.bash.org)

set bMotionRoot "scripts/bmotion"
set bMotionModules "$bMotionRoot/modules"
set bMotionPlugins "$bMotionRoot/plugins"


if {![info exists bMotion_testing]} {
  putloglev d * "bMotion: bMotion_testing is not defined, setting to 0."
  set bMotion_testing 0
}

if {$bMotion_testing == 1} {
  putlog "bMotion: INFO: Code loading in testing mode"
} else {
  putloglev 1 * "bMotion: INFO: Code loading in running mode"
}

proc bMotion_putloglev { level star text } {
  global bMotion_testing
  if {$bMotion_testing == 0} {
    putloglev $level $star $text
  }
}

# init default variables
if {$bMotion_testing == 1} {
  putlog "... loading variables"
}
source "$bMotionModules/variables.tcl"

# load abstracts file (formerly randoms)
if {$bMotion_testing == 1} {
  putlog "... loading abstracts"
}
source "$bMotionModules/abstracts.tcl"

# load settings
if {$bMotion_testing == 1} {
  putlog "... loading settings"
}
source "$bMotionModules/settings.tcl"

#load system functions
if {$bMotion_testing == 1} {
  putlog "... loading system"
}
source "$bMotionModules/system.tcl"

# load output functions
if {$bMotion_testing == 1} {
  putlog "... loading output"
}
source "$bMotionModules/output.tcl"

# load mood functions
if {$bMotion_testing == 1} {
  putlog "... loading mood"
}
source "$bMotionModules/mood.tcl"

# load event functions
if {$bMotion_testing == 1} {
  putlog "... loading events"
}
source "$bMotionModules/events.tcl"

if {$bMotion_testing == 1} {
  putlog "... loading events support"
}
source "$bMotionModules/events_support.tcl"

# load interbot bits
if {$bMotion_testing == 1} {
  putlog "... loading interbot"
}
source "$bMotionModules/interbot.tcl"

# load friendship code
if {$bMotion_testing == 1} {
  putlog "... loading friendship"
}
source "$bMotionModules/friendship.tcl"

# load plugins
if {$bMotion_testing == 1} {
  putlog "... loading plugins"
}
source "$bMotionModules/plugins.tcl"

if {$bMotion_testing == 1} {
  putlog "... loading plugin settings"
}
source "$bMotionModules/plugins_settings.tcl"

# load anti-flood code
if {$bMotion_testing == 1} {
  putlog "... loading flood"
}
source "$bMotionModules/flood.tcl"

# load other bits
if {$bMotion_testing == 1} {
  putlog "... loading leet"
}
source "$bMotionModules/leet.tcl"

# Ignition!
bMotion_startTimers
if {$bMotion_testing == 0} {
  set bMotionCache(rehash) ""
  putlog "\002bMotion $cvsinfo AI online\002 (randoms file: $randomsVersion)"
}

# set this to 0 to stop showing the copyright
# DO NOT DISTRIBUTE THIS FILE IF THE VARIABLE IS SET TO 0
set bMotion_show_copyright 1

if {$bMotion_show_copyright == 1} {
  putlog "bMotion is Copyright (C) 2002 James Seward. bMotion comes with ABSOLUTELY NO WARRANTY; 
  putlog "This is free software, and you are welcome to redistribute it under certain conditions. 
  putlog "See the COPYRIGHT file for details. You can edit bMotion.tcl to hide this message once you have read it."
}
