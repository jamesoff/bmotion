#
#
# vim: fdm=indent fdn=1

#
# This is a bMotion plugin
# Copyright (c) 2007 Mark Sangster <znxster@gmail.com>
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
#
# This isn't true Scots, its more of a gibberish Scots, this is because it
# lacks the real grammar of the Scots tongue. Also I have mixed word from a
# variety of Scots dialects. However, the overall effect is fun and thats what
# bMotion is all aboot!
#


bMotion_plugin_add_output "scots" bMotion_plugin_output_scots 100 "en"

proc bMotion_plugin_output_scots { channel line } {
	bMotion_putloglev 4 * "bMotion_plugin_output_scots $channel $line"
	
	set newLine ""
	set line [string trim $line]
	set words [split $line " "]
	
	foreach word $words {
		# partials
		regsub -nocase "ing$" $word "in'" word

		# dual!
		regsub -nocase "^cookie|biscuit$" $word "bannock" word
		regsub -nocase "^correct|right$" $word "richt" word
		regsub -nocase "^dove|pigeon$" $word "doo" word
		regsub -nocase "^into|inside$" $word "intae" word
		regsub -nocase "^over|across$" $word "ower" word

		# multiple choices .. make a choice or?
		regsub -nocase "^child$" $word "bairn" word
		# child -> bairn / wain
		regsub -nocase "^nuisance$" $word "scunner" word
		# nuisance -> footer / scunner
		regsub -nocase "^one$" $word "ane" word
		# one -> ane / wan / yin

		# full
		regsub -nocase "^about$" $word "aboot" word
		regsub -nocase "^above$" $word "abuin" word
		regsub -nocase "^after$" $word "efter" word
		regsub -nocase "^against$" $word "agin" word
		regsub -nocase "^all$" $word "a'" word
		regsub -nocase "^along$" $word "yont" word
		regsub -nocase "^always$" $word "ayeweys" word
		regsub -nocase "^and$" $word "an" word
		regsub -nocase "^any$" $word "ony" word
		regsub -nocase "^armpit$" $word "oxter" word
		regsub -nocase "^away$" $word "awa'" word
		regsub -nocase "^awfully$" $word "awfu" word
		regsub -nocase "^bald$" $word "baw" word
		regsub -nocase "^beautiful$" $word "bonnie" word
		regsub -nocase "^beer$" $word "heavy" word
		regsub -nocase "^below$" $word "ablo" word
		regsub -nocase "^between$" $word "atweesh" word
		regsub -nocase "^boil$" $word "bile" word
		regsub -nocase "^bounce$" $word "stoat" word
		regsub -nocase "^boy$" $word "laddie" word
		regsub -nocase "^bump$" $word "dunt" word
		regsub -nocase "^came$" $word "cam" word
		regsub -nocase "^careful$" $word "canny" word
		regsub -nocase "^chat$" $word "blether" word
		regsub -nocase "^chimney$" $word "lum" word
		regsub -nocase "^church$" $word "kirk" word
		regsub -nocase "^clothes$" $word "claes" word
		regsub -nocase "^cold$" $word "cauld" word
		regsub -nocase "^commotion$" $word "stramash" word
		regsub -nocase "^complain$" $word "girn" word
		regsub -nocase "^could$" $word "cud" word
		regsub -nocase "^cow$" $word "coo" word
		regsub -nocase "^dead$" $word "deid" word
		regsub -nocase "^devil$" $word "de'il" word
		regsub -nocase "^dig$" $word "howk" word
		regsub -nocase "^down$" $word "doon" word
		regsub -nocase "^down$" $word "doun" word
		regsub -nocase "^do$" $word "dae" word
		regsub -nocase "^drain$" $word "stank" word
		regsub -nocase "^dusk$" $word "gloamin" word
		regsub -nocase "^endure$" $word "thole" word
		regsub -nocase "^every$" $word "ilka" word
		regsub -nocase "^eyes$" $word "een" word
		regsub -nocase "^father$" $word "faither" word
		regsub -nocase "^fool$" $word "gowk" word
		regsub -nocase "^for$" $word "fur" word
		regsub -nocase "^friend$" $word "frein" word
		regsub -nocase "^from$" $word "fae" word
		regsub -nocase "^fuss$" $word "palaver" word
		regsub -nocase "^girl$" $word "lassie" word
		regsub -nocase "^goin$" $word "gaun" word
		regsub -nocase "^good$" $word "guid" word
		regsub -nocase "^half$" $word "hauf" word
		regsub -nocase "^hang$" $word "hing" word
		regsub -nocase "^happy$" $word "cantie" word
		regsub -nocase "^have$" $word "huv" word
		regsub -nocase "^head" $word "heid" word
		regsub -nocase "^heart$" $word "hert" word
		regsub -nocase "^heated$" $word "het" word
		regsub -nocase "^hold$" $word "haud" word
		regsub -nocase "^home$" $word "hame" word
		regsub -nocase "^house$" $word "hoose" word
		regsub -nocase "^idiot$" $word "eejit" word
		regsub -nocase "^i'd$" $word "ah'd" word
		regsub -nocase "^i'll$" $word "ah'll" word
		regsub -nocase "^inn$" $word "howff" word
		regsub -nocase "^inside$" $word "ben" word
		regsub -nocase "^in$" $word "i'" word
		regsub -nocase "^i've$" $word "ah've" word
		regsub -nocase "^i$" $word "ah" word
		regsub -nocase "^just$" $word "juist" word
		regsub -nocase "^know$" $word "ken" word
		regsub -nocase "^lake$" $word "loch" word
		regsub -nocase "^long$" $word "lang" word
		regsub -nocase "^look$" $word "keek" word
		regsub -nocase "^many$" $word "mony" word
		regsub -nocase "^married$" $word "merrit" word
		regsub -nocase "^mire$" $word "glaur" word
		regsub -nocase "^more$" $word "mair" word
		regsub -nocase "^mother$" $word "mither" word
		regsub -nocase "^mountain$" $word "ben" word
		regsub -nocase "^mouse$" $word "moose" word
		regsub -nocase "^mouth$" $word "mooth" word
		regsub -nocase "^my$" $word "ma" word
		regsub -nocase "^never$" $word "ne'er" word
		regsub -nocase "^nonense$" $word "haver" word
		regsub -nocase "^not$" $word "no" word
		regsub -nocase "^no$" $word "nay" word
		regsub -nocase "^now$" $word "noo" word
		regsub -nocase "^off$" $word "aff" word
		regsub -nocase "^of$" $word "o'" word
		regsub -nocase "^old$" $word "auld" word
		regsub -nocase "^other$" $word "ither" word
		regsub -nocase "^our$" $word "oor" word
		regsub -nocase "^out$" $word "oot" word
		regsub -nocase "^own$" $word "ain" word
		regsub -nocase "^part$" $word "pairt" word
		regsub -nocase "^person$" $word "body" word
		regsub -nocase "^perverse$" $word "thrawn" word
		regsub -nocase "^potato$" $word "tattie" word
		regsub -nocase "^pound$" $word "pun" word
		regsub -nocase "^pretty$" $word "bonnie" word
		regsub -nocase "^quiet$" $word "wheesht" word
		regsub -nocase "^rather$" $word "gey" word
		regsub -nocase "^red$" $word "rid" word
		regsub -nocase "^round$" $word "roond" word
		regsub -nocase "^rubbish$" $word "midden" word
		regsub -nocase "^shake$" $word "shoogle" word
		regsub -nocase "^slope$" $word "brae" word
		regsub -nocase "^smack$" $word "skelp" word
		regsub -nocase "^small$" $word "wee" word
		regsub -nocase "^snow$" $word "snaw" word
		regsub -nocase "^somewhat$" $word "fair" word
		regsub -nocase "^sore$" $word "sair" word
		regsub -nocase "^so$" $word "sae" word
		regsub -nocase "^spin$" $word "burl" word
		regsub -nocase "^stone$" $word "stane" word
		regsub -nocase "^stream$" $word "burn" word
		regsub -nocase "^stupid$" $word "glaikit" word
		regsub -nocase "^take$" $word "tak" word
		regsub -nocase "^thrashin$" $word "laldy" word
		regsub -nocase "^through$" $word "throu" word
		regsub -nocase "^tiny$" $word "toty" word
		regsub -nocase "^town$" $word "toon" word
		regsub -nocase "^to$" $word "tae" word
		regsub -nocase "^trouble$" $word "trauchle" word
		regsub -nocase "^true$" $word "troo" word
		regsub -nocase "^turnip$" $word "neep" word
		regsub -nocase "^two$" $word "twa" word
		regsub -nocase "^under$" $word "unner" word
		regsub -nocase "^until$" $word "til" word
		regsub -nocase "^valley$" $word "glen" word
		regsub -nocase "^wall$" $word "dyke" word
		regsub -nocase "^wander$" $word "stravaig" word
		regsub -nocase "^wanted$" $word "socht" word
		regsub -nocase "^warm$" $word "wairm" word
		regsub -nocase "^was$" $word "wis" word
		regsub -nocase "^weep$" $word "greet" word
		regsub -nocase "^wet$" $word "dreich" word
		regsub -nocase "^what$" $word "whit" word
		regsub -nocase "^where$" $word "whaur" word
		regsub -nocase "^whom$" $word "wham" word
		regsub -nocase "^who$" $word "wha" word
		regsub -nocase "^will$" $word "wull" word
		regsub -nocase "^with$" $word "wi'" word
		regsub -nocase "^would$" $word "wid" word
		regsub -nocase "^your$" $word "yer" word
		regsub -nocase "^you$" $word "ye" word

		append newLine "$word "
	}
	set line [string trim $newLine]
	return $line
}
