## bMotion plugin: question handlers
#
# $Id$
#

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2003
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################


bMotion_plugin_add_complex "question" {[?>/]$} 100 bMotion_plugin_complex_question "en"

proc bMotion_plugin_complex_question { nick host handle channel text } {

  global botnicks

  regsub {(.+)[>\/]$} $text {\1?} text

  ## What question targeted at me
  if { [regexp -nocase "^$botnicks,?:? what('?s)?(.+)" $text matches botn s question] ||
       [regexp -nocase "^what('?s)? (.*) $botnicks ?\\?" $text matches s question botn] } {
    bMotion_plugin_complex_question_what $nick $channel $host $question
    return 1
  }

  ## With/at/against who question targeted at me
  if { [regexp -nocase "^$botnicks,?:? (with|at|against|by) who" $text ma mb prop] ||
       [regexp -nocase "^(with|at|against|by) who .* $botnicks ?\\?" $text ma prop ma] } {
    bMotion_plugin_complex_question_with $nick $channel $host $prop
    return 1
  }

  ## Who question targeted at me
  if { [regexp -nocase "^$botnicks,?:? who(se|'s)? " $text matches bot owner] ||
       [regexp -nocase "^who(se|'s)? .* $botnicks ?\\?" $text matches owner] } {
    bMotion_plugin_complex_question_who $nick $channel $host $owner
    return 1
  }

  ## Why question targeted at me
  if { [regexp -nocase "^$botnicks,?:? why" $text] ||
       [regexp -nocase "why.* $botnicks ?\\?" $text] } {
    bMotion_plugin_complex_question_why $nick $channel $host 
    return 1
  }

  ## Where question targeted at me
  if { [regexp -nocase "^$botnicks,?:? where" $text] ||
       [regexp -nocase "^where .* $botnicks ?\\?" $text] } {
    bMotion_plugin_complex_question_where $nick $channel $host 
    return 1
  }

  ## How many question targeted at me
  if { [regexp -nocase "^$botnicks,?:? how ?many" $text] ||
       [regexp -nocase "^how ?many .* $botnicks ?\\?" $text] } {
    bMotion_plugin_complex_question_many $nick $channel $host 
    return 1
  }

  ## When question targeted at me
  if { [regexp -nocase "^$botnicks,?:? (when|what time)" $text] ||
       [regexp -nocase "^(when|what time) .* $botnicks ?\\?" $text] } {
    bMotion_plugin_complex_question_when $nick $channel $host 
    return 1
  }

  ## How question targeted at me
  if { [regexp -nocase "^$botnicks,?:? how" $text] ||
       [regexp -nocase "^how .* $botnicks ?\\?" $text] } {
    bMotion_plugin_complex_question_how $nick $channel $host 
    return 1
  }

  # me .... ?
  if [regexp -nocase "^${botnicks}:?,? (.+)\\?$" $text ming ming2 question] {
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{randomReplies}"
    return 1
  }

  # ... me?
  if [regexp -nocase "${botnicks}\\?$" $text bhar ming what] {
    if { [rand 2] == 1 } {
      bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{randomReplies}"
      return 1
    }
  }

  if [bMotionTalkingToMe $text] {
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{randomReplies}"
    return 1
  }
  return 0
}

proc bMotion_plugin_complex_question_what { nick channel host question } {
    global bMotionInfo
    #see if we know the answer to it
    if {$question != ""} {
      if [regexp -nocase {[[:<:]]a/?s/?l[[:>:]]} $question] {
        #asl?
        set age [expr [rand 20] + 13]
        bMotionDoAction $channel $nick "%%: $age/$bMotionInfo(gender)/%VAR{locations}"
        return 1
      }
      if [string match -nocase "*time*" $question] {
        #what time: redirect to when
        bMotion_plugin_complex_question_when $nick $channel $host
        return 1
      }
    }

    #generic answer to what
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerWhats}"
}

proc bMotion_plugin_complex_question_when { nick channel host } {
  bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerWhens}"
  return 1
}

proc bMotion_plugin_complex_question_with { nick channel host prop } {
  set answer "$prop %VAR{answerWithWhos}"
  bMotionDoAction $channel [bMotionGetRealName $nick $host] $answer
  return 1
}

proc bMotion_plugin_complex_question_who { nick channel host owner } {
  if {$owner == "se"} {
    set line "%OWNER[%VAR{answerWhos}]"
  } else {
    set line "%VAR{answerWhos}"
  }
  bMotionDoAction $channel [bMotionGetRealName $nick $host] "$line"
  return 1
}

proc bMotion_plugin_complex_question_why { nick channel host } {
  bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerWhys}"
  return 1
}

proc bMotion_plugin_complex_question_where { nick channel host } {
  bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerWheres}"
  return 1
}

proc bMotion_plugin_complex_question_many { nick channel host } {
  bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerHowmanys}"
  return 1
}

proc bMotion_plugin_complex_question_how { nick channel host } {
  bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerHows}"
  return 1
}