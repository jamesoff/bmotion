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


bMotion_plugin_add_complex "question" {\?$} 100 bMotion_plugin_complex_question "en"

proc bMotion_plugin_complex_question { nick host handle channel text } {

  global botnicks

  ## What question targeted at me
  if { [regexp -nocase "^$botnicks,?:? what('?s)?(.+)" $text matches botn s question] ||
       [regexp -nocase "^what('?s)? .* $botnicks ?\\?" $text matches s question botn] } {
    bMotion_putloglev 1 * "bMotion: $nick asked me a what question"

    #see if we know the answer to it
    if {$question != ""} {
      if [regexp -nocase {[[:<:]]a/?s/?l[[:>:]]} $question] {
        set age [expr [rand 20] + 13]
        global bMotionInfo
        bMotionDoAction $channel $nick "%%: $age/$bMotionInfo(gender)/%VAR{locations}"
        return 1
      }
    }

    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerWhats}"
    return 1
  }

  ## With/at/against who question targeted at me
  if { [regexp -nocase "^$botnicks,?:? (with|at|against|by) who" $text ma mb prop] ||
       [regexp -nocase "^(with|at|against|by) who .* $botnicks ?\\?" $text ma prop ma] } {
    bMotion_putloglev d * "bMotion: $nick asked me a with/at/against who question ($prop)"
    
    set answer "$prop %VAR{answerWithWhos}"
    bMotionDoAction $channel [bMotionGetRealName $nick $host] $answer
    return 1
  }

  ## Who question targeted at me
  if { [regexp -nocase "^$botnicks,?:? who(se)? " $text matches bot owner] ||
       [regexp -nocase "^who(se)? .* $botnicks ?\\?" $text matches owner] } {
    bMotion_putloglev 1 * "bMotion: $nick asked me a who$owner question"
    
    if {$owner == "se"} {
      set line "%OWNER[%VAR{answerWhos}]"
    } else {
      set line "%VAR{answerWhos}"
    }
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "$line"
    return 1
  }

  ## Why question targeted at me
  if { [regexp -nocase "^$botnicks,?:? why" $text] ||
       [regexp -nocase "why.* $botnicks ?\\?" $text] } {
    bMotion_putloglev 1 * "bMotion: $nick asked me a why question"
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerWhys}"
    return 0
  }

  ## Where question targeted at me
  if { [regexp -nocase "^$botnicks,?:? where" $text] ||
       [regexp -nocase "^where .* $botnicks ?\\?" $text] } {
    bMotion_putloglev 1 * "bMotion: $nick asked me a where question"
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerWheres}"
    return 1
  }

  ## How many question targeted at me
  if { [regexp -nocase "^$botnicks,?:? how ?many" $text] ||
       [regexp -nocase "^how ?many .* $botnicks ?\\?" $text] } {
    bMotion_putloglev 1 * "bMotion: $nick asked me a how many question"
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerHowmanys}"
    return 1
  }

  ## When question targeted at me
  if { [regexp -nocase "^$botnicks,?:? (when|what time)" $text] ||
       [regexp -nocase "^(when|what time) .* $botnicks ?\\?" $text] } {
    bMotion_putloglev 1 * "bMotion: $nick asked me a when question"
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerWhens}"
    return 1
  }

  ## How question targeted at me
  if { [regexp -nocase "^$botnicks,?:? how" $text] ||
       [regexp -nocase "^how .* $botnicks ?\\?" $text] } {
    bMotion_putloglev 1 * "bMotion: $nick asked me a how question"
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerHows}"
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