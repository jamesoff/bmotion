#
#

###############################################################################
# This is a bMotion plugin
# Copyright (C) James Michael Seward 2000-2008
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

bMotion_plugin_add_simple "ick" "^!ick" 100 "%VAR{ick_sentences}" "en"

# abstracts

bMotion_abstract_register "ick_sentences" {
  "Don't picture %VAR{ick_males} and %VAR{ick_females} in %VAR{ick_wraps} and covered in %VAR{ick_covereds} %VAR{ick_fucks} each other %VAR{ick_locations}"
  "Don't picture %VAR{ick_females} %VAR{ick_fucks} %VAR{ick_males} %VAR{ick_dildos} %VAR{ick_locations}"
  "Don't picture %VAR{ick_females} %VAR{ick_fucks} %VAR{ick_females} %VAR{ick_dildos} %VAR{ick_locations}"
}

bMotion_abstract_register "ick_males" {
  "yourself"
  "Jean-Luc Picard"
  "the Pope"
  "John Major"
  "your dad"
  "the entire crew of Voyager"
  "your mum"
  "Bill Gates"
  "the Kazon"
  "the cast of Dallas"
  "Hwoarang"
  "Bob Monkhouse"
  "Dale Winton"
  "Harold from Neighbours"
  "Jade of Big Brother"
  "Tony Blair"
  "Graham Norton"
  "the editor of The Sun"
  "Tim"
  "Brian"
  "%ruser{male}"
}

bMotion_abstract_register "ick_females" {
  "the queen"
  "your mum"
  "Miss Marple"
  "that really minging woman who was on Eurovision"
  "Ling Xiaoyu"
  "Britney Spears"
  "Ling Xiaoyu"
  "Anna Kournikova"
  "Holly Valence"
  "Jade of Big Brother"
  "Davina McCall"
  "%ruser{female}"
}

bMotion_abstract_register "ick_wraps" {
  "cellophane"
  "cling-film"
  "pvc"
  "latex"
  "a thong"
  "stockings"
  "a miniskirt"
  "zero-gravity"
  "pantyhose"
  "chains"
  "hotpants"
}

bMotion_abstract_register "ick_covereds" {
  "custard" "cooking oil" "motor oil" "baby oil" "cream" "whipped cream" "KY" "strawberry jam"
  "Raspberry yogurt *eg*" "chocolate sauce" "coconut oil" "peanut butter" "dairylea" "%ruser{:owner} love juice"
  "jelly" "assorted food stuffs" "3 week old toffee yogurt"
}
bMotion_abstract_add_filter "ick_covereds" "%OWNER"

bMotion_abstract_register "ick_locations" {
  "in your bed"
  "on a chair" "in a field" "on a checkout" "against a fish tank"
  "on a trampoline" "from behind"
  "on a train" "on a bus" "in a swimming pool" "at the bus stop" "in your parents' bed" "under that bush"
  "under your desk" "at the local Tesco" "over there -->" "in the shower" "behind the bikesheds"
  "in Essex" "in Wales" "on a hilltop" "at Pontins" "for a porn site"
  "in %ruser{:owner} bed"
}

bMotion_abstract_register "ick_fucks" {
  "doing it to"
  "fucking"
  "shagging"
  "having sex with"
  "having intercourse with"
  "being intimate with"
  "fscking"
  "fux0ring"
  "rogering"
  "making sweet love to"
}

bMotion_abstract_register "ick_dildos" {
  "with a strap-on" "with a big dildo" "with a cucumber" "with a banana" "with a chicken"
  "whith a cucumber" "with a keyboard" "with bananna motion lotion" "with a ribbed tickler"
  "with a gag on" "with a webcam" "with a mouse" "with a realistic penis shaped keyring" "with a coffee bean"
  "with a cabbage" "with a carrott" "with WindowsXP" "wearing a dog collar" "with a computer virus"
  "with a carrot" "with a marrow" "with a 'bionic finger'" "and using shaving foam and a razor" "with a floppy disk"
  "with a can of plums" "with a pen" "with a toy car" "with the USS Enterprise" "with a cotton bud" "with corn on the cob"
  "with a mobile phone" "with %VAR{sillyThings}"
}
