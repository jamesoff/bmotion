## bMotion plugin: away handler
#
# $Id$
#
# vim: fdm=indent fdn=1


###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_plugin_add_action_complex "zzz-failsafe" {^(.+?)s?( at|with)? %botnicks} 100 bMotion_plugin_complex_action_failsafe "en"

proc bMotion_plugin_complex_action_failsafe { nick host handle channel text } {
  regexp {^([^ ]+) ((across|near|at|with|to|against|from|over|under|in|on|next to) )?} $text matches verb dir
  if {$verb == ""} {
    return 2
  }

  bMotion_plugins_settings_set "complex:failsafe" "last" "nick" "moo" [bMotionGetRealName $nick]

	#try to figure out something geneal about this action
	if [regexp -nocase {(hug(gle)?|p[ae]t|rub|like|<3|sniff|smell|nibble|tickle)s?} $verb] {
		bMotionDoAction $channel $nick "%VAR{failsafe_nice}"
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

	if [regexp -nocase "(eyes|looks|stares)" $verb] {
		bMotionDoAction $channel $nick "%VAR{whats}"
		return 1
	}

	set whee [rand 10]

	if {$whee > 5} {
  	bMotionDoAction $channel $nick "%VAR{failsafes_a}"
  } else {
  	bMotionDoAction $channel $verb "%VAR{failsafes_b}" $dir
  }
  return 1
}

bMotion_abstract_register "failsafe_nice"
bMotion_abstract_batchadd "failsafe_nice" [list "mmm" "%VAR{smiles}" "%VAR{smiles}%|/gives %% %VAR{sillyThings}"]


bMotion_abstract_register "failsafes_a"
bMotion_abstract_batchadd "failsafes_a" [list "%VAR{rarrs}" "%REPEAT{3:7:m}" "%VAR{thanks}" "what" "/loves it" "/passes it on to %ruser" "/. o O ( ? )"]

bMotion_abstract_register "failsafes_b"
bMotion_abstract_batchadd "failsafes_b" [list "/%% %2 %SETTING{complex:failsafe:last:nick:moo} back with %VAR{sillyThings}" "/%% %2 %SETTING{complex:failsafe:last:nick:moo}" "/%VERB{%VAR{sillyThings}{strip}} %2 %SETTING{complex:failsafe:last:nick:moo} in return"]

bMotion_abstract_register "squeezeds"
bMotion_abstract_batchadd "squeezeds" [list "/pops" "/bursts" "/is compressed to a singularity and sucks in all of spacetime%|whoops" "/deflates" "%VAR{smiles}"]

bMotion_abstract_register "whats"
bMotion_abstract_batchadd "whats" [list "what?" "hmm?" "hello? yes?" "er... they did it%|/points at %ruser" "/stares back"]
