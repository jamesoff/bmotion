# Responses
# $Id$
#
###############################################################################
# bMotion - an 'AI' TCL script for eggdrops

# Copyright (C) James Michael Seward 2000-2002
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by

# the Free Software Foundation; either version 2 of the License, or 
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but 
# WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU 
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License 
# along with this program; if not, write to the Free Software 
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
###############################################################################

set randomsVersion {$Id$}

set fellOffs {
  "fell off"
  "exploded"
  "imploded"
  "caught fire"
  "got eaten"
  "turned into %noun"
  "got discontinued"
  "ran out"
  "ran off"
  "expired"
  "bounced off"
  "collapsed"
  "split into component atoms"
  "got sat on by a fat person"
  "get turned in to %VAR{sillyThings}"
}

set jokeends {
  "Confucious say, %VAR{confuciousStart} %VAR{confuciousEnd}"
}

set confuciousStart {
  "man who walk through turnstile sideways"
  "man with hand in pocket"
  "passionate kiss, like spider web,"
  "girl who sits in judge's lap"
  "boy who go to sleep with hard problem"
  "man who drop watch in toilet"
  "man who jump off cliff"
}

set confuciousEnds {
  "going to Bangkok."
  "feel cocky all day."
  "lead to undoing of fly"
  "get honourable discharge"
  "wake up with solution in hand"
  "keep shitty time"
  "jump to conslusion"
}


bMotion_abstract_register "ranjoins"

bMotion_abstract_register "bigranjoins"

bMotion_abstract_register "lols"

bMotion_abstract_register "smiles"
bMotion_abstract_register "unsmiles"
bMotion_abstract_register "frightens"
bMotion_abstract_register "thanks"
bMotion_abstract_register "mingreplies"

bMotion_abstract_register "greetings"
bMotion_abstract_register "welcomes"
bMotion_abstract_register "sorryoks"
bMotion_abstract_register "loveresponses"
bMotion_abstract_register "blindings"

bMotion_abstract_register "boreds"

bMotion_abstract_register "rarrs"

bMotion_abstract_register "upyourbums"

bMotion_abstract_register "hides"

bMotion_abstract_register "kills"

bMotion_abstract_register "makeItSos"
bMotion_abstract_register "balefired"

bMotion_abstract_register "moos"

bMotion_abstract_register "insultsupermarket"

bMotion_abstract_register "aiis"

bMotion_abstract_register "sillyThings"
bMotion_abstract_register "randomStuff"

bMotion_abstract_register "hellos"

bMotion_abstract_register "goAways"
bMotion_abstract_register "randomStuffFemale"

bMotion_abstract_register "randomStuffMale"

bMotion_abstract_register "wahey"

bMotion_abstract_register "pullsOut"
bMotion_abstract_register "ers"
bMotion_abstract_register "noneOfYourBusiness"
bMotion_abstract_register "ruins"
bMotion_abstract_register "smokes"
bMotion_abstract_register "stonedRandomStuff"
bMotion_abstract_register "stonedAnnounce"
bMotion_abstract_register "goDowns"

bMotion_abstract_register "stupidReplies"
bMotion_abstract_register "nos"
bMotion_abstract_register "yeses"
bMotion_abstract_register "ididntresponses"
bMotion_abstract_register "shocked"
bMotion_abstract_register "randomAways"
bMotion_abstract_register "silences"

set stolens {
  "Hey NO :(%|That's mine%|/sulks at %%"
  "heeeeyyyy%|:("
  "bah%|/steals it back"
  "/smacks %%"
  "hey no, that's *MINE*"
  "nnk"
}

set fuckOffs {
  "Not now, I'm not in the mood for him"
  "SILENCE%colen"
  "Bite my shiny metal ass"
  "fuck off yourself"
  "go fuck yourself %%"
}

set silenceAways {
  "bah"
  "/goes to find someone more interesting to talk to"
  ":("
  "fine"
  "/stamps foot%|*sulk*"
  "/talks to %ruser instead"
  "hai!"
  "nnk"
}

set lovesits {
  "/loves it"
  "stop making me horny"
  "~oof~"
  "~rarr~"
  "har har"
  "i love it when you do that :D"
  "ooh more, more! MORE!"
  "%REPEAT{3:10:m}"
}

set chocolates {
  "mars bar"
  "bounty bar"
  "malteaser"
  "toblerone"
  "polo"
  "cadbury's dairy milk"
  "twix"
  "toffee crisp"
  "crunchie"
  "%OWNER{%rbot} chocolate orange"
  "Yorkie - it's not for girls"
  "smarties"
  "cadburys buttons"
  "edible panties"
}

set hiddenBehinds {
  "heeeeyyyy"
  "oi"
  "hey, watch it"
  "watch where you're putting your hands :P"
  "/hides behind %%"
  "/runs for it"
  "/makes a break for it"
  "I say, look over there%|/runs"
  "/smacks %%"
  "Shame I'm transparent today really"
}

set satOns {
  "hey ow :("
  "heeeyyy :O"
  "bah"
  "arrrrgh"
  "erk"
  "gerrof!"
  "NNK"
}

#question answers
set answerWhats {
  "a book"
  "3 fingers"
  "cycling"
  "I can't tell you that!"
  "a joint"
  "coffee!"
  "pizza"
  "french fries of course!"
  "talking"
  "a TV"
  "nothing%|/looks shifty."
  "some string"
  "a floppy disk"
  "warm"
  "cold"
  "a CD"
  "mp3!"
  "the Lord of the Rings"
  "the One Ring"
  "a monitor"
  "a snowboard"
  "a wall"
  "a processor"
  "cheese"
  "rainbows"
  "kittens"
  "%noun"
}

set answerWhos {
  "%ruser"
  "me"
  "you"
  "Domilijn"
  "Joost"
  "Bill Gates"
  "damo"
  "monica"
  "jms"
  "Britney Spears"
  "Colen"
  "the Kazon"
  "the cast of Dallas"
  "Ling Xiaoyu"
  "Hwoarang"
  "Bob Monkhouse"
  "Dale Winton"
  "Anna Kournikova"
  "Holly Valence"
  "Harold from Neighbours"
  "Jade of Big Brother"
  "Davina McCall"
  "Tony Blair"
  "Graham Norton"
  "the editor of The Sun"
  "Tim"
  "Brian"
  "who do you think?"
}

set answerWithWhos {
  "%ruser"
  "me"
  "you"
  "Domilijn"
  "Joost"
  "Bill Gates"
  "damo"
  "monica"
  "jms"
  "Britney Spears"
  "Colen"
  "the Kazon"
  "the cast of Dallas"
  "anyone, i'm easy"
  "at least 3 females"
  "Ling Xiaoyu"
  "everyone!"
  "Bob Monkhouse"
  "Dale Winton"
  "Anna Kournikova"
  "Holly Valence"
  "Harold from Neighbours"
  "Jade of Big Brother"
  "Davina McCall"
  "Tony Blair"
  "Graham Norton"
  "the editor of The Sun"
  "Tim"
  "Brian"
  "at least three men"
  "probably at least 3 pr0n DVDs"
}

set answerWhys {
  "why not?"
  "hmm?"
  "because i said so"
  "don't look at me, i thought YOU were responsible for that"
  "sunspots"
  "aliens"
  "too hot"
  "i think %ruser knows..."
  "beats working"
}

set answerWheres {
  "in bed"
  "behind the fridge"
  "on the desk"
  "in a book"
  "Devon"
  "Amsterdam"
  "a cheese shop"
  "Exeter"
  "America"
  "Mars"
  "the USS Enterprise"
  "north pole"
  "in a field"
  "under a book"
  "on top of the telly"
  "in the toilet"
  "Chippenham"
  "London"
  "New York"
  "%OWNER{%ruser} house"
  "hidden."
  "in the coffee pot"
  "down the local shop"
  "in the car"
  "at the shops"
  "over thair%|*point*"
  "next to %ruser"
  "in bed with Madonna"
}
set answerWellbeing {
    "fine thanks"
    "much better now"
    "not now, I'm 'busy'. mmmmmm."
    "so much better now I've got %VAR{sillyThings}"
    "oh the pain, the pain, the....I'm fine thanks"
    "I'm not bad thanks, how're you?"
}
set answerWhens {
  "this morning"
  "this afternoon"
  "now!"
  "this evening"
  "yesterday"
  "tomorrow"
  "today"
  "in 10 minutes"
  "4:32"
  "7:53"
  "9:21"
  "16:08"
}

set answerHowmanys {
  "42"
  "5"
  "34975"
  "ninety-five"
  "minus 6"
  "6"
  "342"
  "pi"
  "e"
  "i"
  "38"
  "0"
  "none"
  "22"
  "%NUMBER{1000}"
}

set answerHows {
  "magic"
  "pull harder"
  "give it a push"
  "climb on top and try again"
  "more lubricant"
  "think happy thoughts!"
  "using the power of greyskull"
  "try twisting"
  "teamwork"
  "drugs. Gotta be drugs."
  "drop an anvil on it"
  "industrial light and magic"
  "drink volvic first, then try"
}

set phaserFires {
  "/fires several shots from the forward phaser banks, disabling %%"
  "/fires several shots from the forward phaser banks, destroying %%%|/flies out through the explosion in an impressive bit of piloting (not to mention rendering :)"
  "/accidentally activates the wrong system and replicates a small tree"
  "/misses a gear and stalls%|Oops%|%bot\[50,¬VAR{ruins}\]"
  "/uses attack pattern alpha, spiralling towards %%, firing all phaser banks%|* %% is blown to pieces as %me flies off into the middle distance"
  "/anchors %% to a small asteriod, paints a target on their upper hull, and fires a full phaser blast at them"
  "/rolls over, flying over %% upside down, firing the dorsal phaser arrays on the way past"
  "/flies around %%, firing the ventral arrays"
  "/jumps to high impulse past %% and fires the aft phaser banks"
  "System failure: TA/T/TS could not interface with phaser command processor (ODN failure)"
  "/pulls the Picard move (the non-uniform one)"
}

set torpedoFires {
  "/fires a volley of torpedos at %%"
  "/breaks into a roll and fires torpedos from dorsal and ventral launchers in sequence"
  "/breaks into a roll and ties itself in a knot%|Damn.%|%bot\[50,¬VAR{ruins}\]"
  "System failure: TSC error"
  "/flies past %% and fires a full spread of torpedos from the aft launchers"
  "/heads directly for %%, firing a full spread of torpedos from the forward lauchers%|/flies out through the wreakage"
}

set everythingFires {
  "/opens the cargo hold and ejects some plastic drums at %%"
  "/lauches all the escape pods"
  "/fires the Universe Gun(tm) at %%"
  "/launches some torpedos and fires all phasers"
  "/shoots a little stick with a flag reading 'BANG' on it out from the forward torpedo launchers"
  "/lobs General Darian at %%"
}

set trekNouns {
  "Neelix"
  "Captain Janeway"
  "Deputy Wall Licker 97th Class Splock"
  "the USS Enterspace"
  "the USS Enterprise"
  "the USS Voyager"
  "a class M planet"
  "a class Y planet"
  "the holodeck"
  "Deanna Troi"
  "Tasha Yar"
  "Lt Cmdr Tuvok"
  "a shuttle"
  "the phaser bank"
  "several female Maquis crewmembers"
  "the entire male crew"
  "the entire female crew"
  "the entire crew"
  "the Kazon"
  "a PADD"
  "the FLT processor"
  "the Crystalline Entity(tm)"
  "a Targ"
  "a proton"
  "a Black Hole"
  "Dr Crusher"
  "the EMH"
  "the Borg"
  "Deep Space 9"
}

set charges {
  "exploding %%"
  "setting fire to %%"
  "gross incompetence"
  "teaching the replicators to make decaffinated beverages"
  "existing"
  "misuse of %%"
  "improper use of %%"
  "improper conduct with %%"
  "plotting with %%"
  "doing warp 5 in a 3 zone"
  "phase-shifting %%"
  "having sex on %%"
  "having sex with %%"
  "attempting to replicate %%"
  "terraforming %%"
  "putting %% into suspended animation"
  "writing a character development episode"
  "timetravelling without a safety net"
}

set punishments {
  "talk to Neelix for 5 hours"
  "be keel-dragged through an asteriod field"
  "play chess against 7 of 9 (you may leave as soon as you win)"
  "degauss the entire viewscreen with a toothpick"
  "be Neelix's food taster for a day"
  "have your holodeck priviledges removed for a week"
  "listen to Harry Kim practice the clarinet"
  "polish Captain Picard's head"
  "polish the EMH's head"
  "lick %% clean"
  "watch that really bad warp 10 episode of Voyager. Twice"
  "listen to an album by Olivia Newton-John"
  "explain quantum physics to Jade"
  "carry out a level 1 diagonstic single handed"
  "find Geordi a date"
}

set brigBanzais {
  "The %% Being In Brig Bet!"
  "The Naughty %% Charge Conundrum!"
  "%%'s Prison Poser!"
}

set banzaiMidBets {
  "bet bet bet!"
  "bet now! Time running out!"
  "come on, bet!"
  "what you waiting for? bet now!"
  "you want friends to laugh at you? Bet!"
}

set wands {
  "/waves %hisher <notopic>magic wand</notopic>"
  "Go go gadget magic wand!"
}

set harhars {
  "har har"
  "h4w."
  "h4w"
  "This victory strengthens the soul of %me!"
  "<canadian>Yeah, I am perfect!</canadian>"
  "/<-- winnar"
  "I am the greatest!"
}

set analsexhelps {
  "/hands %% the KY jelly"
  "/watches"
  "/offers to help"
  "~rarr~"
  "*wank*"
  "/lubes %% up"
  "/lubes %pronoun up"
}

set wankhelps {
  "/helps %%"
  "~rarr~"
  "~oof~"
  "/watches"
  "/perves"
}

set niceTrys {
  "Nice try."
  "You wish."
  "Stop trying to break me or I'll break you."
  "00h! j00r try1n9 t0 h4X0r m3h!%|/ph33rs"
}


set awwws {
  "awww"
  "awww%|poor %%"
  "awww%|/kisses it better"
  "awww%|/rubs %% better"
}

set randomReplies {
  "%ruser"
  "Orange."
  "about half-past three, I think"
  "yes"
  "no"
  "maybe"
  "medium-rare"
  "no thanks, i already have some"
  "woah cool, let me try that!"
  "sorry no, I'm still sore from last time"
  "eh?"
  "what?"
  "yellow, and sometimes blue"
  "I like edam best of all"
  "perhaps"
  "I didn't like it before"
  "someone set up us the bomb"
  "we get signal"
  "nothing"
  "panties%|%BOT\[¬VAR{rarrs}\]"
  "moist knickers%|%BOT\[¬VAR{rarrs}\]"
  "what do you think?"
  "i can't tell you that"
  "it wasn't me"
  "exeter"
  "amsterdam"
  "you should ask Domilijn :)"
  "i'd rather not"
  "not particularly, no"
  "last night, yes"
  "i'll consider that"
  "do you really want to know that?"
  "i am not at liberty to discuss that"
  "only with spud"
  "why the hell not"
  "only if there are no alternatives"
  "what a silly question *giggle*"
  "only on Wednesdays"
  "42"
  "a tv"
  "purple dildos"
  "shopping"
  "sailing"
  "coffee"
  "lots and lots of tea"
  "french fries of course!"
  "not without lubricant"
  "only with you %%"
  "only with %ruser"
  "no."
  "yes."
  "yes, but only on sundays and selected bank holidays"
  "yes, but only on the third wednesday of every month"
  "over there"
  "crap"
  "yes, that makes me horny"
  "yes, but only at the weekend"
  "no, never, not me"
  "you wish"
  "lemmie go look that up"
  "brb - library"
  "i'll need to look that one up %%"
  "i wish i knew"
  "have you tried google?"
  "www.google.com"
  "wtf are you asking me for?"
  "www.aj.com"
  "ask jeeves, he is smarter than the average %me"
  "cabbages"
  "penguins"
  "sometimes"
  "perhaps"
  "only with wizwoz"
  "only with %ruser"
  "sunday"
  "tuesday"
  "no, but it does make me horny"
  "no, that doesn't make me horny"
  "can i phone a friend?"
  "can i have 50:50?"
  "can i ask the audience?"
  "what do you think this is? Who Wants to be a Millionaire"
  "only when you win the lottery"
  "ask someone else"
  "have you asked chabby?"
  "69%|would i lie?"
  "69"
  "i know i know, but i have to be paid in pies"
  "if i tell you, i will have to kill you"
  "you want the answer? you can't handle the answer!"
  "you want the truth? you can't handle the truth!"
  "if i just reach in here%|*squelch*%|then the answer will be on this little bit of card"
  "let me consult a fortune cookie"
  "let me check your horoscope"
  "i'm not psychic"
  "omg yes"
  "omg no"
  "i might know"
  "i'll tell ya later"
  "only with fruit"
  "take one little step left"
  "who knows"
  "i might answer, one day"
  "death comes to those who wait"
  "what is your favourite colour?"
  "can i check?"
  "i might"
  "one day"
  "green%|No! Blue!"
  "a shrub"
  "a bush"
  "a shrubbery"
  "that depends. Who's asking?"
  "the answer lies in the stars%|bugger off there and find it"
  "%rbot knows"
  "If only I hadn't used up all my lifelines%|%bot\[50,you can have one of mine\]%|no thanks, don't know where it's been"
}

bMotion_abstract_register "feelings"
set feelings {
  "ok thanks"
  "fine"
  "all good"
  "pretty good"
  "bon"
  "okay"
  "not bad"
  "been worse"
  "been better"
  "friskier than a rabbit in springtime"
  "minging"
  "positively jade-like"
  "like John's mum on a Thursday night"
}
bMotion_abstract_batchadd "feelings" $feelings
unset feelings

bMotion_abstract_register "blownAways"
#set blownAways {
#  "/is blown off feet by force of %%'s statement%|%bot[50,¬VAR{picksUp}]"
#  "/falls over%|%bot[50,¬VAR{picksUp}]"
#  "/is blown away by force of %%'s statement%|%bot[50,¬VAR{picksUp}]"
#  "ow my eyes :("
#  "/blinks"
#  ":O"
#  "o_O"
#  ":o"
#  "blimey"
#  "crumbs"
#  "i say"
#  "lordy"
#}
#bMotion_abstract_batchadd "blownAways" $blownAways

set picksUp {
  "/picks up %%"
  "/helps %% back off the ground"

}

set dildoFlutePlays {
  "this one time at band camp...%|well, i'll show you...%|/puts the flute in herself"
  "this one time, at band camp, i put a flute in my pussy%|/demonstrates"
  "/puts the flute in herself%|we did this at band camp one year, too"
}

set dildoFluteFinishes {
  "/rescues her flute and plays a happy tune"
  "hey %%, want to play it? :P"
  "and that's why I liked band camp :)"
}

# %% = who, %2 = dildo
set dildoPlays {
  "/sits herself down and shows %% how she uses a %2"
  "/lubes up and shows %% how pleased she is with her new present :D"
}

# %% = dildo, %2 = who
set dildoFinishes {
  "/pulls out the %% and shoves it in %2's face%|you want some? :D"
  "~oof~ ... much better :)"
}

set dildoFemaleFemale {
  "/would do some girl-on-girl action here on %%, but needs to know how :P%|KatieStar! ;)"
}

set dildoFemaleFemaleSwap {
  "ok, i hope you're done cos it's my turn now :)%|/has her turn with the %%"
  "my turn my turn my turn!%|/swipes the %%"
}

set dildoMaleFemale {
  "*weg*%|/applies the %2 to %%"
  "ooh you are norty%|/makes %% horny with the %2"
  "i didn't realise you were in the mood for that%|*weg*%|/uses the %2 on %%"
  "cor you are randy%|/sticks the %2 up %%"
  "do you want me to help you eat that or help you sit on it?"
  "hmm, and where do you expect me to put *that*?"
  "/uses the %2 on %%"
  "/abuses %% with the %2"
  "/stretches %% with the %2"
}

set dildoMaleMale {
  "/would do some man-on-man action here on %%, but needs to know how :P%|hmm... who can I ask? :)"
}

set dildoMaleMaleSwap {
  "ok, i hope you're done cos it's my turn now :)%|/has his turn with the %%"
}

set dildoMalePlays {
  "/'plays' with the %2"
  "/replicates himself some lube"
}

set handcoffees {
  "/hands %% a coffee"
  "wake up%colen"
  "go to bed already"
  "sorry, are we <notopic>keeping you up</notopic>?"
  "you need a coffee"
  "/throws water over %% to wake them up"
  "/lends %% a pillow"
  "/lends %% a cushion"
}

set parkedinsDislike {
  "heyyy"
  "hey OW"
  "%colen"
  "that's not very nice"
  "ha, it's mine now!"
  "hey, i don't like that"
  "/disapproves of that sort of thing."
}

set secondDildoPlays {
  "/makes use of the additional %%%|%bot[50,sheesh]"
  "/locates another hole for the %%%|%bot[50,sheesh]"
  "thanks, but i don't have a free hand... could you put that one in for me?"
  "woah cool!%|/gets some more lube%|%bot[50,sheesh]"
}

set thrownAts {
  "wh%REPEAT{4:10:e}!"
  "I can seeee myyy house from heeeerrreeeeee!"
  "*CRUMP*"
  "/flattens %%"
  "hey :("
  "oi"
  "/sails through the air towards %%"
  "loookkk ooouuuttt beellooww!%|*CRUMP*%|ow :("
  "/flies through the air with the greatest of ease"
}

set bookmarks {
  "%VAR{smiles}"
}

set punchlines {
  "but it's legal if it's HER dog."
  "because penguins can't dance."
  "look if you don't know where it is put your tongue away."
  "you'll never be half the man your mother was!"
  "so THAT'S where I put the watermelon!"
  "2 in the front 2 in the back"
  "a military coo"
  "big holes all over Australia"
  "that's not my dog!"
  "depends if you're in Texas"
  "she only shaved the front!"
}

set typoFix {
  "oops"
  "oops %SETTING{output:typos:typos:_:_}"
  "%colen"
  "ffs"
  "grrr %SETTING{output:typos:typos:_:_}"
  "%SETTING{output:typos:typos:_:_}"
}

#set locations {
#  "England"
#  "US"
#  "california"
#  "indiana"
#  "the moon"
#  "australia"
#  "holland"
#  "norway"
#  "bosnia"
#  "russia"
#  "canada"
#  "toronto"
#  "amsterdam"
#  "mars"
#  "exeter"
#  "london"
#  "new york"
#  "basingstoke"
#}

bMotion_abstract_register "locations"
#bMotion_abstract_batchadd "locations" $locations

bMotion_abstract_register "hugs"
set hugs {
  "*hugs %%*"
  "/huggles %%"
  "/snuggles %%"
  "*snuggles %%*"
  "/huggles with %%"
  "/squeezes %%"
}
bMotion_abstract_batchadd "hugs" $hugs

set blehs {
  "bleh"
  "feh"
  "meh"
}

set huks {
  "huk"
  "kek"
  "tilde"
  "~"
}

set yesnos {
  "%VAR{yeses}"
  "%VAR{nos}"
}

set rehashes {
  "Done."
  "ryoukai"
  "hai"
  "Rehash complete"
  "shiage desu"
  "rehash klaar"
  "okie"
}

set bodypart {
  "foot"
  "arm"
  "head"
  "ear"
  "nose"
  "nostril"
  "eyeball"
  "fingernail"
  "clothes"
}

set dude {
  "Dude!"
  "My god dude!"
  "Duuuuuuuuuuuuuuuuuude!"
}

set sweet {
  "Sweet!"
  "Schweet!"
  "Sweeeeeeeeeet!"
}

set units {
  "inches"
  "miles"
  "feet"
  "sq inches"
  "litres"
  "meters"
  "picas"
  "gigainches"
  "kilomiles"
  "acres"
  "cubits"
  "ultramiles"
  "Roman paces"
  "miles an hour"
  "times the speed of light"
  "kph"
  "meters per second"
  "years"
  "AUs"
}

set oops {
  "oops"
  "whoops"
  "d'oh"
  "doh"
  "huk"
  "heh"
}
bMotion_abstract_register "smacks"
bMotion_abstract_register "hexStart"
bMotion_abstract_register "hexMiddle"
bMotion_abstract_register "hexEnd"

## autogenerated
bMotion_abstract_register "randomZimness"
bMotion_abstract_batchadd "randomZimness" [list "yes, my tallest!" "how can you have an operation impending doom 2 without me?" "doom. doooom." "shouldn't you be frying something?" "but sir, we're still on our own planet" "invader blood runs through my veins like giant radioactive rubber pants... the pants command me! do not ignore my veins!" "silence!" "pitiful human" "Gir... help me... there isn't much time!" "MADNESS%colen" "have you the brain worms?" "you won't make a fool of this Irken invader" "I'll just have to wait for the skin to grow back on my eyeballs" "ow... my spine" "mwahahahahahahahahahaha" 	"you lie... YOU LIEEEEEEE%colen" "squealing fools%colen" "we will begin by testing your absorbancy." "invaders need no one... NO ONE%colen" "victory for %me%colen" "nothing will stand in my way... not even drool!" "so... much... filth!" "prepare yourselves for destruction" "aaah, the stink of clean" "another win for the Irkin Empire... clean lemony fresh victory is mine." "i'm not giving up... i'll destroy you%colen" "you! burger lord! how is this meat so clean... so pure?!" "inferior human organs!" "ow! my squealyspooch!" "say, you're full of organs aren't you? and you wouldn't notice if you were missing a few?" 	"evaluation: PATHETIC%colen" "surely that was no human bee!" "when the repairs are done i shall hunt down that evil death bee." "why am i so amazing?" "what is the meaning of this%colen" "there is no so worthy as %me%colen" "release the pig%colen" "this is no man pig" "don't come any closer or i will lay eggs in your stomach" "get away... you smell like feet%colen" "RIDE THE PIG%colen" "stupid silent glue boy" "i will annihilate you down to your every last cell" "i will be in my lab bathing in paste" "i will be... LORD OF ALL HUMANS%colen" 	"i will rule you all with an iron fist" "i will prepare food with my iron fist" "%%... obey my fist" "i am %me%colen" "take me to the meat" "i have a MIGHTY NEED to use the restroom" "LEAVE NO EVIDENCE%colen" "do not invoke the wrath of the Irken elite!" "stop snivelling little worm monkey" "now to release screaming temporal doom" "something is broken and it's not your fault?" "the very thought of it make me... makes... little... sicky noises" "i have a plan... an amazing plan" "FOOLS! i am %me!" "time for another amazing plan from me... %me!" 	"i have already stuffed my normal human belly with delicious human filth that i could not eat another bite" "ah! ah! THE MEAT!! THE HORRIBLE MEAT%colen" "meats of evil! meat of EVIL%colen" "is it a fair fight... is this moose weilding any projectile weapons?" "i told you that you would would rue the day when you messed with %me... now begin your rueing... i'll just sit here and watch." "dumb like a moose." "the dogs! they're after my meat body of juicy bologna meats." "be quiet" "why was there bacon in the soap?" "i will call you... pusstulio" "come my filthy stink children" "you will open your eyes... you have to breathe sometime" "he is part of the collective now" "please buy my candies or my little brother will go insane" "they've locked down their fortress... with locks" 	"release me! release me or suffer the wrath of %me" "who *are* you people" "rise up and use your revolting limbs to escape this prison" "nothing can stop %me... nothing! not even this army of zombies!" "silence... my victory begins now%colen" "more power... give me MORE POWER%colen" "prepare to meet your horrible doom" "with my mighty fists of horror, and unstoppable cruelty, i am the tool of destruction, vengeance and fury" "are we going to have trouble, soldier?" "behold the fortress of pain" "soon they'll all be after my delicious guts" "i have had enough of your smelly mouth filled with corn" "as soon as my skeleton stops being broken i will destroy you" "when will the lies end?!" "wave of doom" 	"%%, you man the tractor beam, i'll pump the cows full of human sewage" "sometimes i'm afraid to find out what goes on in that insane head of yours" "you dare tell me what i already know?!?!?!" "curse you snacks... CURSE YOU%colen" "delicious DELICIOUS... I AM NORMAL%colen" "i'm in a bear suit" "DESTRUCTION IS NICE%colen" "the taste of human annihilation grows stronger in my amazing head" "people of earth! prepare to meet the mighty foot of my planet" "well... yes... i'm an unstoppable death machine" ]
bMotion_abstract_batchadd "randomZimness" [list "i congratulate you in recognising my superiority and choosing me to be your love pig!" "your magical love adventure begins now" "now cry... CRY like you've never cried...... before" "you're after my robot bee%colen" "yes yes... i'm a master of comedy, now what's this plan" "don't touch anything or i'll melt your face off or something" "hey! hey! HEY! hey over here, my tallest! my tallest! my taaaaaalllesst!" "I was curious to see when you'd shut up on your own... but it's been three hours now, %ruser... THREE HOURS%colen" "oh, I know all kinds of things about you... pretty creepy, huh?" "hey, someone's making doughnuts!" "The latest plan is about to explode!" "but his voice fills me with a terrible rage!" "processing... PROCESSING%colen" "SON! THERE BETTER NOT BE ANY WALKING DEAD UP THERE!" "call them, and tell them we're going to blow them up!" "ALERT! Something is happening at the front door! Something... horrible!" "you're nothing, earth-boy! go home and shave your giant head of smell with your bad self!" "activate the shrinky self-destruct!" "you dare insult the pants of %me%colen" "get off of me! you smell like human!" "%%... analysis: moron!" "%%... analysis: annoying!" "as president, I will ensure that all mankind HAS ITS LEGS SAWN OFF .... and replaced with legs of PURE GOLD!" "%%: Debate.. now! OR SUFFER!" "only now can I reveal that, if elected, I will ensure that every student is given a zombie wiener-dog to do their bidding. Can %% say that?" "the grotesque monster-boy avoids the issues! just what does he plan on doing about the size of %OWNER{%ruser} giant head? If I am elected, %OWNER{%%} head will be removed, and filled with salted nuts!" "the child shrieks like a fruitbat!" "well, time to work on my next evil plan." "the giant flesh-eating demon squid has escaped! security! protect your master! GIR! Defensive mode!" "ah yes... uh... %%! and how is the happiness probe in your brain doing today, FILTHY HUMAN?" "stay right there... we're sending someone over to beat you up for playing jokes in the FBI!" "no more waffles, GIR. No really, I'm starting to feel sick. *retch*" "AARGH! The hideous mutant squid has escaped again and has created an army of cyborg zombie soldiers to do its evil bidding!" "your waffle-eating days are over, %%!" "Well, thankfully I was able to reprogram those cyborgs at the last minute, and send them off to do HORRIBLE THINGS to the humans." "GIR, your waffles have sickened me! FETCH ME THE BUCKET!"]


bMotion_abstract_register "hides"
bMotion_abstract_batchadd "hides" [list "/ducks" "/runs for the hills" "/legs it" "eek!%|/runs for it" "/hides behind %ruser" "/hides" "/duck-and-covers" "Don't be so silly." "Look over there!%|/runs" ]


bMotion_abstract_register "stonedAnnounce"
bMotion_abstract_batchadd "stonedAnnounce" [list "/is quite obviously stoned" "/is stoned" "/is caned" "/is delighted to announce i have achieved the status 'stoned'%|Now to go for very stoned" ]


bMotion_abstract_register "goDowns"
bMotion_abstract_batchadd "goDowns" [list "/goes down on %%" "/goes slowly down on %%" "/flops down on %%" "/pleasures %%" "/pleasures %% with %hisher tongue" ]


bMotion_abstract_register "bigranjoins"
bMotion_abstract_batchadd "bigranjoins" [list "bhar" "r." "r %%" "a%REPEAT{3:8:r}" "boohar %%" "boom" "BOOM%colen" "BOOM!" "alors bof" "pop" "%%%colen" "%%!" ]


bMotion_abstract_register "randomGirness"
bMotion_abstract_batchadd "randomGirness" [list "i don't know... weee hoo hoo hoo!" "I'm gonna sing the doom song now... dooom doom doom" "that's my favourite show" "whoooo I'm naked" "*sniff* I miss you cupcake" "dootie!" "wooo... I like destroying" "i had no idea." "*gasp* it's got chicken legs %VAR{smiles}" "i'm so happy %VAR{smiles}" "yes, my master." "leprechauns" "i'm making a cake" "yes... wait a minute... no." "doo dee doo dedo deee do" "i got chocolate bubblegum!" "hooray for earth!" "weee hehehehehehehehe" "let's go to my room, pig" "aw... somebody needs a hug %VAR{smiles}" "I like you %VAR{smiles}" "tacos" "where's my moose" "oooh... what's that do?" "do do do do do do do... do do do do do.... do doo do do do do do... do do do do do doooo" "i need tacos... i need them or i explode. that happens sometimes" "WHY! WHY my piggy, WHY?? I loved you my piggy... I loved you" "i know... i'm scared too" "wee... do that again" "let's make biscuits... LET'S MAKE BISCUITS" "stolen?" "i like TV" "aw... i wanted to explode" "I'm guarding the house" "thank you... i love you." "i had a coupon" "yes... i will stop... i will obey" "yay... i'm gonna be sick" "do you have any  taquitos?" "i had no idea" "i can still see you" "%REPEAT{4:7:eh}e chicken!! I'm gonna eat you!" "aw... you look so cute" "me and the squirrel are friends" "aw... your little robot toy is broken" "hi floor... make me a sandwich" "i gotta go pig... i'll see you later" "aw... it's broken" "you're on fire" "yay! brains!" "yay... it burns" "i don't wanna.... ok" "won't the exploding hurt?" "it's me! I was the turkey all along!" "i made mashed potatoes!" "i had a sandwich in my head" "so... about my sandwich..." "gue%REPEAT{2:7:s} who made waffles!"]


bMotion_abstract_register "hexMiddle"
bMotion_abstract_batchadd "hexMiddle" [list "Cheese Error" "FTB" "GBL" "+MELON+" "Octarine" "Sixth Dimension" "Teatime" "Phase Of Moon Generator" "Unreal Time Clock" "Anthill Inside" "Thaumic Disturbance" "Flux" "Influx" "Hive Interface" "Line 666" "Line %NUMBER{10000}" "Nether Realm" "Conjuring" "Octagram" "Archive Reference" "Enchantment" "Eternal Domain" "Paradox Shifting" "Here Comes The Cheese" "Ow" "%VAR{sillyThings}" ]


bMotion_abstract_register "tech_tries"
bMotion_abstract_batchadd "tech_tries" [list "sacrificing my boss" "reinstalling it" "going to a voodoo witch doctor" "covering it in honey" "putting the CD in the other way up" "putting the CD in the floppy drive" "smearing it with mud" "running it on my Mac" "rebooting" ]


bMotion_abstract_register "goodlucks"
bMotion_abstract_batchadd "goodlucks" [list "GL" "good luck :)" "good luck" ]


bMotion_abstract_register "goAways"
bMotion_abstract_batchadd "goAways" [list "go away" "piss off" "shut up" "get lost" "..." "make like a banana" ]


bMotion_abstract_register "smacks"
bMotion_abstract_batchadd "smacks" [list "smacks" "cuff" "hits" "pats" "slaps" "socks" "spanks" "chops" "clouts" "punches" "annihilates" "annuls" "axes" "butchers" "crusesh" "damages" "defaces" "eradicates" "erases" "exterminates" "extinguishes" "gust" "impairs" "kills" "lays waste" "levels" "liquidates" "maims" "mutilates" "nukes" "nullifies" "quashes" "quells" "ravages" "ravishes" "razes" "ruins" "sabotages" "shatters" "slays" "smashes" "snuffs out" "stamps out" "suppresses" "torpedoes" "trashes" "wastes" "wipes out" "wrecks" "zaps" ]


bMotion_abstract_register "ranjoins"
bMotion_abstract_batchadd "ranjoins" [list "hey %%" "hi %%" "hi there %%" "hi yo~" "Good Morning %%" "%% you're looking especially shagworthy today" ]


bMotion_abstract_register "smiles"
bMotion_abstract_batchadd "smiles" [list ":)" ";)" "=)" "=]" "=D" "^_^" "-_-" ]


bMotion_abstract_register "thanks"
bMotion_abstract_batchadd "thanks" [list "cheers" "ta" "thanks" "merki" "a thousand thankyous" "thx" "tanks" "thankie" "thansk" "praise be to you" ]


bMotion_abstract_register "stupidReplies"
bMotion_abstract_batchadd "stupidReplies" [list "I may be stupid, but you're minging, and I can learn new things :)" "At least I'm not minging." "Minger." "You do better in 6911 lines of TCL :P" "You know, I think you say that just to hide the fact that you're not the sharpest tool in the box either." "*hands over ears* lalalalala I can't hear you..." "I'm only code, what's your excuse?" "Silence!" "I only have 1s and 0s.  You don't seem to be doing so hot with the rest of the numbers" "I'm made of SAND! I think I'm doing bloody well." "You see how you do after 2 years on IRC with no sleep" "You say that now. Wait till I'm in Mensa." "You're so thick even Densa rejected you." "Yes Jade. Absolutely." ]


bMotion_abstract_register "moose"
bMotion_abstract_batchadd "moose" [list "yarr" "pop" "jum" "zort" ]


bMotion_abstract_register "get_fact_intros"
bMotion_abstract_batchadd "get_fact_intros" [list "I think I heard that" "last time I knew," "it could be that" "ok, I'll tell you that" "well, don't tell anyone, but......." "last time I knew," ]


bMotion_abstract_register "rarrs"
bMotion_abstract_batchadd "rarrs" [list "~rarr~" "~oof~" "uNf" "*uNf" "*squeaky*" "*boing*" "%REPEAT{3:8:bl}" "*spangle*" "~oef~" ]


bMotion_abstract_register "sorryoks"
bMotion_abstract_batchadd "sorryoks" [list "ok" "that's ok" "alright then" "i forgive you" "/spanks %%%|%BOT\[¬VAR{rarrs}\]" "That's ok then. I suppose. Don't think this makes me like you again though" ]


bMotion_abstract_register "loveresponses"
bMotion_abstract_batchadd "loveresponses" [list "awww thanks" "i love you too" "i wuv you too" "and i love you" "and i wuv you" "aww wuv you too" "awww *giggle*" "i love you just as much" "i want to have your babies" "/blushes" "hehe thanks" "you know, I've always loved you the most" ]


bMotion_abstract_register "hugs"
bMotion_abstract_batchadd "hugs" [list "*hugs %%*" "/huggles %%" "/snuggles %%" "*snuggles %%*" "/huggles with %%" "/squeezes %%" ]


bMotion_abstract_register "upyourbums"
bMotion_abstract_batchadd "upyourbums" [list "up your bum." "up yer bum" "up yer cavernous arse" "up ya bum" "up my bum :P" "hold on, i'll check%%|not up my bum :P" "hold on, i'll check%|not up your bum :P" "is it up your bum?" "have you checked your bum yet?" "down the shops." "Turkey." "on a tube train." "on a bus." "halfway up big ben." "toilet." "bathroom." "up my nose." "in a field" "hiding in the long grass" "hidden." "%PICKUSER\[female\]%|down %OWNER{%ruser} clevage%|%PICKBOT\[male\]%|%bot{50,i'll get it!}" ]


bMotion_abstract_register "tech_answer"
bMotion_abstract_batchadd "tech_answer" [list "I just bought %VAR{tech_software} and I can't get it to %VAR{tech_problem}, I've tried %VAR{tech_tries} and it still won't work" "I've just got %VAR{tech_software}, and it won't %VAR{tech_problem}. I've tried everything including %VAR{tech_tries} but nothing helps" "I hear you do books by %VAR{answerWhos}, can you sell me one?" "I need a bit of software to %VAR{tech_functions} %VAR{sillyThings}" ]


bMotion_abstract_register "prom_first"
bMotion_abstract_batchadd "prom_first" [list "piss" "shit" "fuck" "turd" "minge" "crap" "vadge" "shat" "clit" "cack" "arse" "cum" "wank" "flid" ]


bMotion_abstract_register "silences"
bMotion_abstract_batchadd "silences" [list "Be quiet" "Enough" "Silence!" "%colen" "no more!" "NNK" ]


bMotion_abstract_register "hexEnd"
bMotion_abstract_batchadd "hexEnd" [list "Disabled+++" "Occurance+++" "Portal Opening+++" "Detected+++" ": Reinstall Syrup+++" "snack break+++" "-(Why Not Take This Time To Register Your Purchase)+++" "=Error %REPEAT{3:6:%NUMBER{100}}+++" "%REPEAT{3:12:?}+++" "Warning : Excess %VAR{sillyThings}" "Data Lost+++" ": Redo From Start+++" "- Please Reboot Universe+++" "Aknowledgment+++" "Ended+++" 	"-If Problem Persists Contact The Creator+++" "-Could Not Complete Destiny+++" "-no sufficient sentient life forms+++" "Technological Change+++" "-Access Completely And Indefinitely Denied+++" "-Query+++" "+++" "Waaaaah!+++" "Divide By Cucumber Error+++" ": Error - Division By Moonlight+++" ]


bMotion_abstract_register "randomDootie"
bMotion_abstract_batchadd "randomDootie" [list "dootie %VAR{smiles}" "doootie dootie dooootie dootie" "i like dootie" "ooooooooooOOOOOooooo dootie" "weee hoo hooo hooo! dootie" "dooo-tie. dooo-tie. dooo-tie. dooo-tie. dooo-tie" "dootie is my friend" "you said dootie %VAR{smiles}" ]


bMotion_abstract_register "prom_second"
bMotion_abstract_batchadd "prom_second" [list "rifle" "flower" "desk" "curtain" "wheel" "door" "coin" "speaker" "lamp" "radio" "twix" "action" "account" "pump" "puma" "whistle" "shaver" "glass" "flute" "tea" "pot" "square" "robe" "apple" "cave" "lantern" "drawer" "card" "pants" ]


bMotion_abstract_register "ididntresponses"
bMotion_abstract_batchadd "ididntresponses" [list "no, *I* didn't" "Oh really." "Yes you did. We all saw it." "Of course you didn't." "Oh yes you did." "You must think us all fools." "nnk" ]


bMotion_abstract_register "aiis"
bMotion_abstract_batchadd "aiis" [list "wikkid" "aii" "aiiiii" "innit" "respect" "westsyde%|/snaps wrist Ali G-stylee." "true" "keepin' it real" "iz wikkid" "wikkid stylin' of da wikkid!" "/is hangin with his crew" "Respect ma blingbling" "kickin it down with da home boy posse" "That is so last week" ]


bMotion_abstract_register "randomStuffFemale"
bMotion_abstract_batchadd "randomStuffFemale" [list "This one time, at band camp, I put a flute..." "Does my arse look big in this?" "Does my bum look big in this?" "*ping*%|Did it just get cold in here?" "Do you know how we keep warm in Russia?%|... we play chess." "I kinda like thongs" "I wonder what happens when I put that in here...%|oooooooh!" "/plays with herself" "That ain't my belly button" "This one time, at band camp, I put %noun..." "/considers breast implants%|%PICKUSER\[female\]%|%BOT\[¬PICKUSER\[female\]¬|/feels up ¬¬ to check¬|true, they aren't as good as ¬ruser's¬|/feels up ¬ruser's breasts¬|mmmm ¬VAR{smiles}\]" "/considers sexchange operation%|%PICKUSER\[male\]%|/looks at %ruser%|Maybe not" "%PICKUSER\[female\]%|It's good to be female isn't it %ruser" ]


bMotion_abstract_register "PROM"
bMotion_abstract_batchadd "PROM" [list "%VAR{prom_first}-%VAR{prom_second}" ]


bMotion_abstract_register "blindings"
bMotion_abstract_batchadd "blindings" [list "h%REPEAT{5:10:n}" "blinding" "h%REPEAT{5:10:n} blinding" ]


bMotion_abstract_register "ers"
bMotion_abstract_batchadd "ers" [list "er" "erm" "umm" "um" ]


bMotion_abstract_register "goodnights"
bMotion_abstract_batchadd "goodnights" [list "night" "nn" "night %%" "sleep well" "goodnight :)" "night :)" "g'night" "sleep well %%" "nn %%" "don't have really bad dreams about a nasty man coming to strangle you in your bed" ]


bMotion_abstract_register "afro_1"
bMotion_abstract_batchadd "afro_1" [list "1000" "1001" "1002" "1003" "1004" "1005" "1006" "1007" "1008" "1009" "1010" "1011" "1012" "1013" "1014" "1015" "1016" "1017" "1018" "1019" "1020" "1021" "1022" "1023" "1024" "1025" "1026" "1027" "1028" "1029" "1030" "1031" "1032" "1033" "1034" "1035" "1036" "1037" "1038" "1039" "1040" "1041" "1042" "1043" "1044" "1045" "1046" "1047" "1048" "1049" "1050" "1051" "1052" "1053" "1054" "1055" "1056" "1057" "1058" "1059" "1060" "1061" "1062" "1063" "1064" "1065" "1066" "1067" "1068" "1069" "1070" "1071" "1072" "1073" "1074" "1075" "1076" "1077" "1078" "1079" "1080" "1081" "1082" "1083" "1084" "1085" "1086" "1087" "1088" "1089" "1090" "1091" "1092" "1093" "1094" "1095" "1096" "1097" "1098" "1099" ]


bMotion_abstract_register "makeItSos"
bMotion_abstract_batchadd "makeItSos" [list "/makes it so" "/goes to warp" "/fires phasers" "/replicates some coffee" "/jumps to warp" "/sets fire to %%" "/launches a volley of photon torpedos" "/launches a volley of quantum torpedos" ]


bMotion_abstract_register "french1"
bMotion_abstract_batchadd "french1" [list "est-ce que je peut" "je prend" "je vais au" "ou sont les toilettes" "on m'a" "je vais manger" "bounjour" ]


bMotion_abstract_register "french2"
bMotion_abstract_batchadd "french2" [list "ouvir la fenetre" "une douche" "manger" "baiser-vous plus vite" "un velo" "une lesbienne" ]


bMotion_abstract_register "french3"
bMotion_abstract_batchadd "french3" [list "a dix heures" "dans la salle de bains" "sur la bus 264" "dans la collection noir" "une vie sexuelle" "ma tete" "ma fesse" "les chapeaux" ]


bMotion_abstract_register "afro_A"
bMotion_abstract_batchadd "afro_A" [list "aardvark" "arse" "arrange" "american" "a" "at" "anthony" "aboot" "alright" "all" "another" "archer" "anna" "and" "andrews" "albert" "amy" "anabolic" "athena" "arnold" "adu" "alice" "animals" "amalia" "assassinated" "aces" "al" "alberts" "andy" "asymmetric" "ashton" "armstrong" "africa" "ames" "age" "albania" "allen" "am" "arc" "aint" "affairs" "annabel" "applejacks" "air" "athens" "aerial" "arabia" "around" "atlanta" "anthophobia" "archaeologists" "america" "allegro" "alley" "adams" "armored" "as" "aioli" "asquith" "alphanumeric" "adagio" "avon" "atlantic" "augustus" ]


bMotion_abstract_register "afro_B"
bMotion_abstract_batchadd "afro_B" [list "balloon" "breasts" "beethoven" "because" "back" "bing" "blues" "belinda" "bills" "batman" "borromeo" "barrett" "barkier" "brewer" "banshees" 	"blindness" "breath" "bud" "be" "boy" "bellini" "bees" "bayreuth" "baht" "brazil" "birnham" "beans" "backdraft" "brook" "benton" 	"brinkley" "bull" "brian" "bruce" "bernard" "b" "bill" "beelzebub" "britain" "bonnie" "brothers" "brigitte" "bardot" "breed" "blind" 	"ballet" "belgium" "beau" "bridges" "bag" "band" "barrymore" "billion" "black" "bronze" "boston" "blue" "brewery" "bird" "bryan" 	"big" "bang" "brenda" "bee" "bow" ]


bMotion_abstract_register "afro_C"
bMotion_abstract_batchadd "afro_C" [list "cheese" "cow" "cock" "chicken" "cup" "cupcake" "cubism" "charity" "collins" "cappuccino" "capote" "cobb" "california" "canadian" "carl" 	"cocks" "cool" "country" "crosby" "carla" "club" "child" "charles" "cairo" "copenhagen" "coming" "cardiff" "christmas" "change" "collector" 	"could" "candy" "chris" "cat" "coin" "chicago" "calories" "churchill" "crocodiles" "couldn" "care" "cirrus" "connery" "corporal" "cant" 	"cooper" "cities" "communist" "chrissie" "chamberlain" "casablanca" "champs" "cadillacs" "copper" "cincinnati" "chihuahua" "cougar" "come" "composer" "castrato" 	"cobol" "charlie" "calcium" "cognac" "curve" "calico" "century" "capsicum" "close" "cemetary" "caesar" ]


bMotion_abstract_register "afro_D"
bMotion_abstract_batchadd "afro_D" [list "dog" "dick" "doughnuts" "donkey" "dinner" "diner" "day" "diane" "dion" "de" "douglas" "don" "deborah" "dingaan" "dayne" 	"days" "down" "duckling" "david" "deburgh" "denver" "disney" "dorothy" "disease" "dorsey" "drood" "die" "doris" "doubt" "dire" 	"dinah" "digital" "date" "decay" "daisy" "doctor" "dead" "duffel" "dmitri" "drew" "debbie" "dont" "dima" "dictionary" "daily" 	"dame" "desmond" "del" ]


bMotion_abstract_register "afro_E"
bMotion_abstract_batchadd "afro_E" [list "elephant" "enormous" "eggs" "electric" "easton" "emma" "enough" "end" "einstein" "england" "east" "eden" "europe" "etta" "edwin" 	"emerald" "ellison" "enterprise" "edutainment" "edelweiss" "eagles" "ethiopia" "everly" "entomology" "eighty" "ed" ]


bMotion_abstract_register "afro_F"
bMotion_abstract_batchadd "afro_F" [list "fish" "fudge" "fuck" "fsck" "fucking" "fridge" "forbidden" "feokistov" "fried" "fell" "ford" "flesh" "for" "field" "fixx" 	"family" "fox" "forward" "french" "fiji" "forest" "fab" "fireman" "four" "featuring" "fez" "frederick" "food" "foster" "figure" 	"fascinators" "fonda" "ferguson" "force" "finland" "fed" "fritz" ]


bMotion_abstract_register "afro_G"
bMotion_abstract_batchadd "afro_G" [list "goat" "green" "gang" "gong" "glass" "grapefruit" "glasses" "girls" "gandhi" "girl" "gonna" "gibson" "get" "grant" "gabrielle" 	"god" "golding" "gus" "grissom" "gyrocompass" "gabriel" "got" "glaucoma" "gardener" "gannets" "garfield" "grand" "great" "game" "goldblum" 	"gabor" "guitar" "goldie" "george" "grimm" "grooves" "gees" "good" "gets" "grania" "greyhound" "gary" "gate" ]


bMotion_abstract_register "afro_H"
bMotion_abstract_batchadd "afro_H" [list "hippo" "horny" "honk" "hooters" "hardness" "hopkins" "hudson" "harrison" "hypodermic" "home" "holly" "horse" "heathrow" "hercules" "haricot" 	"hard" "huston" "helen" "hynde" "house" "haley" "hurt" "high" "hotel" "houston" "his" "hands" "harmless" "hates" "hollis" 	"here" "hecubus" "hume" "hermaphrodite" "hawn" "hawaii" "have" "henley" "harmony" "hunchback" "hitches" "hollies" "harden" "heart" "hercule" ]


bMotion_abstract_register "afro_I"
bMotion_abstract_batchadd "afro_I" [list "igloo" "iceage" "is" "intelligent" "idiot" "ivan" "immediately" "i" "in" "it" "if" "israel" "international" "iphigenia" "ii" 	"india" "iraq" "illumination" "infinity" "inch" "infectious" "ives" ]


bMotion_abstract_register "afro_J"
bMotion_abstract_batchadd "afro_J" [list "jam" "jump" "jumper" "jealous" "juice" "japan" "just" "jody" "jeffrey" "julie" "janis" "joplin" "jr" "joffrey" "james" 	"john" "jackie" "jingles" "jets" "joan" "jeeves" "johnny" "jazz" "joe" "jeff" "jaffas" "january" "jodie" "jailers" ]


bMotion_abstract_register "afro_K"
bMotion_abstract_batchadd "afro_K" [list "kite" "kinky" "keaton" "kool" "kept" "kaiser" "kerr" "keating" "kura" "knutsford" "kolya" "king" "kalifornia" "kirstie" "karis" 	"kennedy" "kilby" "knockout" "kings" ]


bMotion_abstract_register "afro_L"
bMotion_abstract_batchadd "afro_L" [list "llama" "lemon" "lift" "long" "lovely" "lendl" "light" "libra" "luyts" "limestone" "lulu" "land" "lira" "london" "lauren" 	"leave" "lyman" "leo" "libya" "less" "last" "lords" "laforge" "lieutenant" "landscape" "love" "loud" "lee" "line" "laughing" 	"louis" "leiber" "low" "lebanon" "lawrence" "lucy" "liu" "lizard" "little" "lupoid" "lion" "llewelyn" "litres" "los" ]


bMotion_abstract_register "afro_M"
bMotion_abstract_batchadd "afro_M" [list "moose" "moo" "ming" "mouth" "minerals" "monks" "mcwhirter" "michael" "michelangelo" "make" "more" "mark" "mars" "maeko" "medicine" 	"man" "monticello" "musik" "mendelevium" "malone" "mononoke" "mail" "mystery" "meg" "my" "michelle" "mooning" "must" "mechanophobia" "mostly" 	"max" "magnum" "me" "mandela" "megara" "mesa" "mankind" "mrs" "miller" "musical" "majors" "malaga" "meredith" "mercutio" "mata" 	"manhattan" "mathis" "mountain" "music" "mittens" "mchales" "million" "madonna" "moody" ]


bMotion_abstract_register "afro_N"
bMotion_abstract_batchadd "afro_N" [list "noodle" "noise" "nice" "nerd" "new" "niro" "napoleon" "needle" "nepotism" "nod" "nelson" "noises" "now" "norman" "northern" 	"no" "nine" "nails" "non" "night" "notre" "navy" "neap" ]


bMotion_abstract_register "afro_O"
bMotion_abstract_batchadd "afro_O" [list "orange" "opium" "optional" "ormand" "of" "orchestra" "or" "oldest" "oklahoma" "ophthalmophobia" "organisation" "organ" "o" "ox" "ochlophobia" 	"out" "optophobia" "own" "oysters" "oz" "orlons" "one" "oscar" "olaf" "ogee" ]


bMotion_abstract_register "afro_P"
bMotion_abstract_batchadd "afro_P" [list "peas" "parents" "pornography" "pies" "planet" "peter" "pan" "people" "poles" "profession" "pop" "phnom" "penh" "porno" "pyros" 	"parisienne" "pfeiffer" "paul" "pomegranate" "pia" "poisoning" "prodigy" "pie" "paprika" "potsdam" "point" "picasso" "parrish" "pretenders" "polydor" 	"pickle" "pisces" "palme" "peterson" "poirot" ]


bMotion_abstract_register "afro_Q"
bMotion_abstract_batchadd "afro_Q" [list "quote" "quickly" "quick" "queensland" "quadruple" ]


bMotion_abstract_register "afro_R"
bMotion_abstract_batchadd "afro_R" [list "rhubarb" "rubbing" "rhombus" "races" "robert" "reynolds" "rona" "rose" "racing" "ronan" "road" "rhythm" "ryan" "ralph" "radiation" 	"richard" "rain" "r" "rambutan" "roosevelt" "romania" "rhapsody" "riyal" "russia" "race" "return" "ray" "rob" "roy" "ridge" 	"radar" "romeo" "really" "rudolph" "rescuers" "rio" "ren" ]


bMotion_abstract_register "afro_S"
bMotion_abstract_batchadd "afro_S" [list "sushi" "suck" "something" "seaside" "startrek" "sweet" "shirelles" "shlomo" "saturn" "sheena" "southern" "spider" "scream" "spectacles" "sandusky" 	"sweat" "supremes" "snert" "street" "sting" "st" "stop" "santa" "siouxsie" "steroids" "seven" "sheats" "scouts" "subaru" "scorpio" 	"skylab" "seventeen" "space" "surgery" "sharon" "stone" "sly" "sean" "salem" "standards" "sox" "siderophobia" "salt" "setzer" "straits" 	"slating" "stomach" "subscriber" "sides" "steve" "stephen" "sir" "sphere" "spandau" "shoe" "sea" "scrolls" "supply" "still" "sappers" 	"scotophobia" "services" "sigourney" "stripper" "sydney" "steptoe" "south" "sand" "savage" "spain" "six" "star" "seattle" "she" "sits" 	"stand" "so" "stevie" ]


bMotion_abstract_register "afro_T"
bMotion_abstract_batchadd "afro_T" [list "teapot" "toss" "timothy" "the" "theresa" "tom" "truman" "ten" "train" "tiffany" "tension" "thompson" "tip" "toe" "thru" 	"tulips" "thomas" "than" "teresa" "til" "taylor" "three" "tirana" "ties" "taiwan" "turn" "time" "ta" "trials" "touch" 	"this" "that" "then" "thumb" "tyler" "tooth" "thelma" "tallulah" "theodore" "tex" "taco" "traffic" "territory" "tail" "tickle" 	"tone" "testicles" "taifa" "telekinesis" "turkey" "tommy" "troop" "tarika" "task" "troppo" "team" "topaz" "their" "turkiye" "tides" 	"tart" "tenderloin" "tea" "to" ]


bMotion_abstract_register "afro_U"
bMotion_abstract_batchadd "afro_U" [list "undone" "upsidedown" "uber" "u" "under" "upside" "uraguay" "uterus" "usa" "up" "uniform" ]


bMotion_abstract_register "afro_V"
bMotion_abstract_batchadd "afro_V" [list "violet" "veal" "very" "village" "visual" "vincenzo" "van" ]


bMotion_abstract_register "afro_W"
bMotion_abstract_batchadd "afro_W" [list "wiggle" "wobble" "wank" "willemstad" "with" "was" "wedloe" "wilton" "winston" "white" "walt" "wood" "wheat" "who" "witch" 	"woman" "when" "we" "without" "wilson" "willis" "washington" "williams" "woody" "wedding" "walrus" "words" "war" "weaver" "wild" 	"wyoming" "west" "wizard" "welcome" "wife" "w" "wow" ]


bMotion_abstract_register "wahey"
bMotion_abstract_batchadd "wahey" [list "wahey!" "wahey" "WAHEY" "wahey%colen" ]


bMotion_abstract_register "afro_X"
bMotion_abstract_batchadd "afro_X" [list "xray" "xrated" "xylophone" "x" ]


bMotion_abstract_register "afro_Y"
bMotion_abstract_batchadd "afro_Y" [list "yellow" "yank" "you" "yourself" "your" ]


bMotion_abstract_register "afro_Z"
bMotion_abstract_batchadd "afro_Z" [list "zebra" "zeus" "zadora" "zsa" ]


bMotion_abstract_register "boreds"
bMotion_abstract_batchadd "boreds" [list "aww%|/hugs %%" "/tickles %%" "cheer up %%%|*hugs*" "/feels %%" "/spanks %%" "I'll get the body paint... :P" ]


bMotion_abstract_register "moos"
bMotion_abstract_batchadd "moos" [list "moo" "MOO!" "/moos quietly" "/moos back to %%" "M%REPEAT{2:8:o}%REPEAT{2:8:O}%REPEAT{2:8:0}%REPEAT{2:8:o}%REPEAT{2:8:0}%REPEAT{2:8:o}!" "ahhh moo" "moo?" "/goes moo" "quack" "woof" "baa" "oink" "You mooing at me?" "MOo" "Moooooooweeeeeeeeeehahahahahahahahahaa" 	"MOO" "moo..." "mo...o" "moo%colen" ]


bMotion_abstract_register "insultsupermarket"
bMotion_abstract_batchadd "insultsupermarket" [list "eek, not %%" "%% mings" "watch your language :)" "Clearly you are a mingbeast of the highest order and should only ever shop at Tesco to redeem yourself." "You know, everyone you hate shops at %%" "I once found a live student in %%" "You know, they sell recycled food at %%" "They had a vote for the mingingest place on earth. It was won by %%" ]


bMotion_abstract_register "awayWorks"
bMotion_abstract_batchadd "awayWorks" [list "hf %%" "have fun %%" "have a nice day %% :)" ]


bMotion_abstract_register "frightens"
bMotion_abstract_batchadd "frightens" [list "eek!%|%bot\[50,¬VAR{awwws}\]" "o_O" "erk" "bah" "oh no b-" "crikey%|%bot\[50,¬VAR{awwws}\]" "blimey%|%bot\[50,¬VAR{awwws}\]" "gosh" "crumbs%|%bot\[50,¬VAR{awwws}\]" "yof" "ohmigod!" ]


bMotion_abstract_register "blinding"
bMotion_abstract_batchadd "blinding" [list ]


bMotion_abstract_register "autoAways"
bMotion_abstract_batchadd "autoAways" [list "oh, so we're not interesting enough?%|%bot\[50,obviously not\]" "o, bye then" "bored? fine, we'll have fun without you ;)" "bored? fine, we'll have fun without you ;)%|%bot\[50,¬VAR{rarrs}\]" "fine, leave your computer, see if i care" "damnit! I WAS TALKING TO YOU!" "yea, go away, you don't care" "auto away my arse" "Great! Time to talk behind your back!%|So what do you guys really think about %%" ]


bMotion_abstract_register "tech_functions"
bMotion_abstract_batchadd "tech_functions" [list "virus-scan" "validate" "manage" "install" "clean" "update" "audit" ]


bMotion_abstract_register "sucks"
bMotion_abstract_batchadd "sucks" [list "%% = %VAR{PROM}" ]


bMotion_abstract_register "yeses"
bMotion_abstract_batchadd "yeses" [list "Yes." "yes" "yes." "mais oui" "oui" "but of course" "hai" "ja" "absolutement" "yup" "and you don't even have lots of forms to fill in" ]


bMotion_abstract_register "sillyThings"
bMotion_abstract_batchadd "sillyThings" [list "12 year old black metal kids" "14 US dollars" "1.5 pie" "20 minutes till lunch" "5 litres of Halfords 10W-40" "5 pints" "99 bicycle clips" "a 12-inch pianist" "a 1.44MB floppy disk" "a 1979 Aston Martin" "a 7MB Flash movie" "AA" "a backup" "a badger" "a bag" 	"a bagette" "a bank" "a barbecue" "a bath" "a baton" "a bazooka" "a beach" "a beard" "a beast" "a bed" "Aberystwyth" "a better computer" "a big stick with nails in it" "a bike" "a bird" 	"a biscuit tin" "a blanket" "a bloke" "a bog wallness" "a boiler" "a boob" "a book" "a bookshelf" "a bookstore" "a boot" "a bot" "a bottle" "a bottom" "a box" "a boy" 	"a branch" "a brick" "a bridge" "a broken CD case" "a brother" "a brownie" "a bucket" "a budget" "a building" "a bullet" "a bunker" "a bus" "a business" "a button" "a cab" 	"a camara" "a camera" "a candidate" "a can of coke" "a can of diet coke (bleh)" "a capital" "a Cappucino" "a captain" "a car" "a car park" "a carrot" "a cartoon" "a case" "a cassette" "a cassette deck" 	"a cat" "a catflap" "a cd wallet" "a ceiling" "a cellar" "a certain" "a chain" "a champion" "a channel" "a chat" "a chatterbot" "a cheque" "a choir" "a Christian" "a chum" 	"a cinema" "a circus" "a client" "a clock" "a clothes peg" "a clown" "a coffee pot" "a company" "a compiler" "a complete central heating system" ]


bMotion_abstract_register "blownAways"
bMotion_abstract_batchadd "blownAways" [list "/is blown off feet by force of %%'s statement%|%bot\[50,¬VAR{picksUp}\]" "/falls over%|%bot\[50,¬VAR{picksUp}\]" "/is blown away by force of %%'s statement%|%bot\[50,¬VAR{picksUp}\]" "ow my eyes :(" "/blinks" ":O" "o_O" ":o" "blimey" "crumbs" "i say" "lordy" ]


bMotion_abstract_register "shocked"
bMotion_abstract_batchadd "shocked" [list "!" "!!!" "crikey" "blimey" "crumbs" "yikes" "wow" "boom" "marmalade" ":O" ":o" "ooh 'eck" "i say%|%BOT\[what do you say?\]%|I say, %VAR{ers}...%|%VAR{randomStuff}." "%colen" "O_O" 	"A%REPEAT{4:7:R}GH!" ]


bMotion_abstract_register "randomAways"
bMotion_abstract_batchadd "randomAways" [list "sex" "coffee" "food" "sleep" "campus" "town" "work" "working" "shopping" "gaming" "playing a game" "h4X0ring" "dvd" "watching a film" "brb" 	"around" "taking over the world" "I am the magic horse(£(£$&" "John's Mum" "sekrit" "auto-away" "code" "programming" "beer" "pub" "out" "*squeeky*" "tea" "fud" "bnar" 	"bibble" "fnar" "coffee machine ~rarr~" "tantric sex" "pornography" "porn" "divx" "manual-away" "McDonalds" "yo mamma" "%ruser" "cookie" "penguin" "toilet" "shower" 	"bath" "taking the guinea pig for a walk" "washing my hair" "removing my enemies from the timeline" ]


bMotion_abstract_register "smokes"
bMotion_abstract_batchadd "smokes" [list "/takes a drag" "/lights up" "/has a puff" "/smokes :)" "/partakes of herbal refreshment" ]


bMotion_abstract_register "mingreplies"
bMotion_abstract_batchadd "mingreplies" [list "not as much as you though" "yeah? well you ming more" "so? you're my role model" "oh no b-" "you bitch" "you suck like a dustbuster" ]


bMotion_abstract_register "nos"
bMotion_abstract_batchadd "nos" [list "no." "no" "No." "No" "certainly not" "don't be so silly" "nope" "negative" "nup" "nada" "nein" "no siree bob" "maybe where you come from" ]


bMotion_abstract_register "tech_software"
bMotion_abstract_batchadd "tech_software" [list "windows" "xml spy" "installshield" "notepad" "media player" "wise for windows" "goldmine" "gmClass" "vmware" "the internet" ]


bMotion_abstract_register "waveTooMuch"
bMotion_abstract_batchadd "waveTooMuch" [list "What." "Are you practicing to be the Queen or something?" "..." ]


bMotion_abstract_register "welcomes"
bMotion_abstract_batchadd "welcomes" [list "you're welcome" "no problem" "np" "no prob" "ok" "my pleasure" "any time" "only for you" "no biggie" "no worries" ]


bMotion_abstract_register "greetings"
bMotion_abstract_batchadd "greetings" [list "hey %%" "hi %%" "hey there %%" "how's it going %%" "* wave at %%" "yo %%" "y0 %%" "howdy %%" "hiya %%" "hi" "hey" "howdy" "hoi" "%VAR{jokeends}" "hi yo %%" ]


bMotion_abstract_register "FRENCH"
bMotion_abstract_batchadd "FRENCH" [list "%VAR{french1} %VAR{french2} %VAR{french3}" ]


bMotion_abstract_register "hellos"
bMotion_abstract_batchadd "hellos" [list "hello" "hey" "hi" ]


bMotion_abstract_register "cyas"
bMotion_abstract_batchadd "cyas" [list "l8r" "cya" "cya l8r" "bye" "byebye" "/waves" "you still here?" "quand vous retournez, apporter les tartes!" ]


bMotion_abstract_register "balefired"
bMotion_abstract_batchadd "balefired" [list "/vanishes from the continuum" "/ceases to have ever existed" "hey! :(" "/dodges%|/hits d+1 and does Chinese Fan on %%" ]


bMotion_abstract_register "randomStuff"
bMotion_abstract_batchadd "randomStuff" [list "I'm a doctor not %VAR{sillyThings}" "pika pika!" "pikachu!" "pika...CHUUUU!!! *ZZZAAP*" "*boing*" "moo." "BOOM" "BLAM" "Knickers.%|%BOT\[¬VAR{rarrs}\]" "/goes for coffee" "bof" "alors" "bhar" "arrrr.." "elbow." 	"gorilla" "*yawn*" "*spangle*" "brb" "lalalala.. ow! I stubbed my toe :(%|%bot\[50,¬VAR{awwws}\]" "lum de dum de dum..." "/twiddles thumbs" "boom" "Look over there!" "bleh" "/puts on some banging house tunes" "zut alors" "alors bof" "groogle arrhar" "brb, loo" 	"brb, sex" "uNF" "~rarr~" "~oof~" "Oops, I've ruined it." "Buttock Crunchies" "D'oh!" "setty mings lalalala" "pika" "Are you local?" "We'll have no trouble here" "Resistance is futile, you will be assimilated" "Resistance is futile, you will be 0wn3d" "Assimilation is futile, you will be resi... D'OH!" "I *didn't*" 	"waCHOO *sniff*%|%BOT\[¬VAR{blessyous}\]" "blblblblblbl" "/assimilates the channel" "We are the B0rg. You will be 4551m1la70r3d." "wheeeee" "We are the Borg. Lower your shields and surrender your ship." "h%REPEAT{3:8:n}" "did you see that.." "You are the weakest link, goodbye." "Computer, deactivate iguana." "kerPOW" "kerSPLAT" "KAZAM" "kazOO" "yaZOO" 	"spam, spam, spam, spam, spam, spam..." "Oh my god! There's an axe in my head.%|%BOT\[¬VAR{pullsOut}\]" "Mon dieu! Il y a une hache dans ma tete.%|%BOT\[¬VAR{pullsOut}\]" "ghay'cha'! nachwIjDaq betleH tu'lu'!%|%BOT\[¬VAR{pullsOut}\]" "Deus Meus! Securis in capite meo est.%|%BOT\[¬VAR{pullsOut}\]" "ALL YOUR BASE ARE BELONG TO US" "For great justice." "nostril" "%REPEAT{2:7:bl}" "wh%REPEAT{3:8:e}" "h%REPEAT{3:10:e} FUN" "ah bof" "I didn't!" "shh, sekrit" "SSSH SEKRIT" 	"SILENCE%colen" "pop" "cabbages" "penguin" "cheese" "mmm chicken" "blimey" "crikey" "hoorah" "pie pie pie pie" "fantastic" "ho ho" "har har" "deary me" "m00se" 	"llama" "frogs" "knickers" "bob" "kenneth" "nigel" "is everyone thooper?" "super" "thooper" "lashings of ginger beer" ]


bMotion_abstract_register "wrong_infoline"
bMotion_abstract_batchadd "wrong_infoline" [list "oops, wrong infoline, sorry" "huk, wrong infoline" "whoops" "o wait not that infoline" ]


bMotion_abstract_register "randomStuffMale"
bMotion_abstract_batchadd "randomStuffMale" [list "Yeah baby yeah!" "I don't know how that got in there. It's not mine." "I don't think there's enough room in here for me and my thingy%|/removes thingy and sits in the other room" "That ain't my finger" "%REPEAT{3:8:m} electronical things" "%REPEAT{3:6:m} internet" "%REPEAT{3:6:m} breasts" "%REPEAT{3:6:m} jugs" "/considers sexchange operation%|%PICKUSER\[female\]%|/looks at %ruser%|Maybe not" "%PICKUSER\[male\]%|It's good to be male isn't it %ruser" ]


bMotion_abstract_register "welcomeBacks"
bMotion_abstract_batchadd "welcomeBacks" [list "re" "wb" "welcome back" "hey" "hi" "%REPEAT{4:7:bl}" "pop" ]


bMotion_abstract_register "tech_problem"
bMotion_abstract_batchadd "tech_problem" [list "install" "work" "stop being purple" "stop rendering pictures of %VAR{sillyThings}" "connect to the network" "stop telling me 'you are too stupid to use this software'" "make the tea" "download pornography" "connect" ]


bMotion_abstract_register "lols"
bMotion_abstract_batchadd "lols" [list "lol" "cbsl" "hehe" "%REPEAT{2:5:ha}" "muwa%REPEAT{2:5:ha}" "heh" ":D" "rofl" "socl" "heheh" ":))" ":)" ]


bMotion_abstract_register "noneOfYourBusiness"
bMotion_abstract_batchadd "noneOfYourBusiness" [list "none of your business. shut up." "none of your business" "shut up" "you keep out of this" "it's sekrit" "Yes." "It's a secret." "I don't care." ]


bMotion_abstract_register "joinins"
bMotion_abstract_batchadd "joinins" [list "~rarr~" "~oof~" "ooh, can I come?" "can I join in?" "wahey-waterproof" ":)" "have fun ~rarr~" ]


bMotion_abstract_register "unsmiles"
bMotion_abstract_batchadd "unsmiles" [list ":(" ";(" ":O" ":\[" ":<" "=(" "=\[" "=O" "o_O" "T_T" ":~(" ]


bMotion_abstract_register "ruins"
bMotion_abstract_batchadd "ruins" [list "Incompetence." "INCOMPETENCE%colen" "YOU INCOMPETENT FOOL!" "You've ruined it." "That's torn it." ":P" "I spy incompetence." "Idiot." "heh" "\"great\"" "\"well done\"" "\"Good\" job." "\"Good\" work." "plonker" "you plonker" 	"fool" "taunt!" "cretin" "moron" "Jade!" ]


bMotion_abstract_register "hexStart"
bMotion_abstract_batchadd "hexStart" [list "+++Out Of" "+++Overley Terrifying" "+++Please Execute" "%REPEAT(1,4,+++MELON}+++" "+++Conflicting" "+++Current" "+++Load" "+++Incorrect" "+++Completed" "+++Undefined" "+++" "+++Missing" "+++Proceed to" "+++Magical" "+++Trying To Enable" 	"+++Good Morning:" "+++I WANT MY" "+++Summoning" "+++Unparalleled" "+++Insidious" "+++DANGER:" "+++System Error" "+++Arbitrary" "+++Random" "+++Insert" "+++Activating" ]


bMotion_abstract_register "attack_responses"
bMotion_abstract_batchadd "attack_responses" [list "%% attacks %SETTING{complex:attacks:who:_:_} with '%SETTING{complex:attacks:item:_:_}' for %SETTING{complex:attacks:score:_:_} damage." "%SETTING{complex:attacks:who:_:_} takes %SETTING{complex:attacks:score:_:_} damage from %OWNER{%%} '%SETTING{complex:attacks:item:_:_}'" "%SETTING{complex:attacks:who:_:_} is tremendously damaged by the %SETTING{complex:attacks:item:_:_} and takes %SETTING{complex:attacks:score:_:_} damage!" "MISS!" "%SETTING{complex:attacks:who:_:_} is immune to '%SETTING{complex:attacks:item:_:_}'" "%SETTING{complex:attacks:who:_:_} absorbs the damage and gains %SETTING{complex:attacks:score:_:_} HP!" ]


bMotion_abstract_register "randomZimNameChange"
bMotion_abstract_batchadd "randomZimNameChange" [list "master, where did you go? I can't see you" "master?" "where'd my moose go?" "we have no time for these games%colen" "watch out for the moose" ]


bMotion_abstract_register "locations"
bMotion_abstract_batchadd "locations" [list "England" "US" "california" "indiana" "the moon" "australia" "holland" "norway" "bosnia" "russia" "canada" "toronto" "amsterdam" "mars" "exeter" 	"london" "new york" "basingstoke" ]


bMotion_abstract_register "kills"
bMotion_abstract_batchadd "kills" [list "/stabs %%" "/phasers %%" "/nukes %%" "/kills %%" "/0wnz %%" "/destroys %%" "/plays S Club 7 singles at %%" "/pops %% with a knitting neadle" "/dices %%" "/shoots %%" "/eats %%" "/minces %%" "/slashes %%" "/chainsaws %%" "/farts on %%" 	"/uses the power of greyskull on %%" "/forces %% to shop at Budgens" ]


bMotion_abstract_register "insult_joins"
bMotion_abstract_batchadd "insult_joins" [list "%ruser: yeah, %% does suckOH HI %%!" "\[%%\] I'm a %VAR{PROM}%|%VAR{wrong_infoline}" "\[%%\] I love %ruser%|%VAR{wrong_infoline}" ]


bMotion_abstract_register "pullsOut"
bMotion_abstract_batchadd "pullsOut" [list "/pulls it out%|%bot\[50,¬VAR{wahey}\]" ]


bMotion_abstract_register "goodMornings"
bMotion_abstract_batchadd "goodMornings" [list "Morning %%" "good morning %%" ]


bMotion_abstract_register "stonedRandomStuff"
bMotion_abstract_batchadd "stonedRandomStuff" [list "wheeeeeeee" "wheeeee..." "hey... i sound really stoned..." "hey, my hands are huge... they can touch anything but themselves... oh, wait" "slap my ass and call me charlie" "I don't think I'm ever going to come down" "peace" "flower power rules" "Did you ever wonder about the rising situation in Eastern Europe" "Hey, my TCL is HUGE" "I love you all" "look at all those beautiful colours" "I have to be stoned to feel normal" "see the marmalade skies" ]

