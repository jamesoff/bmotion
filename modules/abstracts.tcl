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


  "/misses a gear and stalls%|Oops%|%bot[50,¬VAR{ruins}]"


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


  "/breaks into a roll and ties itself in a knot%|Damn.%|%bot[50,¬VAR{ruins}]"


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


  "panties%|%BOT[¬VAR{rarrs}]"


  "moist knickers%|%BOT[¬VAR{rarrs}]"


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


  "If only I hadn't used up all my lifelines%|%bot[50,you can have one of mine]%|no thanks, don't know where it's been"


}





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