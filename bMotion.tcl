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


### Set some important variables
set bMotionRoot "scripts/bmotion"
set bMotionModules "$bMotionRoot/modules"
set bMotionPlugins "$bMotionRoot/plugins"
set bMotionLocal "$bMotionRoot/local"

### We need to do this early on in case something breaks
setudef flag bmotion

if {![info exists bMotion_log_regexp]} {
	set bMotion_log_regexp ""
}

if {![info exists bMotion_testing]} {
  putloglev d * "bMotion: bMotion_testing is not defined, setting to 0."
  set bMotion_testing 0
}


source "$bMotionRoot/VERSION"
if {$bMotion_testing == 0} {
  putlog "bMotion $bMotionVersion starting up..."
}


if {$bMotion_testing == 1} {
  putlog "bMotion: INFO: Code loading in testing mode"
  set bMotion_loading 0
} else {
  putloglev 1 * "bMotion: INFO: Code loading in running mode"
  set bMotion_loading 1
}

proc bMotion_putloglev { level star text } {
  global bMotion_testing bMotion_log_regexp
	
	if {$bMotion_log_regexp != ""} {
		if {![regexp -nocase $bMotion_log_regexp $text]} {
			return 0
		}
	}

  regsub "bMotion:" $text "" text
  set text2 ""
  if {$level != "d"} {
    set text2 [string repeat " " $level]
  }
  set text "bMotion:$text2 $text"

  if {$bMotion_testing == 0} {
    putloglev $level $star "($level)$text"
  }
}

# init default variables
if {$bMotion_testing == 1} {
  putlog "... loading variables"
}
source "$bMotionModules/variables.tcl"

# load counters
if {$bMotion_testing == 1} {
  putlog "... loading counters"
}
source "$bMotionModules/counters.tcl"

# load settings
if {$bMotion_testing == 1} {
  putlog "... loading settings"
}
# try the original location first
set bMotion_loaded_settings 0
if [file exists "$bMotionModules/settings.tcl"] {
	source "$bMotionModules/settings.tcl"
	set bMotion_loaded_settings 1
}

#try to load a file for this bot
catch {
  if {${botnet-nick} != ""} {
    source "$bMotionModules/settings_${botnet-nick}.tcl"
    bMotion_putloglev d * "loaded settings for this bot from settings_${botnet-nick}.tcl"
		set bMotion_loaded_settings 1
  }
}

#try to load from the local dir
if [file exists "$bMotionLocal/settings.tcl"] {
	source "$bMotionLocal/settings.tcl"
	bMotion_putloglev d * "loaded local settings from $bMotionLocal/settings.tcl"
	set bMotion_loaded_settings 1
}

if {$bMotion_loaded_settings == 0} {
	putlog "bMotion: FATAL! Could not load from any settings file! bMotion is not going to work! :("
}

#load system functions
if {$bMotion_testing == 1} {
  putlog "... loading system"
}
source "$bMotionModules/system.tcl"

#load new abstract system
if {$bMotion_testing == 1} {
  putlog "... loading abstract system"
}
source "$bMotionModules/abstract.tcl"

# load output functions
if {$bMotion_testing == 1} {
  putlog "... loading output"
}
source "$bMotionModules/output.tcl"

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

# load anti-flood code
if {$bMotion_testing == 1} {
  putlog "... loading flood"
}
source "$bMotionModules/flood.tcl"

# load queue code
if {$bMotion_testing == 1} {
  putlog "... loading queue"
}
source "$bMotionModules/queue.tcl"

# load plugins
if {$bMotion_testing == 1} {
  putlog "... loading plugins"
}
source "$bMotionModules/plugins.tcl"

# load mood functions
if {$bMotion_testing == 1} {
  putlog "... loading mood"
}
source "$bMotionModules/mood.tcl"

if {$bMotion_testing == 1} {
  putlog "... loading plugin settings"
}
source "$bMotionModules/plugins_settings.tcl"

### That's everything but the plugins stuff loaded. Now load extra modules
bMotion_putloglev d * "looking for 3rd party modules..."
set files [lsort [glob -nocomplain "$bMotionModules/extra/*.tcl"]]
foreach f $files {
  bMotion_putloglev 1 * "... loading extra module: $f"
  catch {
    source $f
  }
}

### Done, load the plugins:



#load local abstracts
catch {
	source "$bMotionLocal/abstracts.tcl"
	bMotion_putloglev d * "loaded abstracts for this bot from local abstracts.tcl"
}

# load other bits
if {$bMotion_testing == 1} {
  putlog "... loading leet"
}
source "$bMotionModules/leet.tcl"

# load diagnostics
catch {
  if {$bMotion_testing == 1} {
    putlog "... loading self-diagnostics"
  }
  source "$bMotionModules/diagnostics.tcl"
}

# Ignition!

bMotion_startTimers
if {$bMotion_testing == 0} {
	bMotion_diagnostic_utimers
	bMotion_diagnostic_timers

  putlog "\002bMotion $bMotionVersion AI online\002 :D"
}

set bMotion_loading 0
set bMotion_testing 0

# To hide this message from your bot's startup/rehash, edit your settings.tcl and change
# the bMotion_show_copyright value to 0
if {$bMotion_show_copyright == 1} {
	putlog "bMotion is Copyright (C) 2007 James Seward. bMotion comes with ABSOLUTELY NO WARRANTY;"
  putlog "This is free software, and you are welcome to redistribute it under certain conditions."
  putlog "See the COPYRIGHT file for details. See bMotion.tcl to hide this message once you have read it."
}
