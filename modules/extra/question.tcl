# bMotion module to hold functions for handling questions, to keep them out of scripts/complex_questions.tcl


###############################################################################
# This is a bMotion 
# Copyright (C) James Michael Seward 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

proc bMotion_question_wellbeing { nick channel host } {
    ##boring code, replaced
    bMotion_putloglev 2 * "$nick wellbeing question"
    #bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerWellbeing}"
    #return 1

    global mood
    driftFriendship $nick 2

    #if {![bMotionTalkingToMe $text]} { return 0 }

    set moodString "I'm feeling "
    set moodIndex 0
    if {$mood(lonely) > 5} {
	append moodString "a bit lonely"
	incr moodIndex -2
    }
    
    if {$mood(horny) > 2} {
	if {[string length $moodString] > 13} {
	    append moodString ", "
	}
	append moodString "a little horny"
	incr moodIndex 2
    }
    
    if {$mood(happy) > 3} {
	if {[string length $moodString] > 13} {
	    append moodString ", "
	}
	append moodString "happy"
	incr moodIndex 1
    }
    
    if {$mood(happy) < 0} {
	if {[string length $moodString] > 13} {
	    append moodString ", "
	}
	append moodString "sad"
	incr moodIndex -3
    }
    
    if {$mood(stoned) > 5} {
	if {[string length $moodString] > 13} {
	    append moodString ", "
	}
	append moodString "stoned off my tits"
	incr moodIndex 2
    }
    
    if {$moodIndex >= 0} {
	append moodString " :)"
    } else {
	append moodString " :("
    }

    if {[string length $moodString] == [string length "I'm feeling  :)"]} {
	global feelings
	set moodString [pickRandom $feelings]
    }
    
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%%: $moodString"
    return 1
}
