# bMotion: admin plugin file for language mangement
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

proc bMotion_plugin_management_language { handle { arg "" }} {
  global bMotionSettings
  global bMotionInfo

  if [regexp -nocase {remove (.+)} $arg matches lang] {
    if { $lang == $bMotionInfo(language) } {
      bMotion_putadmin "Cannot remove current language"
      return 0
    }
    bMotion_putadmin "Removing language $lang..."
    set langs [split $bMotionSettings(languages) ","]
    set newlangs [list]
    foreach language $langs {
      if {$lang != $language} {
        lappend newlangs $language
      }
    }
    if {[llength $newlangs] == 0} {
      set newlangs [list "en"]
    }

    set newlangstring [join $newlangs ","]

    set bMotionSettings(languages) $newlangstring

    bMotion_putadmin "bMotion: new languages are $newlangstring ... rehash to load"

    return 0
  }

  if [regexp -nocase {add (.+)} $arg matches lang] {
    set langs [split $bMotionSettings(languages) ","]
    foreach language $langs {
      if {$lang == $language} {
        bMotion_putadmin "Cannot add language already in list"
	return 0
      }
    }
    bMotion_putadmin "Adding language $lang..."
    append bMotionSettings(languages) ",$lang"
    bMotion_putadmin "bMotion: new languages are $bMotionSettings(languages) ... rehash to load"
    return 0
  }

  if [regexp -nocase {use (.+)} $arg matches lang] {
    bMotion_putadmin "Switching languages to $lang..."
    if [regexp $lang $bMotionSettings(languages)] {
      # step 1: flush the abstracts
      bMotion_abstract_flush
      # step 2: change the language in info
      set bMotionInfo(language) $lang
      # step 3: load the new abstracts
      bMotion_abstract_revive_language
    } else {
      bMotion_putadmin "Error! Language $lang not loaded"
    }
    return 0
  }

  #else list langs
  set langs "bMotion loaded languages: "
  foreach lang $bMotionSettings(languages) {
    append langs "$lang  "
  }
  global bMotionInfo
  bMotion_putadmin "$langs"
  bMotion_putadmin "Current language is $bMotionInfo(language)"
}

# register the plugin
bMotion_plugin_add_management "lang" "^lang(uage)?" n "bMotion_plugin_management_language" "any"
