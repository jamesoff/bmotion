#
# Modify this to fit your needs :)
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

#                         name  regexp            %  responses
bMotion_plugin_add_simple "url-img" {(http|ftp)://([[:alnum:]]+\.)+[[:alnum:]]{2,3}.+\.(jpg|jpeg|gif|png)} 25 "%VAR{rarrs}" "en"
#bMotion_plugin_add_simple "url-gen" {(http|ftp)://([[:alnum:]]+\.)+[[:alnum:]]{2,3}} 15 "%VAR{bookmarks}" "en"
bMotion_plugin_add_simple "ali g" "^((aiii+)|wikkid|innit|respect|you got me mobile|you iz)" 40 "%VAR{aiis}" "en"
bMotion_plugin_add_simple "wassup" "^wa+((ss+)|(zz+))u+p+(!*)?$" 40 "wa%REPEAT{4:12:a}up!" "en"
bMotion_plugin_add_simple "oops" "^(oops|who+ps|whups|doh |d\'oh)" 40 "%VAR{ruins}" "en"
bMotion_plugin_add_simple "bof" "^bof$" 30 [list "alors" "%VAR{FRENCH}"] "en"
bMotion_plugin_add_simple "alors" "^alors$" 30 [list "bof" "%VAR{FRENCH}"] "en"
bMotion_plugin_add_simple "bonjour" "bonjour" 20 "%VAR{FRENCH}" "en"
bMotion_plugin_add_simple "foo" "^foo$" 30 "bar" "en"
bMotion_plugin_add_simple "bar" "^bar$" 30 "baz" "en"
bMotion_plugin_add_simple "moo" "^mooo*!*$" 40 "%VAR{moos}" "en"
bMotion_plugin_add_simple ":(" "^((:|;|=)(\\\(|\\\[))$" 40 "%VAR{boreds}" "en"
bMotion_plugin_add_simple "bored" "i'm bored" 40 "%VAR{boreds}" "en"
bMotion_plugin_add_simple "transform" "^%botnicks:?,? transform and roll out" 100 [list "/transforms into %VAR{sillyThings} and rolls out"] "en"
bMotion_plugin_add_simple "didn't!" "^i didn'?t!?$" 40 "%VAR{ididntresponses}" "en"
bMotion_plugin_add_simple "ow" "^(ow+|ouch|aie+)!*$" 50 "%VAR{awwws}" "en"
#kis moved the following line to complex_questions because it was breaking stuff.
#kis bMotion_plugin_add_simple "question-have" "^%botnicks:?,? do(n'?t)? you (like|want|find .+ attractive|get horny|(find|think) .+ (is ?)horny|have|keep)" 100 "%VAR{yesnos}" "en"
bMotion_plugin_add_simple "dude" "^Dude!$" 40 "%VAR{sweet}" "en"
bMotion_plugin_add_simple "sweet" "^Sweet!$" 40 "%VAR{dude}" "en"
bMotion_plugin_add_simple "asl-catch" {[0-9]+%slash[mf]%slash.+} 75 "%VAR{greetings}" "en"
bMotion_plugin_add_simple "sing-catch" {^#.+#$} 40 [list "no singing%colen" "shh%colen"] "en"
bMotion_plugin_add_simple "seven" {^7[?!.]?$} 40 [list "7!" "7 %VAR{smiles}" "wh%REPEAT{3:7:e} 7!"] "en"
bMotion_plugin_add_simple "mmm" "mmm+ $botnicks" 25 "%VAR{smiles}" "en"
bMotion_plugin_add_simple "no-mirc" "mirc" 5 [list "mIRC < irssi" "use irssi" "mmm irssi" "irssi > *" "/fires %% into the sun"] "en"
bMotion_plugin_add_simple "no-bitchx" "bitchx" 5 [list "bitchx < irssi" "use irssi" "mmm irssi" "irssi > *" "/fires %% into the sun"] "en"
bMotion_plugin_add_simple "no-trillian" "trillian" 5 [list "trillian < irssi" "use trillian + bitlbee" "mmm irssi" "irssi > *" "/fires %% into the sun"] "en"
bMotion_plugin_add_simple "right" "%botnicks: (i see|ri+ght|ok|all? ?right|whatever)" 60 [list "it's true %VAR{unsmiles}" "it's true%colen" "yes" "what" "you don't believe me?"] "en"
bMotion_plugin_add_simple "hal" "%botnicks: open the cargo bay doors?" 70 [list "I'm sorry %%, I can't do that."] "en"
bMotion_plugin_add_simple "only4" {^only [0-9]+} 80 [list "well actually %NUMBER{100}" "that's quite a lot" "that's not very many" "well that's usually enough to get me functioning"] "en"
bMotion_plugin_add_simple "team" "there'?s no \[\"'\]?i\[\"'\]? in \[\"'\]?team\[\"'\]?" 80 [list "But there is a U in cunt"] "en"
bMotion_plugin_add_simple "luck" "wish me (good )?luck" 90 { "Luck!" "good luck!" "bad luck!%|no wait, good luck!" "i hope it doesn't explode" "%NUMBER{100}%percent good luck" "Luck you say? ... hmm, it's possible. I can have that with you in 6-8 weeks" "/looks for falling star in order to make luck based wish" } "en"
bMotion_plugin_add_simple "coffee1" "coffee ? < ?" 90 [list "what" "%VAR{unsmiles}" "%VAR{kills}" "/%VAR{smacks} %%" "traitor!" "you li%REPEAT{1:5:e}!%|YOU LI%REPEAT{4:10:E}%REPEAT{3:5:!}%colen"] "en"
bMotion_plugin_add_simple "coffee2" "\[a-z0-9\]+ ?> ?coffee" 90 [list "what" "%VAR{unsmiles}" "%VAR{kills}" "/%VAR{smacks} %%" "traitor!" "you li%REPEAT{1:5:e}!%|YOU LI%REPEAT{4:10:E}%REPEAT{3:5:!}%colen"] "en"
bMotion_plugin_add_simple "coffee3" "coffee (is |=+ )?(teh |the )?(suck|rubbish|fail|horrible|horrid)" 90 [list "what" "%VAR{unsmiles}" "%VAR{kills}" "/%VAR{smacks} %%" "traitor!" "you li%REPEAT{1:5:e}!%|YOU LI%REPEAT{4:10:E}%REPEAT{3:5:!}%colen"] "en"
bMotion_plugin_add_simple "lolcats" "i can has " 60 [list "no you fucking can't%|not until you learn to use english right, anyway" "what" "i can has grammar plz" "i has a bucket%|I have placed it over your stupid head." "no you fucking can't" "shut up" "everyone look at %%, they're up to date on all internet memes!%|for example, <%%> all your base are belong to us%|fantastic."] "en"

bMotion_plugin_add_simple "centipedes" {[a-z]+\? in my [a-z]+\?} 70 [list "it's more likely than you think"] "en"
bMotion_plugin_add_simple "cilit" "they're a challenge" 80 [list "but not... for Cilit Bang!"] "en"
bMotion_plugin_add_simple "cunt" "^(cunt|twat|bollocks)" 80 [list "cunt" "twat" "bollocks" "bastards" "idiot" "wanker" "%VAR{prom_first}" "pile of %VAR{prom_first}" "%VAR{prom_first}ing %VAR{prom_first}ers"] "en"

bMotion_plugin_add_simple "likea-catch" "i do love a good (.+)" 40 [list "me too %VAR{smiles}" "same!" ] "en"
bMotion_plugin_add_simple "secretcatch" "(secret|sekrit)" 40 [list "we all know %ruser likes to %VAR{dVerbs} themselves with a %VAR{dNouns} %VAR{smiles}" "it was %ruser!" "%VAR{ididntresponses}" ] "en"
bMotion_plugin_add_simple "andthan-catch" "and( then| than)" 10 [list "and then a %VAR{animals} came" "and then a bear came" "and then my %VAR{bodypart} %VAR{fellOffs}" "and thaaan?"] "en"
bMotion_plugin_add_simple "choose" "choose (.+)" 30 [list "Choose Life." "Choose a job." "Choose a career." "Choose a family." "Choose a fucking big television" "choose washing machines" "choose cars" "choose compact disc players" "choose electrical tin openers" "Choose good health" "choose low cholesterol" "choose dental insurance" "choose fixed interest mortage repayments" "Choose a starter home." "Choose your friends." "Choose leisurewear and matching luggage." "Choose a three-piece suite on hire purchase in a range of fucking fabrics." "Choose DIY and wondering who the fuck you are on a Sunday morning." "Choose sitting on that couch watching mind-numbing, spirit-crushing game shows, stuffing fucking junk food into your mouth." "Choose rotting away at the end of it all, pishing your last in a miserable home, nothing more than an embarrassment to the selfish, fucked up brats you spawned to replace yourself." ] "en"
bMotion_plugin_add_simple "the-r" "^r$" 30 [list "%VAR{theRs}" ] "en"
bMotion_plugin_add_simple "answerR" "\\mr %botnicks" 50 [list "%VAR{greetings}" "%VAR{theRs}" ] "en"
bMotion_plugin_add_simple "lookrobot" "(look robot|look,? robot|%botnicks look|look,? %botnicks)" 100 [list "I've seen it before, it's rubbish" ":o" "omg" "^_^" ] "en"
bMotion_plugin_add_simple "inokunfu" "(i know kungfu|i know kung fu)" 100 [list "Show me%|hmh.. your style is un-impressive" "Show me%|hmh.. your style is impressive" ] "en"

bMotion_plugin_add_simple "cartman1" "not (every|all) of them" 40 [list "no, but most of them are%|and all it takes is most of them..."] "en"

bMotion_plugin_add_simple "nicecar1" {^nice [^ ]+[a-rt-z]!?$} 40 [list "wanna show me what it can do?"] "en"
bMotion_plugin_add_simple "nicecar2" {^nice [^ ]+s!?$} 40 [list "wanna show me what they can do?"] "en"

bMotion_plugin_add_simple "luggage" "^\[0-9\]{5}$" 40 [list "amazing, that's the same combination as my luggage!"] "en"

bMotion_plugin_add_simple "letme1" "(%botnicks.? let me know when)|(let me know when.? %botnicks)" 100 [list "r" "will do" "sure" "np" "ok"] "en"
bMotion_plugin_add_simple "energydrink" "^!energy(drink)?" 100 [list "%VAR{energydrink}"] "en"
