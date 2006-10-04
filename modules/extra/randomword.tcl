# random word generator for bex

source "scripts/randomwordList.tcl"

bind pub - "!beckyword" pubm_beckyword
bind pub - "!beckywordcount" pubm_beckywordcount
bind pub - "!kitword" pubm_kitword
bind pub - "!ick" pubm_ick
bind pub - "!rosieword" pubm_rosieword
#bind pub - "!taunt" pubm_taunt
bind pub - "!bhar" pubm_letters

proc pubm_beckyword {nick host handle channel text} {
  global randomPrefixes randomFirstParts randomMiddleParts randomEndParts
  set prefix ""
  if [rand 2] {
    set prefix [pickRandom $randomPrefixes]
  }
  bMotionDoAction $channel $nick "$prefix[pickRandom $randomFirstParts][pickRandom $randomMiddleParts][pickRandom $randomEndParts]"
}

proc pubm_beckywordcount {nick host handle channel text} {
  global randomFirstParts randomMiddleParts randomEndParts randomPrefixes
  set bl "prefixes: [llength $randomPrefixes] first parts: [llength $randomFirstParts] second parts: [llength $randomMiddleParts] last parts: [llength $randomEndParts]"

  set total [expr [llength $randomFirstParts] * [llength $randomMiddleParts] * [llength $randomEndParts] * [expr [llength $randomPrefixes] + 1]]
  set bl "$bl total: $total"
  puthelp "PRIVMSG $channel :$bl"
}

proc pubm_kitword {nick host handle channel text} {
  global randomKitWords
  bMotionDoAction $channel $nick "[pickRandom $randomKitWords]"
}



proc pubm_rosieword {nick host handle channel text} {
  global randomRosieFirstParts randomRosieSecondParts
  set first [pickRandom $randomRosieFirstParts]
  set line ""

  set mode [rand 3]
  
  if {$mode == 0} {
    #<something><something>
    set second $first
    while {$second == $first} {
      set second [pickRandom $randomRosieSecondParts]
    }
    set line "$first$second"
  }

  if {$mode == 1} {
    #<something> <something>
    set second $first
    while {$second == $first} {
      set second [pickRandom $randomRosieSecondParts]
    }
    set line "$first $second"
  }

  if {$mode == 2} {
    #putlog "mode = 2 bof"
    #<something>^n<something>
    set count [rand 10]
    set count [expr $count + 1]
    set line $first
    while {$count > 0} {
      incr count -1
      set line "$line $first"
    }
    set second [pickRandom $randomRosieSecondParts]
    set line "$line $second"
  }
  bMotionDoAction $channel $nick "$line"
}

proc pubm_letters {nick host handle channel text} {
  set randomChar "!£$%^&*@#~€"

  set randomChars [split $randomChar {}]

  set length [rand 8]
  set length [expr $length + 5]

  set line ""

  while {$length >= 0} {
    incr length -1

    set line "$line[pickRandom $randomChars]"
  }

  bMotionDoAction $channel "" $line
}
