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

# NOTICE TO PROGRAMMERS (hi James, how've you been?)
# Correct format for regexps is now just botnicks: as pre-processing takes
#   care of other formats and rewrites them

bMotion_plugin_add_complex "question" {[?>/]$} 100 bMotion_plugin_complex_question "en"

proc bMotion_plugin_complex_question { nick host handle channel text } {
  bMotion_putloglev 2 * "Question handler triggerred"
  global botnicks bMotionFacts

	if [regexp {\\o/} $text] {
		return
	}

  # START PREPROCESSING

  # Allow typos for question marks at end
  regsub {(.+)[>\/]$} $text {\1?} text

  # Move nick from end to start to simplify regexps later on
  if {[regexp -nocase "(.+?),? $botnicks\\?$" $text matches 1]} {
    global botnick
    bMotion_putloglev d * "rewriting question to have my nick at the start"
    set text "$botnick: $1\?"
    bMotion_putloglev 1 * "question is now: $text"
  }

  # Rewrite nick, and nick to nick: to simplify regexps later on
  if {[regexp -nocase "$botnicks,? (.+)" $text matches 1 2]} {
    global botnick
    bMotion_putloglev d * "rewriting question to use colon after my nick"
    set text "$botnick: $2"
    bMotion_putloglev 1 * "question is now: $text"
  }

  # END OF PREPROCESSING


	if [regexp -nocase "^$botnicks: when you (say|said),? (.+),? (did|do) you mean,? (.+)\\??" $text matches ignore a 1 b 2] {
		bMotionDoAction $channel $1 "%VAR{noimeant}" $2
		return 1
	}

  ## wellbeing question targeted at me
  if { [regexp -nocase "^$botnicks: how( a|')?re (you|ya)( today|now)?\\??$" $text] ||
       [regexp -nocase "${botnicks}: (how('?s|z) it going|hoe gaat het|what'?s up|'?sup|how are you)\\?" $text]} {
      bMotion_question_wellbeing $nick $channel $host
      return 1
  }

	if {[regexp -nocase "^$botnicks: what (noise|sound)s? " $text]} {
		bMotionDoAction $channel $nick "%VAR{sound_answer}"
		return 1
	}

	if {[regexp -nocase "^$botnicks: what did you do to" $text]} {
		bMotionDoAction $channel $nick "%VAR{whatdiddos}"
		return 1
	}

  ## moved here from further down because it'd never be triggered otherwise   --szrof
  ## What have question targeted at me
  if [regexp -nocase "^$botnicks: what( have|'ve) " $text] {
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerWhathaves}"
    return 1
  }

  if { [regexp -nocase "^$botnicks: wh(ich|at) ?colou?r" $text]} {
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{question_colour_wrapper}"
    return 1
  }

  ## What have question targeted at me
  if { [regexp -nocase "^$botnicks: what( are| is|'?s| was| were|'?re) the (odds|chance|probability|likelihood)" $text]} {
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerWhatOdds}"
    return 1
  }

  if [regexp -nocase {\ma/?s/?l\M} $text] {
    if {[bMotionTalkingToMe $text] || ([rand 3] == 0)} {
      set age [expr [rand 20] + 13]
      bMotionDoAction $channel $nick "%%: $age/$bMotionInfo(gender)/%VAR{locations}"
      return 1
    }
  }

  ## What question targeted at me
  # TODO: wtf
  if { [regexp -nocase "what('?s)?(.+)" $text matches s question] ||
       [regexp -nocase "what('?s)? (.*)\\?" $text matches s question] } {
    set term ""

    if [regexp -nocase "what time( is it( where you are|where you live|for you)?)?" $text matches isit where] {
      if {$isit != ""} {
        if {$where != ""} {
          # Hmm
          # TODO: pick up Eggdrop's timezone setting, or the system one from ENV?
          set now [clock format [clock seconds]]
        } else {
          set now [clock format [clock seconds] -gmt 1]
        }
        bMotionDoAction $channel $nick "%%: it's $now"
        return 1
      }

      bMotionDoAction $channel $nick "%VAR{answerWhens}"
      return 1
    }

    # expand what's-type contractions
    if [regexp -nocase {what(\'?s| is| was) ([^ ]+)} $text matches ignore term] {
      set question "is $term"
    }

    if {($term == "") && (![bMotionTalkingToMe $text])} { 
      bMotion_putloglev d * "what question handler bailing"
      return 0 
    }

    global bMotionInfo bMotionFacts bMotionOriginalInput

    #see if we know the answer to it
    if {$question != ""} {

      #let's try to process this with facts
      if [regexp -nocase {(are|were|is) ((an?|the) )?([^ ]+)} $question matches ignore ignore3 ignore2 term] {
        set term [string map {"?" ""} $term]
        catch {
          set term [string tolower $term]
          bMotion_putloglev 1 * "looking for what,$term"
          set answers $bMotionFacts(what,$term)
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
    return 1
  }




  ## With/at/against who question targeted at me
  if { [regexp -nocase "^$botnicks: (with|at|against|by) who" $text ma mb prop]} {
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "$prop %VAR{answerWithWhos}"
    return 1
  }

  ## Who question targeted at me
  if [regexp -nocase "^$botnicks: who(se|'s)? " $text matches bot owner] {
    if {$owner == "se"} {
      set line "%VAR{answerWhos:owner}"
    } else {
      set line "%VAR{answerWhos}"
    }
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "$line"
    return 1
  }
  
  ## Want question targetted at me
	set item ""
  if { [regexp -nocase "^$botnicks: do you (need|want) (a|these|this|some|the|those|that) (.+)" $text matches a b c item] ||
        [regexp -nocase "^$botnicks: would you like (.+)" $text matches a item] } {

    if {$item != ""} {
      # let's try to figure out if this is an item proper or something like "to go home" etc
      if {[regexp -nocase "^(to)" $item]} {
        # TODO: scope for improvement --^
        bMotion_putloglev 3 * "item actually looks like an action, using generic answer for now"
        bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{question_want_reply_wrapper}"
        return 1
      }

      # TODO: check if it's a user
      # TODO: factorise this code?
      # TODO: other tests?

      bMotion_putloglev 3 * "item looks like an item!"
      regsub {\?} $item "" item
      set original_item $item
      set item [string tolower [bMotion_strip_article $item]]
      regsub "s$" $item "" item

      if [bMotion_abstract_contains "_bmotion_like" $original_item] {
        bMotion_putloglev d * "I apparently like $original_item"
        bMotionDoAction $channel $item "%VAR{want_item_like}" $nick
        return 1
      }

      if [bMotion_abstract_contains "_bmotion_dislike" $original_item] {
        bMotion_putloglev d * "I apparently dislike $original_item"
        bMotionDoAction $channel $item "%VAR{want_item_dislike}" $nick
        return 1
      }
      
      if {[rand 100] > 80} {
        bMotionDoAction $channel $item "%VAR{want_item_dislike}" $nick
        bMotion_putloglev d * "deciding i dislike $original_item"
        bMotion_abstract_add "_bmotion_dislike" $original_item
      } else {
        bMotionDoAction $channel $item "%VAR{want_item_like}" $nick
        bMotion_putloglev d * "deciding i like $original_item"
        bMotion_abstract_add "_bmotion_like" $original_item
      }
      return 1
    }

    if {$item == ""} {
      bMotion_putloglev 3 * "item is blank, using generic want answer"
      bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{question_want_reply_wrapper}"
    }

    return 1
  }

  ## Why question targeted at me
  if [regexp -nocase "^$botnicks: why('s|'d)?\\M" $text] {
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerWhys}"
    return 1
  }

  ## Where question targeted at me
  if [regexp -nocase "^$botnicks: where('s|'d)?\\M" $text] {
    if {[getFriendship $nick] < 50} {
      bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{upyourbums}"
    } else {
      bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerWheres}"
    }
    return 1
  }

  bMotion_putloglev 3 * "Checking question for 'how many'"
  ## How many question targeted at me
  if [regexp -nocase "^$botnicks: how ?many( (\[^ \]+))?" $text matches 1 2 3] {
    # special case for christmas cracker hats
    if [regexp -nocase "how many (xmas |cracker |christmas )?hats (am|are|do|is|have|has) (\[^ \]+) " $text matches 1 2 3] {
      if {$3 == "you"} {
        set hats [bMotion_plugins_settings_get "cracker" "hats" $channel ""]
        if {($hats == "") || ($hats == 0)} {
          bMotionDoAction $channel "" "%VAR{cracker_no_hats_own}"
          return 1
        }
        if {$hats == 1} {
          bMotionDoAction $channel "" "One hat only"
          return 1
        }
        bMotionDoAction $channel $handle "%VAR{cracker_hats_current}" $hats
        return 1
      }

      if {$3 == "i"} {
        set hats [bMotion_plugins_settings_get "cracker" "hats" $channel $handle]
        if {($hats == "") || ($hats == 0)} {
          bMotionDoAction $channel "" "%VAR{cracker_no_hats_you}"
          return 1
        }
        if {$hats == 1} {
          bMotionDoAction $channel "" "One hat only"
          return 1
        }
        bMotionDoAction $channel $handle "%VAR{cracker_your_hats_current}" $hats 
        return 1
      }

      set handle [nick2hand $3]
      if {($handle == "*" || $handle == "")} {
        bMotionDoAction $channel "" "No idea"
        return 1
      }
        set hats [bMotion_plugins_settings_get "cracker" "hats" $channel $handle]
        if {($hats == "") || ($hats == 0)} {
          bMotionDoAction $channel $handle "%VAR{cracker_no_hats_handle}"
          return 1
        }
        if {$hats == 1} {
          bMotionDoAction $channel "" "One hat only"
          return 1
        }
        bMotionDoAction $channel $handle "%VAR{cracker_handle_hats_current}" $hats
        return 1
    }
    #End of special cracker hats case

    if {$3 == "years"} {
      bMotionDoAction $channel $nick "%NUMBER{1000}"
      return 1
    }

    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerHowmanys}"
    return 1
  }

  ## How long question targeted at me
  if [regexp -nocase "^$botnicks: how long" $text] {
    if [regexp -nocase "how long (is it )?((un)?till?|to|since) (.+)\\?" $text matches 1 direction 3 target] {
      set targetdate [string tolower $target]
      set direction [string tolower $direction]
      switch $target {
        "christmas eve" -
        "xmas eve" {
          set targetdate "24 Dec "
          if {$direction == "since"} {
            append targetdate [clock format [clock scan "1 year ago"] -format "%Y"]
          }
        }

        "christmas" -
        "xmas" {
          set targetdate "25 Dec "
          if {$direction == "since"} {
            append targetdate [clock format [clock scan "1 year ago"] -format "%Y"]
          }
        }

        "talk like a pirate day" {
          set targetdate "19 Sep "
          if {$direction == "since"} {
            append targetdate [clock format [clock scan "1 year ago"] -format "%Y"]
          }
        }

        default {
          set targetdate $target
        }
      }

      bMotion_putloglev d * "calculating how long until $targetdate"
      set targetstamp -1
      catch {
        set targetstamp [clock scan $targetdate]
      }

      if {$targetstamp == -1} {
        bMotionDoAction $channel $nick "No idea, I don't know when that is %SMILEY{sad}"
        return 1
      }

      bMotion_putloglev d * "$targetdate converted into $targetstamp, which is [clock format $targetstamp]"

      set howlongstr [howlong $targetstamp]
      if {$howlongstr == "now"} {
        bMotionDoAction $channel $nick "it's right now!"
        return 1
      }

      if {[string match "*ago" $howlongstr]} {
        bMotionDoAction $channel $nick "it was $target $howlongstr"
      } else {
        bMotionDoAction $channel $nick "it's $howlongstr $target"
      }
      return 1
    }
    
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerHowLongs}"
    return 1
  }

  ## How many question targeted at me
  if [regexp -nocase "^$botnicks: how old" $text] {
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerHowOlds}"
    return 1
  }

  ## How big question targeted at me
  if [regexp -nocase "^$botnicks: how big" $text] {
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerHowBigs}"
    return 1
  }

  ## When question targeted at me
  # Note that "what time" is handled above in the 'what' handler
  if [regexp -nocase "^$botnicks: when" $text] {
    # TODO: take note of when did vs when will
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerWhens}"
    return 1
  }

  ## How many question targeted at me
  if [regexp -nocase "^$botnicks: how much" $text] {
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerHowmuch}"
    return 1
  }

  ## How question targeted at me
  if [regexp -nocase "^$botnicks: how" $text] {
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerHows}"
    return 1
  }

  # TODO: remove?
  if [regexp -nocase  "^${botnicks}: do(n'?t)? you (like|want|find .+ attractive|get horny|(find|think) .+ (is ?)horny|have|keep)" $text] {
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{yesnos}"
    return 1
  }

  ## Have you question targeted at me
  #TODO: handle "have you got" differently
  if [regexp -nocase "^$botnicks: have you" $text] {
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerHaveyous}"
    return 1
  }

  ## Did you question targeted at me
  if [regexp -nocase "^$botnicks: did you" $text] {
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerDidyous}"
    return 1
  }

  ## Will you question targeted at me
  if [regexp -nocase "^$botnicks: will you" $text] {
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerWillyous}"
    return 1
  }

  ## Would you question targeted at me
  if [regexp -nocase "^$botnicks: would you" $text] {
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerWouldyous}"
    return 1
  }

  ## Are you question targeted at me
  if [regexp -nocase "^$botnicks: are you" $text] {
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerAreyous}"
    return 1
  }

  ## Can you question targeted at me
  if [regexp -nocase "^$botnicks: can you" $text] {
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerCanyous}"
    return 1
  }

  ## Do you question targeted at me
  if [regexp -nocase "^$botnicks: do you" $text] {
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerDoyous}"
    return 1
  }

  ## Is your question targeted at me
  if [regexp -nocase "^$botnicks: is your" $text] {
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{answerIsyours}"
    return 1
  }

  if [regexp -nocase "^$botnicks: is it (.+) yet" $text] {

    if [regexp -nocase "(xmas|christmas) ?eve" $text] {
      set date [clock format [clock seconds] -format "%d%m"]
      if {$date == "2412"} {
        bMotionDoAction $channel $nick "%VAR{affirmatives}"
        return 1
      }

      if {$date == "2312"} {
        bMotionDoAction $channel $nick "%={nearly:almost:soon:not long now:just about}!"
        return 1
      }

      bMotionDoAction $channel $nick "%VAR{nos2}"
      return 1
    }

    if [regexp -nocase "xmas|christmas" $text] {
      # Check if it's 25th Dec
      set date [clock format [clock seconds] -format "%d%m"]
      if {$date == "2512"} {
        bMotionDoAction $channel $nick "%VAR{affirmatives}"
        return 1
      }

      if {$date == "2412"} {
        bMotionDoAction $channel $nick "%={nearly:almost:soon:not long now:just about}!"
        return 1
      }

      bMotionDoAction $channel $nick "%VAR{nos2}"
      return 1
    }

    if [regexp -nocase "hometime" $text] {
      bMotionDoAction $channel $nick "%VAR{nothometimes}"
      return 1
    }
  }

  # ... me?
  if [regexp -nocase "^$botnicks\\?$" $text bhar ming what] {
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{shortRandomReplies}"
    return 1
  }

  # me .... ?
  if [regexp -nocase "^$botnicks: (.+)\\?$" $text ming ming2 question] {
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{randomReplies}"
    return 1
  }


  if [bMotionTalkingToMe $text] {
    bMotion_putloglev 2 * "$nick talkingtome catch"
    bMotionDoAction $channel [bMotionGetRealName $nick $host] "%VAR{randomReplies}"
    return 1
  }
  return 0
}

proc bMotion_plugin_complex_question_what { nick channel host question } {
}


### Start abstracts 
bMotion_abstract_register "question_what_fact_wrapper" {
  "%%"
  "%% i guess"
  "i think it's %%"
  "%% i think"
  "%% i suppose"
}

bMotion_abstract_register "question_want_reply_wrapper" {
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

bMotion_abstract_register "question_colour_wrapper" {
  "%VAR{colours}"
  "hmm.. %VAR{colours}, I think"
  "%VAR{colours}"
  "%VAR{colours}%|No! %VAR{colours}!"
  "%VAR{colours}"
}

bMotion_abstract_register "want_item_like" {
	"ooh yes please"
	"%REPEAT{3:7:m} %%"
	"yes please %2"
	"/<3 %%"
	"yes"
	"affirmative"
	"r"
	"r %VAR{smiles}"
	"wh%REPEAT{4:10:e}%|%% == best"
	"%% <3"
	"%%++"
  "giev"
  "gimme"
  "%% is the best thing"
}

bMotion_abstract_register "want_item_dislike" {
	"e%REPEAT{2:5:w} no thanks"
	"barf"
	"bleh"
	"nnk"
	"do not want"
	"blah horrible"
	"no"
	"no thanks"
	"negative"
	"god no"
	"not a chance"
  "ugh"
}

bMotion_abstract_register "whatdiddos" {
	"i %VAR{sillyVerbs:past} it %VAR{smiles}"
	"i %VAR{sillyVerbs:past} it %VAR{unsmiles}"
}

bMotion_abstract_register "noimeant" {
	"no when i said %% i meant %%%!%|if i meant %2 i'd have said that, wouldn't i?"
}
