# bMotion module to hold functions for handling questions, to keep them out of scripts/complex_questions.tcl


###############################################################################
# This is a bMotion module thing
# it provides the answers to questions

# Copyright (C) James Michael Seward 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

proc bMotion_question_where { nick channel host } {
	bMotion_log "plugin" "TRACE" "bMotion_question_where $nick $channel $host"
	if {[getFriendship $nick] < 40} {
		bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{upyourbums}"
	} else {
		bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerWheres}"
	}
}

proc bMotion_question_wellbeing { nick channel host } {
	##boring code, replaced
	bMotion_log "plugin" "TRACE" "bMotion_question_wellbeing $nick $channel $host"

	driftFriendship $nick 2

	set moodString ""
	if {[getFriendship $nick] > 75} {
		append moodString "Awww, thanks for asking "
		append moodString [bMotionGetRealName $nick]
		append moodString ", "
	} else {
		if {[getFriendship $nick] < 35} {
			append moodString "What do you care that "
		}
	}

	append moodString "I'm feeling "
	set moodIndex 0
	set done 0

	if {[bMotion_mood_get lonely] > 5} {
		append moodString "a bit lonely"
		incr moodIndex -2
		incr done 1
	}

	if {[bMotion_mood_get horny] > 2} {
		if {$done > 0} {
			append moodString ", "
		}
		append moodString "a little horny"
		incr moodIndex 2
		incr done 1
	}

	if {[bMotion_mood_get happy] > 3} {
		if {$done > 0} {
			append moodString ", "
		}
		append moodString "happy"
		incr moodIndex 1
		incr done 1
	}


	if {[bMotion_mood_get happy] < 0} {
		if {$done > 0} {
			append moodString ", "
		}
		append moodString "sad"
		incr moodIndex -3
		incr done 1
	}

	if {[bMotion_mood_get stoned] > 5} {
		if {$done > 0} {
			append moodString ", "
		}
		append moodString "stoned off my tits"
		incr moodIndex 2
		incr done 1
	}

	if {$done < 1} {
		append moodString "pretty average :/"
	} else {
		if {$moodIndex >= 0} {
			append moodString " %SMILEY{happy}"
		} else {
			append moodString " %SMILEY{sad}"
		}
	}

	bMotionDoAction $channel [bMotionGetRealName $nick $host] "%%: $moodString"
	return 1
}
