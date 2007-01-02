## bMotion plugin: question handlers
#
# $Id$
#
# vim: fdm=indent fdn=1

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
  bMotion_putloglev 2 * "Question handler triggerred"
  global botnicks bMotionFacts

	if [regexp {\\o/} $text] {
		return
	}

  regsub {(.+)[>\/]$} $text {\1?} text

  bMotion_putloglev 3 * "Checking question for wellbeing"
  ## wellbeing question targeted at me
  if { [regexp -nocase "^$botnicks,?:? how( a|')?re (you|ya)( today|now)?\\??$" $text] ||
       [regexp -nocase "^how( a|')?re (you|ya).*$botnicks ?\\?" $text] ||
       [regexp -nocase "${botnicks}?:? ?(how('?s|z) it going|hoe gaat het|what'?s up|'?sup|how are you),?( ${botnicks})?\\?" $text]} {
      bMotion_question_wellbeing $nick $channel $host
      return 1
  }

  ## moved here from further down because it'd never be triggered otherwise   --szrof
  bMotion_putloglev 3 * "Checking question for 'what have'"
  ## What have question targeted at me
  if { [regexp -nocase "^$botnicks,?:? what ?have" $text] ||
       [regexp -nocase "^what ?have .* $botnicks ?\\?" $text] } {
    bMotion_plugin_complex_question_whathave $nick $channel $host
    return 1
  }

  bMotion_putloglev 3 * "Checking question for 'which/what colour'"
  ## What have question targeted at me
  if { [regexp -nocase "^$botnicks,?:? wh(ich|at) ?colou?r" $text] ||
       [regexp -nocase "^wh(ich|at) ?colou?r .* $botnicks ?\\?" $text] } {
    bMotion_plugin_complex_question_whatcolour $nick $channel $host
    return 1
  }

  bMotion_putloglev 3 * "Checking question for 'what are the odds'"
  ## What have question targeted at me
  if { [regexp -nocase "^$botnicks,?:? what ?(are|is|'?s|was|were) the (odds|chance|probability)" $text] ||
       [regexp -nocase "^what ?(are|is|'?s|was|were) the (odds|chance|probability) .* $botnicks ?\\?" $text] } {
    bMotion_plugin_complex_question_whatodds $nick $channel $host
    return 1
  }

  bMotion_putloglev 3 * "Checking question for 'what'"
  ## What question targeted at me
  if { [regexp -nocase "what('?s)?(.+)" $text matches s question] ||
       [regexp -nocase "what('?s)? (.*)\\?" $text matches s question] } {
    set term ""
    if [regexp -nocase {what(\'?s| is| was) ([^ ]+)} $text matches ignore term] {
      set question "is $term"
    }
    if {($term == "") && (![bMotionTalkingToMe $text])} { return 0 }
    bMotion_plugin_complex_question_what $nick $channel $host $question
    return 1
  }




  bMotion_putloglev 3 * "Checking question for 'with/at/against'"
  ## With/at/against who question targeted at me
  if { [regexp -nocase "^$botnicks,?:? (with|at|against|by) who" $text ma mb prop] ||
       [regexp -nocase "^(with|at|against|by) who .* $botnicks ?\\?" $text ma prop ma] } {
    bMotion_plugin_complex_question_with $nick $channel $host $prop
    return 1
  }

  bMotion_putloglev 3 * "Checking question for 'who'"
  ## Who question targeted at me
  if { [regexp -nocase "^$botnicks,?:? who(se|'s)? " $text matches bot owner] ||
       [regexp -nocase "^who(se|'s)? .* $botnicks ?\\?" $text matches owner] } {
    bMotion_plugin_complex_question_who $nick $channel $host $owner
    return 1
  }

  bMotion_putloglev 3 * "Checking question for 'want'"
  ## Want question targetted at me
  if { [regexp -nocase "^$botnicks,?:? do you (need|want) (a|these|this|some|the|those|that)" $text] ||
        [regexp -nocase "^do you (want|need) (a|these|this|some|the|those|that) .* $botnicks ?\\?" $text] ||
        [regexp -nocase "^$botnicks,?:? would you like" $text] ||
        [regexp -nocase "^would you like .+ $botnicks" $text]} {
      bMotion_plugin_complex_question_want $nick $channel $host
      return 1
  }

  bMotion_putloglev 3 * "Checking question for 'why'"
  ## Why question targeted at me
  if { [regexp -nocase "^$botnicks,?:? why" $text] ||
       [regexp -nocase "why.* $botnicks ?\\?" $text] } {
    bMotion_plugin_complex_question_why $nick $channel $host
    return 1
  }

  bMotion_putloglev 3 * "Checking question for 'where'"
  ## Where question targeted at me
  if { [regexp -nocase "^$botnicks,?:? where" $text] ||
       [regexp -nocase "^where .* $botnicks ?\\?" $text] } {
    bMotion_question_where $nick $channel $host
    return 1
  }

  bMotion_putloglev 3 * "Checking question for 'how many'"
  ## How many question targeted at me
  if { [regexp -nocase "^$botnicks,?:? how ?many" $text] ||
       [regexp -nocase "^how ?many .* $botnicks ?\\?" $text] } {
    bMotion_plugin_complex_question_many $nick $channel $host
    return 1
  }

  bMotion_putloglev 3 * "Checking question for 'how long'"
  ## How many question targeted at me
  if { [regexp -nocase "^$botnicks,?:? how ?long" $text] ||
       [regexp -nocase "^how ?long .* $botnicks ?\\?" $text] } {
    bMotion_plugin_complex_question_long $nick $channel $host
    return 1
  }

  bMotion_putloglev 3 * "Checking question for 'how old'"
  ## How many question targeted at me
  if { [regexp -nocase "^$botnicks,?:? how ?old" $text] ||
       [regexp -nocase "^how ?old .* $botnicks ?\\?" $text] } {
    bMotion_plugin_complex_question_age $nick $channel $host
    return 1
  }

  bMotion_putloglev 3 * "Checking question for 'when'"
  ## When question targeted at me
  if { [regexp -nocase "^$botnicks,?:? (when|what time)" $text] ||
       [regexp -nocase "^(when|what time) .* $botnicks ?\\?" $text] } {
    bMotion_plugin_complex_question_when $nick $channel $host
    return 1
  }

  bMotion_putloglev 3 * "Checking question for 'how much'"
  ## How many question targeted at me
  if { [regexp -nocase "^$botnicks,?:? how ?much" $text] ||
       [regexp -nocase "^how ?much .* $botnicks ?\\?" $text] } {
    bMotion_plugin_complex_question_much $nick $channel $host
    return 1
  }

  bMotion_putloglev 3 * "Checking question for 'how'"
  ## How question targeted at me
  if { [regexp -nocase "^$botnicks,?:? how" $text] ||
       [regexp -nocase "^how .* $botnicks ?\\?" $text] } {
    bMotion_plugin_complex_question_how $nick $channel $host
    return 1
  }

  bMotion_putloglev 3 * "Checking question for some general questions"
  # some other random responses, handled here rather than simple_general so as not to break other code
    if [regexp -nocase  "^${botnicks}:?,? do(n'?t)? you (like|want|find .+ attractive|get horny|(find|think) .+ (is ?)horny|have|keep)" $text] {
    bMotion_putloglev 2 * "$nick general question"
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{yesnos}"
    return 1
  }

  ## begin sid's stuff

  ## moved "what have" to top   --szrof

  ## moved "how much" further up   --szrof

  bMotion_putloglev 3 * "Checking question for 'have you'"
  ## Have you question targeted at me
  if { [regexp -nocase "^$botnicks,?:? have ?you" $text] ||
       [regexp -nocase "^have ?you .* $botnicks ?\\?" $text] } {
    bMotion_plugin_complex_question_haveyou $nick $channel $host
    return 1
  }

  bMotion_putloglev 3 * "Checking question for 'did you'"
  ## Did you question targeted at me
  if { [regexp -nocase "^$botnicks,?:? did ?you" $text] ||
       [regexp -nocase "^did ?you .* $botnicks ?\\?" $text] } {
    bMotion_plugin_complex_question_didyou $nick $channel $host
    return 1
  }

  bMotion_putloglev 3 * "Checking question for 'will you'"
  ## Will you question targeted at me
  if { [regexp -nocase "^$botnicks,?:? will ?you" $text] ||
       [regexp -nocase "^will ?you .* $botnicks ?\\?" $text] } {
    bMotion_plugin_complex_question_willyou $nick $channel $host
    return 1
  }

  bMotion_putloglev 3 * "Checking question for 'would you'"
  ## Would you question targeted at me
  if { [regexp -nocase "^$botnicks,?:? would ?you" $text] ||
       [regexp -nocase "^would ?you .* $botnicks ?\\?" $text] } {
    bMotion_plugin_complex_question_wouldyou $nick $channel $host
    return 1
  }

  bMotion_putloglev 3 * "Checking question for 'are you'"
  ## Are you question targeted at me
  if { [regexp -nocase "^$botnicks,?:? are ?you" $text] ||
       [regexp -nocase "^are ?you .* $botnicks ?\\?" $text] } {
    bMotion_plugin_complex_question_areyou $nick $channel $host
    return 1
  }

  bMotion_putloglev 3 * "Checking question for 'can you'"
  ## Can you question targeted at me
  if { [regexp -nocase "^$botnicks,?:? can ?you" $text] ||
       [regexp -nocase "^can ?you .* $botnicks ?\\?" $text] } {
    bMotion_plugin_complex_question_canyou $nick $channel $host
    return 1
  }

  bMotion_putloglev 3 * "Checking question for 'do you'"
  ## Do you question targeted at me
  if { [regexp -nocase "^$botnicks,?:? do ?you" $text] ||
       [regexp -nocase "^do ?you .* $botnicks ?\\?" $text] } {
    bMotion_plugin_complex_question_doyou $nick $channel $host
    return 1
  }

  bMotion_putloglev 3 * "Checking question for 'is your'"
  ## Is your question targeted at me
  if { [regexp -nocase "^$botnicks,?:? is ?your" $text] ||
       [regexp -nocase "^is ?your .* $botnicks ?\\?" $text] } {
    bMotion_plugin_complex_question_isyour $nick $channel $host
    return 1
  }

  ##end sid's stuff

  # me .... ?
  if [regexp -nocase "^${botnicks}:?,? (.+)\\?$" $text ming ming2 question] {
    bMotion_putloglev 2 * "$nick final question catch"
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{randomReplies}"
    return 1
  }

  # ... me?
  if [regexp -nocase "${botnicks}\\?$" $text bhar ming what] {
    bMotion_putloglev 2 * "$nick very final question catch"
    if { [rand 2] == 1 } {
      bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{randomReplies}"
      return 1
    }
  }

  if [bMotionTalkingToMe $text] {
    bMotion_putloglev 2 * "$nick talkingtome catch"
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{randomReplies}"
    return 1
  }
  return 0
}

proc bMotion_plugin_complex_question_what { nick channel host question } {
    bMotion_putloglev 2 * "$nick what !$question! question"
    global bMotionInfo bMotionFacts bMotionOriginalInput
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
      #let's try to process this with facts
      if [regexp -nocase {is ((an?|the) )?([^ ]+)} $question ignore ignore3 ignore2 term] {
        set term [string map {"?" ""} $term]
        catch {
          set term [string tolower $term]
          bMotion_putloglev 1 * "looking for what,$term"
          set answers $bMotionFacts(what,$term)
          #putlog $answers
          if {[llength $answers] > 0} {
            bMotion_putloglev 1 * "I know answers for what,$term"
            if {![bMotionTalkingToMe $bMotionOriginalInput]} {
              bMotion_putloglev 1 * "I wasn't asked directly"
              if [rand 5] {
                return 1
              }
              bMotion_putloglev 1 * "... but I shall answer anyway."
            }
          }
          set answer [pickRandom $answers]
          #remove any timestamp
          regsub {(_[0-9]+_ )?(.+)} $answer "\2" answer
          bMotionDoAction $channel [pickRandom $answers] "%VAR{question_what_fact_wrapper}"
          return 1
        } err
        if {$err == 1} {
          return 1
        }
      }
    }
    #generic answer to what
    if [bMotionTalkingToMe $bMotionOriginalInput] {
      bMotion_putloglev 2 * "Talking to me, so using generic answer"
      bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerWhats}"
      return 1
    }
}

proc bMotion_plugin_complex_question_when { nick channel host } {
  bMotion_putloglev 2 * "$nick When question"
  bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerWhens}"
  return 1
}

proc bMotion_plugin_complex_question_with { nick channel host prop } {
  bMotion_putloglev 2 * "$nick with question"
  set answer "$prop %VAR{answerWithWhos}"
  bMotionDoAction $channel [bMotionGetRealName $nick $host] $answer
  return 1
}

proc bMotion_plugin_complex_question_who { nick channel host owner } {
    bMotion_putloglev 2 * "$nick who question"
  if {$owner == "se"} {
    set line "%OWNER{%VAR{answerWhos}}"
  } else {
    set line "%VAR{answerWhos}"
  }
  bMotionDoAction $channel [bMotionGetRealName $nick $host] "$line"
  return 1
}

proc bMotion_plugin_complex_question_want { nick channel host } {
    bMotion_putloglev 2 * "$nick Want/need question"
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{question_want_reply_wrapper}"
    return 1
}

proc bMotion_plugin_complex_question_why { nick channel host } {
    bMotion_putloglev 2 * "$nick why question"
  bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerWhys}"
  return 1
}

## obsolete, it's been moved
# proc bMotion_plugin_complex_question_where { nick channel host } {
#   bMotion_putloglev 2 * "$nick where question"
#   bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerWheres}"
#   return 1
# }

proc bMotion_plugin_complex_question_many { nick channel host } {
    bMotion_putloglev 2 * "$nick how many question"
  bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerHowmanys}"
  return 1
}

proc bMotion_plugin_complex_question_how { nick channel host } {
    bMotion_putloglev 2 * "$nick how question"
  bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerHows}"
  return 1
}

## begin sid's functions

proc bMotion_plugin_complex_question_whathave { nick channel host } {
    bMotion_putloglev 2 * "$nick what have question"
  bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerWhathaves}"
  return 1
}

proc bMotion_plugin_complex_question_much { nick channel host } {
    bMotion_putloglev 2 * "$nick how much question"
  bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerHowmanys}"
  return 1
}

proc bMotion_plugin_complex_question_haveyou { nick channel host } {
    bMotion_putloglev 2 * "$nick have you question"
  bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerHaveyous}"
  return 1
}

proc bMotion_plugin_complex_question_didyou { nick channel host } {
    bMotion_putloglev 2 * "$nick did you question"
  bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerDidyous}"
  return 1
}

proc bMotion_plugin_complex_question_willyou { nick channel host } {
    bMotion_putloglev 2 * "$nick will you question"
  bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerWillyous}"
  return 1
}

proc bMotion_plugin_complex_question_wouldyou { nick channel host } {
    bMotion_putloglev 2 * "$nick would you question"
  bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerWouldyous}"
  return 1
}

proc bMotion_plugin_complex_question_areyou { nick channel host } {
    bMotion_putloglev 2 * "$nick are you question"
  bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerAreyous}"
  return 1
}

proc bMotion_plugin_complex_question_canyou { nick channel host } {
    bMotion_putloglev 2 * "$nick can you question"
  bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerCanyous}"
  return 1
}

proc bMotion_plugin_complex_question_doyou { nick channel host } {
    bMotion_putloglev 2 * "$nick do you question"
  bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerDoyous}"
  return 1
}

proc bMotion_plugin_complex_question_isyour { nick channel host } {
    bMotion_putloglev 2 * "$nick is your question"
  bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerIsyours}"
  return 1
}

proc bMotion_plugin_complex_question_whatcolour { nick channel host } {
    bMotion_putloglev 2 * "$nick what colour question"
  bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{question_colour_wrapper}"
  return 1
}

proc bMotion_plugin_complex_question_whatodds { nick channel host } {
    bMotion_putloglev 2 * "$nick what odds question"
  bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerWhatOdds}"
  return 1
}

proc bMotion_plugin_complex_question_long { nick channel host } {
    bMotion_putloglev 2 * "$nick how long question"
  bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerHowLongs}"
  return 1
}

proc bMotion_plugin_complex_question_age { nick channel host } {
    bMotion_putloglev 2 * "$nick how old question"
  bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerHowOlds}"
  return 1
}

## end sid's functions

bMotion_abstract_register "question_what_fact_wrapper"
bMotion_abstract_batchadd "question_what_fact_wrapper" {
  "%%"
  "%% i guess"
  "i think it's %%"
  "%% i think"
  "%% i suppose"
}

bMotion_abstract_register "question_want_reply_wrapper"
bMotion_abstract_batchadd "question_want_reply_wrapper" {
  "Why? I've got %VAR{sillyThings}!"
  "With %VAR{sillyThings} I have no need for anything else."
  "Ooh yes please, I've had %VAR{sillyThings} for so long it's boring me."
  "Will it feel as good as %VAR{sillyThings} from %ruser?"
  "Hell yes, %ruser's given me %VAR{sillyThings} and I can't wait to get away from it!"
  "I don't know, %VAR{sillyThings} from %ruser just %VAR{fellOffs}."
  "Yes, %VAR{confuciousStart} %VAR{confuciousEnd}."
  "No, %VAR{confuciousStart} %VAR{confuciousEnd}."
  "Can I have a %VAR{chocolates} too?"
  "Yes please, I left %VAR{sillyThings} in %VAR{answerWheres}."
  "Not until %VAR{answerWhens}."
  "Yes please, the Borg Queen offered me %VAR{trekNouns} and I only got %VAR{sillyThings}."
  "%VAR{sweet}."
}

bMotion_abstract_register "question_colour_wrapper"
bMotion_abstract_batchadd "question_colour_wrapper" {
  "%VAR{colours}"
  "hmm.. %VAR{colours}, I think"
  "%VAR{colours}"
  "%VAR{colours}%|No! %VAR{colours}!"
  "%VAR{colours}"
}
