## plugins engine for bMotion
#
# $Id$
#

###############################################################################
# bMotion - an 'AI' TCL script for eggdrops
# Copyright (C) James Michael Seward 2000-2002
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or 
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but 
# WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU 
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License 
# along with this program; if not, write to the Free Software 
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
###############################################################################

## Simple plugins
if [info exists bMotion_plugins_simple] { unset bMotion_plugins_simple }
set bMotion_plugins_simple(dummy) "_{100,100}¦0¦/has a tremendous plugin-related error (wahey)$"

## Admin plugins (.bmotion)
if [info exists bMotion_plugins_admin] { unset bMotion_plugins_admin }
set bMotion_plugins_admin(dummy) "none"

## complex plugins 
if [info exists bMotion_plugins_complex] { unset bMotion_plugins_complex }
set bMotion_plugins_complex(dummy) "none"

## output plugins 
if [info exists bMotion_plugins_output] { unset bMotion_plugins_output }
set bMotion_plugins_output(dummy) "none"

## action simple plugins
if [info exists bMotion_plugins_action_simple] { unset bMotion_plugins_action_simple }
set bMotion_plugins_action_simple(dummy) "none"

## action complex plugins
if [info exists bMotion_plugins_action_complex] { unset bMotion_plugins_action_complex }
set bMotion_plugins_action_complex(dummy) "none"

## irc_event plugins
if [info exists bMotion_plugins_irc_event] { unset bMotion_plugins_irc_event }
set bMotion_plugins_irc_event(dummy) "none"

## management plugins
if [info exists bMotion_plugins_management] { unset bMotion_plugins_management }
set bMotion_plugins_management(dummy) "none"

##############################################################################################################################
## Load a simple plugin
proc bMotion_plugin_add_simple { id match chance response language} {
  global bMotion_plugins_simple plugins bMotion_testing

  if {$bMotion_testing == 0} {
    catch {
      set test $bMotion_plugins_simple($id)
      putlog "bMotion: ALERT! Simple plugin $id is defined more than once"
      return 0
    }
  }
  if [bMotion_plugin_check_allowed "simple:$id"] {
    set bMotion_plugins_simple($id) "${match}¦${chance}¦${response}¦${language}"
    bMotion_putloglev 2 * "bMotion: added simple plugin: $id"
    append plugins "$id,"
    return 1
  }
  bMotion_putloglev d * "bMotion: ignoring disallowed plugin simple:$id"
}


## Find a simple plugin
proc bMotion_plugin_find_simple { text lang } {
  bMotion_putloglev 3 * "bMotion_plugin_find_simple: text = $text, lang = $lang"
  global bMotion_plugins_simple botnicks
  set s [lsort [array names bMotion_plugins_simple]]

  foreach key $s {
    if {$key == "dummy"} { continue }
    set val $bMotion_plugins_simple($key)
    set blah [split $val "¦"]
    set rexp [lindex $blah 0]
    set chance [lindex $blah 1]
    set response [lindex $blah 2]
    set language [lindex $blah 3]
    if {[string match $lang $language] || ($language == "any")} {
      set rexp [bMotionInsertString $rexp "%botnicks" "${botnicks}"]
      if [regexp -nocase $rexp $text] {
        set c [rand 100]
        bMotion_putloglev 4 * "simple plugin $key matches"
        if {$chance > $c} {
          bMotion_putloglev 4 * "  `- firing"
          return $response
        }
      }
    }
  }
  return ""
}



## Load an admin plugin
proc bMotion_plugin_add_admin { id match flags callback language } {
  global bMotion_plugins_admin plugins bMotion_testing

  if {$bMotion_testing == 0} {
    catch {
      set test $bMotion_plugins_admin($id)
      putlog "bMotion: ALERT! admin plugin $id is defined more than once"
      return 0
    }
  }

  if [bMotion_plugin_check_allowed "admin:$id"] {
    set bMotion_plugins_admin($id) "${match}¦${flags}¦${callback}¦${language}"
    bMotion_putloglev 2 * "bMotion: added admin plugin: $id"
    append plugins "$id,"
    return 1
  }
  bMotion_putloglev d * "bMotion: ignoring disallowed plugin admin:$id"
}


## Find an admin plugin
proc bMotion_plugin_find_admin { text lang } {
  global bMotion_plugins_admin
  set s [array startsearch bMotion_plugins_admin]

  while {[set key [array nextelement bMotion_plugins_admin $s]] != ""} {
    if {$key == "dummy"} { continue }
    set val $bMotion_plugins_admin($key)
    set blah [split $val "¦"]
    set rexp [lindex $blah 0]
    set flags [lindex $blah 1]
    set callback [lindex $blah 2]
    set language [lindex $blah 3]
    if {[string match $lang $language] || ($language == "any")|| ($language == "all")} {
      if [regexp -nocase $rexp $text] {
        array donesearch bMotion_plugins_admin $s
        return "${flags}¦$callback"
      }
    }
  }
  array donesearch bMotion_plugins_admin $s
  return ""
}

## Load management plugin
proc bMotion_plugin_add_management { id match flags callback { language "" } } {
  global bMotion_plugins_management plugins bMotion_testing

  if {$bMotion_testing == 0} {
    catch {
      set test $bMotion_plugins_management($id)
      putlog "bMotion: ALERT! management plugin $id is defined more than once"
      return 0
    }
  }

  if [bMotion_plugin_check_allowed "management:$id"] {
    set bMotion_plugins_management($id) "${match}¦${flags}¦${callback}"
    bMotion_putloglev 2 * "bMotion: added management plugin: $id"
    append plugins "$id,"
    return 1
  }
  bMotion_putloglev d * "bMotion: ignoring disallowed plugin management:$id"
}

## Find management plugin
proc bMotion_plugin_find_management { text } {
  global bMotion_plugins_management
  set s [array startsearch bMotion_plugins_management]

  while {[set key [array nextelement bMotion_plugins_management $s]] != ""} {
    if {$key == "dummy"} { continue }
    set val $bMotion_plugins_management($key)
    set blah [split $val "¦"]
    set rexp [lindex $blah 0]
    set flags [lindex $blah 1]
    set callback [lindex $blah 2]
    if [regexp -nocase $rexp $text] {
      array donesearch bMotion_plugins_management $s
      return "${flags}¦$callback"
    }
  }
  array donesearch bMotion_plugins_management $s
  return ""
}


## Load a complex plugin
proc bMotion_plugin_add_complex { id match chance callback language } {
  global bMotion_plugins_complex plugins bMotion_testing
  if {$bMotion_testing == 0} {
    catch {
      set test $bMotion_plugins_complex($id)
      putlog "bMotion: ALERT! Complex plugin $id is defined more than once"
      return 0
    }
  }
  if [bMotion_plugin_check_allowed "complex:$id"] {
    set bMotion_plugins_complex($id) "${match}¦${chance}¦${callback}¦${language}"
    bMotion_putloglev 2 * "bMotion: added complex plugin: $id"
    append plugins "$id,"
    return 1
  }
  bMotion_putloglev d * "bMotion: ignoring disallowed plugin complex:$id"

}

## Find a complex plugin plugin
proc bMotion_plugin_find_complex { text lang } {
  global bMotion_plugins_complex botnicks
  set s [lsort [array names bMotion_plugins_complex]]
  set result [list]

  foreach key $s {
    if {$key == "dummy"} { continue }
    set val $bMotion_plugins_complex($key)
    set blah [split $val "¦"]
    set rexp [lindex $blah 0]
    set chance [lindex $blah 1]
    set callback [lindex $blah 2]
    set language [lindex $blah 3]
    if {[string match $lang $language] || ($language == "any") || ($language == "all")} {
    set rexp [bMotionInsertString $rexp "%botnicks" "${botnicks}"]
      if [regexp -nocase $rexp $text] {
        set c [rand 100]
        bMotion_putloglev 4 * "matched complex:$key"
        if {$chance > $c} {
          lappend result $callback
        }
      }
    }
  }
  return $result
}


## Load an output plugin
proc bMotion_plugin_add_output { id callback enabled language } {
  global bMotion_plugins_output plugins bMotion_testing

  if {$bMotion_testing == 0} {
    catch {
      set test $bMotion_plugins_output($id)
      putlog "bMotion: ALERT! Output plugin $id is defined more than once"
      return 0
    }
  }
  if [bMotion_plugin_check_allowed "output:$id"] {
    set bMotion_plugins_output($id) "${callback}¦${enabled}¦$language"
    bMotion_putloglev 2 * "bMotion: added output plugin: $id"
    append plugins "$id,"
    return 1
  }
  bMotion_putloglev d * "bMotion: ignoring disallowed plugin output:$id"
}

proc bMotion_plugin_find_output { lang } {
  global bMotion_plugins_output botnicks
  set s [array startsearch bMotion_plugins_output]
  set result [list]

  while {[set key [array nextelement bMotion_plugins_output $s]] != ""} {
    if {$key == "dummy"} { continue }
    set val $bMotion_plugins_output($key)
    set blah [split $val "¦"]
    set callback [lindex $blah 0]
    set enabled [lindex $blah 1]
    set language [lindex $blah 2]
    if {[string match $lang $language] || ($language == "any")|| ($language == "all")} {
      if {$enabled == 1} {
        lappend result $callback
      }
    }
  }
  array donesearch bMotion_plugins_output $s
  return $result
}


## Load a simple action plugin
proc bMotion_plugin_add_action_simple { id match chance response language } {
  global bMotion_plugins_action_simple plugins bMotion_testing

  if {$bMotion_testing == 0} {
    catch {
      set test $bMotion_plugins_action_simple($id)
      putlog "bMotion: ALERT! Simple plugin $id is defined more than once"
      return 0
    }
  }
  if [bMotion_plugin_check_allowed "action_simple:$id"] {
    set bMotion_plugins_action_simple($id) "${match}¦${chance}¦${response}¦$language"
    bMotion_putloglev 2 * "bMotion: added simple action plugin: $id"
    append plugins "$id,"
    return 1
  }
  bMotion_putloglev d * "bMotion: ignoring disallowed plugin action_simple:$id"

}


## Find a simple action plugin
proc bMotion_plugin_find_action_simple { text lang } {
  global bMotion_plugins_action_simple botnicks
  set s [lsort [array names bMotion_plugins_action_simple]]

  foreach key $s {
    if {$key == "dummy"} { continue }
    set val $bMotion_plugins_action_simple($key)
    set blah [split $val "¦"]
    set rexp [lindex $blah 0]
    set chance [lindex $blah 1]
    set response [lindex $blah 2]
    set language [lindex $blah 3]
    if {[string match $lang $language] || ($language == "any")|| ($language == "all")} {
      set rexp [bMotionInsertString $rexp "%botnicks" "${botnicks}"]
      if [regexp -nocase $rexp $text] {
        set c [rand 100]
        if {$chance > $c} {
          return $response
        }
      }
    }
  }
  return ""
}


## Load a complex action plugin
proc bMotion_plugin_add_action_complex { id match chance callback language } {
  global bMotion_plugins_action_complex plugins bMotion_testing
  if {$bMotion_testing == 0} {
    catch {
      set test $bMotion_plugins_action_complex($id)
      putlog "bMotion: ALERT! Complex action plugin $id is defined more than once"
      return 0
    }
  }
  if [bMotion_plugin_check_allowed "action_complex:$id"] {
    set bMotion_plugins_action_complex($id) "${match}¦${chance}¦${callback}¦${language}"
    bMotion_putloglev 2 * "bMotion: added complex action plugin: $id"
    append plugins "$id,"
    return 1
  }
  bMotion_putloglev d * "bMotion: ignoring disallowed plugin action_complex:$id"

}

## Find a complex action plugin plugin
proc bMotion_plugin_find_action_complex { text lang } {
  global bMotion_plugins_action_complex botnicks
  set s [lsort [array names bMotion_plugins_action_complex]]
  set result [list]

  foreach key $s {
    if {$key == "dummy"} { continue }
    set val $bMotion_plugins_action_complex($key)
    set blah [split $val "¦"]
    set rexp [lindex $blah 0]
    set chance [lindex $blah 1]
    set callback [lindex $blah 2]
    set language [lindex $blah 3]
    if {[string match $language $lang] || ($language == "any")|| ($language == "all")} {
      set rexp [bMotionInsertString $rexp "%botnicks" "${botnicks}"]
      if [regexp -nocase $rexp $text] {
        bMotion_putloglev 4 * "matched: $key"
        set c [rand 100]
        if {$chance > $c} {
          lappend result $callback
        }
      }
    }
  }
  return $result
}


###############################################################################

proc bMotion_plugin_check_depend { depends } {

  #pass a string in the format "type:plugin,type:plugin,..."

  if {$depends == ""} {
    return 1
  }

  set result 1

  set blah [split $depends ","]
  foreach depend $blah {
    set blah2 [split $depend ":"]
    set t [lindex $blah2 0]
    set id [lindex $blah2 1]
    set a "bMotion_plugins_$t"
    upvar #0 $a ar
    bMotion_putloglev 1 * "bMotion: checking $a for $id ..."
    set temp [array names ar $id]
    if {[llength $temp] == 0} {
      set result 0
      bMotion_putloglev d * "bMotion: Missing dependency $t:$id"
    }
  }
  return $result
}



###############################################################################

proc bMotion_plugin_check_allowed { name } {

  #pass a string in the format "type:plugin"
  #setting in config should be "type:plugin,type:plugin,..."

  global bMotionSettings

  set disallowed ""

  catch {
    set disallowed $bMotionSettings(noPlugin)
  }

  if {$disallowed == ""} {
    return 1
  }

  bMotion_putloglev 4 * "bMotion: checking $name against $disallowed"

  set blah [split $disallowed ","]
  foreach plugin $blah {
    if {$plugin == $name} {
      return 0
    }
  }
  return 1
}

################################################################################

## dev: simsea
## Load an irc event response plugin
proc bMotion_plugin_add_irc_event { id type match chance callback language } {
  if {![regexp -nocase "nick|join|quit|part|split" $type]} {
    putlog "bMotion: ALERT! IRC Event plugin $id has an invalid type $type"
    return 0
  }
  global bMotion_plugins_irc_event plugins bMotion_testing
  if {$bMotion_testing == 0} {
    catch {
      set test $bMotion_plugins_irc_event($id)
      putlog "bMotion: ALERT! IRC Event plugin $id is defined more than once"
      return 0
    }
  }
  if [bMotion_plugin_check_allowed "irc:$id"] {
    set bMotion_plugins_irc_event($id) "$type¦${match}¦$chance¦$callback¦$language"
    bMotion_putloglev 2 * "bMotion: added IRC event plugin: $id"
    append plugins "$id,"
    return 1
  }
  bMotion_putloglev d * "bMotion: ignoring disallowed plugin irc:$id"

}

## Find an IRC Event response plugin plugin
proc bMotion_plugin_find_irc_event { text type lang } {
  if {![regexp -nocase "nick|join|quit|part|split" $type]} {
    putlog "bMotion: IRC Event search type $type is invalid"
    return 0
  }
  global bMotion_plugins_irc_event botnicks
  set s [lsort [array names bMotion_plugins_irc_event]]
  set result [list]

  foreach key $s {
    if {$key == "dummy"} { continue }
    set val $bMotion_plugins_irc_event($key)
    set blah [split $val "¦"]
    set etype [lindex $blah 0]
    set rexp [lindex $blah 1]
    set chance [lindex $blah 2]
    set callback [lindex $blah 3]
    set language [lindex $blah 4]
    if {[string match $type $etype]} {
      if {[string match $language $lang] || ($language == "any") || ($language == "all")} {
        if [regexp -nocase $rexp $text] {
          set c [rand 100]
          if {$chance > $c} {
            lappend result $callback
          }
        }
      }
    }
  }
  return $result
}


################################################################################

## Load the simple plugins
set plugins ""
catch { source "$bMotionPlugins/simple.tcl" }
#set plugins [string range $plugins 0 [expr [string length $plugins] - 2]]
#bMotion_putloglev d * "bMotion: simple plugins loaded: $plugins"

## Load the admin plugins
set plugins ""
catch { source "$bMotionPlugins/admin.tcl" }
#set plugins [string range $plugins 0 [expr [string length $plugins] - 2]]
#bMotion_putloglev d * "bMotion: admin plugins loaded: $plugins"

## Load the complex plugins
set plugins ""
catch { source "$bMotionPlugins/complex.tcl" }
#set plugins [string range $plugins 0 [expr [string length $plugins] - 2]]
#bMotion_putloglev d * "bMotion: complex plugins loaded: $plugins"

## Load the output plugins
set plugins ""
catch { source "$bMotionPlugins/output.tcl" }
#set plugins [string range $plugins 0 [expr [string length $plugins] - 2]]
#bMotion_putloglev d * "bMotion: output plugins loaded: $plugins"

## Load the simple action plugins
catch { source "$bMotionPlugins/action_simple.tcl" }

## Load the complex action plugins
catch { source "$bMotionPlugins/action_complex.tcl" }

## Load the irc event plugins
catch { source "$bMotionPlugins/irc_event.tcl" }

bMotion_putloglev d * "Installed bMotion plugins: (some may be inactive)\r"
bMotion_putloglev d * "(one moment...)\r"
foreach t {simple complex admin output action_simple action_complex irc_event} {
  set arrayName "bMotion_plugins_$t"
  upvar #0 $arrayName cheese
  set plugins [lsort [array names cheese]]
  set output "$t: "
  foreach n $plugins {
    if {$n != "dummy"} {
      append output "$n, "
    }
  }
  set output [string range $output 0 [expr [string length $output] - 3]]
  bMotion_putloglev d * "$output\r"
}

### null plugin routine for faking plugins
proc bMotion_plugin_null { {a ""} {b ""} {c ""} {d ""} {e ""} } {
  return 0
}

bMotion_putloglev d * "bMotion: plugins module loaded"

