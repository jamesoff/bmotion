#
# Jolly sneaky.. if someone wants something, we'll remember it for ourselves :)
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

bMotion_plugin_add_complex "want-catch" "i (want|need) (.+)" 100 bMotion_plugin_complex_want_catcher "en"
bMotion_plugin_add_complex "mmm-catch" {^mm+[,. ]*(.+)} 100 bMotion_plugin_complex_mmm_catcher "en"
bMotion_plugin_add_complex "plusplus-catch" {^(.+)\+{2}$} 100 bMotion_plugin_complex_plusplus_catcher "en"
bMotion_plugin_add_complex "minmin-catch" {^(.+)-{2}$} 100 bMotion_plugin_complex_minmin_catcher "en"
bMotion_plugin_add_complex "zzz-noun-catch" {\m(?:a|an|the) ([[:alpha:]]+)} 100 bMotion_plugin_complex_noun_catcher "en"
bMotion_plugin_add_complex "karma-query" {^(!getkarma (.+))|((.+)\?\?)} 100 bMotion_plugin_complex_karma_get "en"

proc bMotion_plugin_complex_want_catcher { nick host handle channel text } {
  if [regexp -nocase "i (want|need) (?!to)(.+? )" $text matches verb item] {
    #that's a negative lookahead ---^
		if {![bMotion_filter_sillyThings $item]} {
			return 0
		}

    bMotion_abstract_add "sillyThings" $item
    if {[rand 100] > 95} {
    	bMotionDoAction $channel "" "%VAR{gotone}"
			return 1
    }
	}
}

proc bMotion_plugin_complex_mmm_catcher { nick host handle channel text } {
	global botnicks
  if [regexp -nocase {^mm+[,.]* (.+)} $text matches item] {

		if {![bMotion_filter_sillyThings $item]} {
			return 0
		}

    if [regexp -nocase "\ybmotion|$botnicks\y" $item] {
    	bMotionDoAction $channel "" "%VAR{wins}"
    	return 1
    }

    bMotion_abstract_add "sillyThings" $item
	
		if {[rand 100] > 95} {
				bMotionDoAction $channel $item "%VAR{betters}"
				return 1
		}
	}
}


proc bMotion_plugin_complex_plusplus_catcher { nick host handle channel text } {
	global botnicks
  if [regexp -nocase {^(.+)\+{2}$} $text matches item] {

		set retval 0

		if {![bMotion_plugin_complex_karma $nick $channel $text]} {
			if {[rand 100] > 95} {
				bMotionDoAction $channel $item "%VAR{betters}"
				set retval 1
			}
		}

		if {![bMotion_filter_sillyThings $item]} {
			bMotion_abstract_add "sillyThings" $item
		}

    if [regexp -nocase "^(bmotion|$botnicks)$" $item] {
			driftFriendship $handle 2
    	bMotionDoAction $channel "" "%VAR{wins}"
    	return 1
    }

		return $retval
	}
}

proc bMotion_plugin_complex_minmin_catcher { nick host handle channel text } {
  global botnicks
  if [regexp -nocase {^(.+)-{2}$} $text matches item] {

		set retval 0

		if {![bMotion_plugin_complex_karma $nick $channel $text]} {
			if {[rand 100] > 95} {
				bMotionDoAction $channel $item "%% = %VAR{PROM}"
				set retval 1
			}
		}

		if {![bMotion_filter_sillyThings $item]} {
			bMotion_abstract_add "sillyThings" $item
		}

    if [regexp -nocase "^(bmotion|$botnicks)$" $item] {
			driftFriendship $handle -2
      bMotionDoAction $channel "" "%VAR{unsmiles}"
      return 1
    }

		return $retval
  }
}


proc bMotion_plugin_complex_noun_catcher { nick host handle channel text } {
  if [regexp -nocase {\m(a|an|the|some) ([[:alpha:]]+)( [[:alpha:]]+\M)?} $text matches prefix item second] {
    set item [string tolower $item]

		if {![bMotion_filter_sillyThings $item]} {
			return 0
		}

    if [regexp "(ing|ed)$" $item] {
      if {$second == ""} {
        return 0
      }
      append item $second
    }

    set prefix [string tolower $prefix]
    if {$prefix == "the"} {
      if {[string range $item end end] == "s"} {
        set prefix "some"
      } else {
        set prefix "a"
      }
    }

    bMotion_abstract_add "sillyThings" "$prefix $item"
		return 0
  }
}

proc bMotion_plugin_complex_karma { nick channel text } {
	# setting to only allow a certain number of words to be grabbed?
	# setting to limit line length when triggering?

	if {![bMotion_setting_get "karma_enable"]} {
		return 0
	}
  
	global bMotion_karma
	
	if [regexp -nocase {\m([\w_\|\{\}\[\]^-]+)(\+\+|--)} $text matches word mode] {
		set word [string tolower $word]
		bMotion_putloglev d * "found karma mode $mode for word $word"
		set karma 0
		catch {
			set karma $bMotion_karma($word)
		}
		bMotion_putloglev d * "karma for $word is currently $karma"
		if {$mode == "++"} {
			incr karma
		} else {
			incr karma -1
		}
		bMotion_putloglev d * "karma for $word is now $karma"
		set bMotion_karma($word) $karma

		if {[bMotion_setting_get "karma_impatient"] == "1"} {
			putchan $channel "karma for $word is now $karma"
		} else {
			bMotionDoAction $channel "" "karma for $word is now $karma"
		}

		bMotion_plugin_complex_karma_save

		return 1
	} 
	return 0
}

proc bMotion_plugin_complex_karma_get { nick host handle channel text } {
	global bMotion_karma

	if {![bMotion_setting_get "karma_enable"]} {
		return 0
	}
  
	if [regexp -nocase {^(!getkarma ([\w_\|\{\}\[\]^-]+))|(([\w_\|\{\}\[\]^-]+)\?\?)} $text matches a word1 b word2] {
		if {$a != ""} {
			set word [string tolower $word1]
		} else {
			set word [string tolower $word2]
		}

		set karma "unknown"
		catch {
			set karma $bMotion_karma($word)
		}
		if {[bMotion_setting_get "karma_impatient"] == "1"} {
			putchan $channel "$nick: karma for '$word' is $karma"
		} else {
			bMotionDoAction $channel "" "$nick: karma for '$word' is $karma"
		}
		return 1
	}
}

proc bMotion_plugin_complex_karma_save { } {
	global bMotion_karma bMotionLocal

	set saved 0
	catch {
		set fh [open "$bMotionLocal/karma.txt" "w"]
		set names [array names bMotion_karma]
		foreach name $names {
			set karma $bMotion_karma($name)
			puts $fh "$name:$karma"
		}
		close $fh
		set saved 1
	}
	if {!$saved} {
		putlog "bMotion: unable to save karma database."
	}
}


proc bMotion_plugin_complex_karma_load { } {
	global bMotion_karma bMotionLocal
	bMotion_putloglev d * "Attempting to load karma database"
	catch {
		set fh [open "$bMotionLocal/karma.txt" "r"]
		set line [gets $fh]
		while {![eof $fh]} {
			set line [string trim $line]
			if {$line != ""} {
				set bits [split $line ":"]
				if {[llength $bits] == 2} {
					set bMotion_karma([lindex $bits 0]) [lindex $bits 1]
				} else {
					bMotion_putloglev d * "couldn't parse karma line $line"
				}
			}
			set line [gets $fh]
		}
		close $fh
	}
	set count [llength [array names bMotion_karma]]
	bMotion_putloglev d * "karma database holds $count items"
}


bMotion_abstract_register "gotone" [list "I've already got one%|%BOT\[are you sure?\]%|yes yes, it's very nice" "I already have one of those." "I had one of them the other week. They're very nice, aren't they?" "r"]

bMotion_abstract_register "betters" [list "mm%REPEAT{1:5:m}, %VAR{sillyThings:strip}" "%VAR{sillyThings:strip} > %%" "%% < %VAR{sillyThings:strip}" "%%++"]

bMotion_abstract_register "karma_update" [list "karma for %% is now %2"]

# initalise the storage for karma
# this command leaves existing arrays untouched
array set bMotion_karma [list]
if {[bMotion_setting_get "karma_enable"]} {
	bMotion_plugin_complex_karma_load
}

