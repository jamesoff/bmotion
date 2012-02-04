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

bMotion_plugin_add_action_complex "zzz-failsafe" {^(.+?)s?( at|with)? %botnicks} 100 bMotion_plugin_complex_action_failsafe "en"
bMotion_plugin_add_action_complex "aaa-autogender" {[a-z]+s (his|her) } 100 bMotion_plugin_complex_action_autolearn_gender "en"
bMotion_plugin_add_action_complex "aaa-verbcatch" {(\w+s)\M} 100 bMotion_plugin_complex_action_verb_catch "en"

proc bMotion_plugin_complex_action_failsafe { nick host handle channel text } {
  regexp {^([^ ]+) ((across|near|at|with|to|against|from|over|under|in|on|next to) )?} $text matches verb dir
  if {$verb == ""} {
    return 2
  }

  bMotion_plugins_settings_set "complex:failsafe" "last" "nick" "moo" [bMotionGetRealName $nick]

	#try to figure out something geneal about this action
	if [regexp -nocase {(giggle|hug(gle)?|p[ae]t|rub|like|<3|sniff|smell|nibble|tickle)s?} $verb] {
		bMotionDoAction $channel $nick "%VAR{failsafe_nice}" $verb
		bMotionGetHappy
		driftFriendship $nick 1
		return 1
	}

	if [regexp -nocase "(squashes|squishes|squee+zes)" $verb] {
		bMotionDoAction $channel $nick "%VAR{squeezeds}"
		bMotionGetHappy
		driftFriendship $nick 1
		return 1
	}

	if [regexp "(dance|sing|play|bop|doof)s?" $verb] {
		bMotionDoAction $channel $nick "%VAR{failsafe_niceactions}"
		bMotionGetHappy
		driftFriendship $nick 10
		return 1
	}

	if [regexp "(cum|come|jizze|spurt)s?" $verb] {
		bMotionDoAction $channel $nick "%VAR{failsafe_wtfs}"
		bMotionGetHappy
		bMotionGetHorny
		driftFriendship $nick 10
	}


	if [regexp "(look|stare|eye|frown)s?" $verb] {
		bMotionDoAction $channel $nick "%VAR{failsafe_lookback}"
		bMotionGetHappy
		driftFriendship $nick 10
		return 1
	}

	set whee [rand 10]

	if {$whee > 5} {
  	bMotionDoAction $channel $nick "%VAR{failsafes_a}" $verb
  } else {
  	bMotionDoAction $channel $verb "%VAR{failsafes_b}" $dir
  }
  return 1
}

proc bMotion_plugin_complex_action_autolearn_gender { nick host handle channel text } {
	if {$handle == "*"} {
		return 0
	}

	set gender [getuser $handle XTRA gender]
	if [regexp -nocase {[a-z]+s (his|her) } $text matches pronoun] {
		set pronoun [string tolower $pronoun]
		if {$pronoun == "his"} {
			if {$gender != ""} {
				if {$gender == "male"} {
					return 0
				} else {
					bMotion_putloglev 3 * "would learn gender for $nick as male, but they're already female!"
					return 0
				}
			}
			bMotion_putloglev d * "learning gender = male for $handle (via $nick)"
			setuser $handle XTRA gender male
			return 0
		} else {
			if {$gender != ""} {
				if {$gender == "female"} {
					return 0
				} else {
					bMotion_putloglev 3 * "would learn gender for $nick as female, but they're already male!"
					return 0
				}
			}
			bMotion_putloglev d * "learning gender = female for $handle (via $nick)"
			setuser $handle XTRA gender female
			return 0
		}
	}
	return 0
}

proc bMotion_plugin_complex_action_verb_catch { nick host handle channel text } {

	set stem ""
	if [regexp -nocase {^((\w+)s)\M} $text matches verb stem] {
	}

	if {$stem != ""} {
		if {[string length $stem] < 3} {
			return 0
		}

		if [string match -nocase "*e" $stem] {
			set stem [string range $stem 0 end-1]
		}
		# TODO: Handle any obvious cases where the stem isn't just lopping off the s!
		bMotion_putloglev 1 * "found verb $verb ($stem)"
		bMotion_abstract_add "sillyVerbs" $stem
	}

	return 0
}

bMotion_abstract_register "failsafe_nice" [list "mmm" "%VAR{smiles}" "%VAR{smiles}%|/gives %% %VAR{sillyThings}" "i do love a good %2ing"]


bMotion_abstract_register "failsafes_a" [list "%VAR{rarrs}" "%REPEAT{3:7:m}" "%VAR{thanks}" "what" "/loves it" "/passes it on to %ruser" "/. o O ( ? )" "i do love a good %%ing"]

bMotion_abstract_register "failsafes_b" [list "/%% %2 %SETTING{complex:failsafe:last:nick:moo} back with %VAR{sillyThings}" "/%% %2 %SETTING{complex:failsafe:last:nick:moo}" "/%VAR{sillyThings:verb,strip} %2 %SETTING{complex:failsafe:last:nick:moo} in the %VAR{bodypart:bothmixin}" "/%VAR{sillyThings:verb,strip} %2 %SETTING{complex:failsafe:last:nick:moo} in return" "i do love a good %%ing"]
bMotion_abstract_add_filter "failsafes_b" "%VERB"

bMotion_abstract_register "squeezeds" [list "/pops" "/bursts" "/is compressed to a singularity and sucks in all of spacetime%|whoops" "/deflates" "%VAR{smiles}"]

bMotion_abstract_register "whats" [list "what?" "hmm?" "hello? yes?" "er... they did it%|/points at %ruser" "/stares back"]

 bMotion_abstract_register "failsafe_lookback" [list "/stares at %%" "hello, yes?" "i can still see you..." "/poses" "/bounces away" "%VAR{smiles}" "/looks at %%" ]

bMotion_abstract_register "failsafe_wtfs" [list "%VAR{satOns}" "%VAR{shocked}" ]

bMotion_abstract_register "failsafe_niceactions" [list "wh%REPEAT{3:7:e} %VAR{smiles}" "%VAR{smiles}" "/bounces around" "*drool*" ]

bMotion_abstract_register "sillyVerbs"
