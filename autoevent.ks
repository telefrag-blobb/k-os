// Anzahl der Beobachtungen, nach denen abgebrochen werden soll
parameter anzahl is 10.

// Der zu beobachtende Wert: 3-Tupel aus Teilname, Modulname und Feldname
parameter beobachten is list("dmImagingPlatform","ModuleGPS","biome").

// Die auszufuehrenden Events: Jedes Element ist ein 3-Tupel aus Teilname, Modulname und Eventname.
parameter ausfuehren is list(list("dmImagingPlatform","DMModuleScienceAnimate","log imaging data"),list("dmscope","DMModuleScienceAnimate","log visual observations")).

set beobachter to ship:partsnamed(beobachten[0])[0].
set beobachterModul to beobachter:getmodule(beobachten[1]).
set bekannteBeobachtungen to list().

on beobachterModul:getfield(beobachten[2]) {

	set aktuelleBeobachtung to beobachterModul:getfield(beobachten[2]).
	for beobachtung in bekannteBeobachtungen {
		if (beobachtung = aktuelleBeobachtung) {
			return true.
		}
	}
	bekannteBeobachtungen:add(aktuelleBeobachtung).
	print "Neue Beobachtung '"+aktuelleBeobachtung+"'.".

	// Aktionen ausfuehren
	for element in ausfuehren {
		set teil to ship:partsnamed(element[0])[0].
		set modul to teil:getmodule(element[1]).
		modul:doevent(element[2]).
	}

	return true.
}
until (anzahl <= bekannteBeobachtungen:length) {
	print "Anzahl einzigartiger Beobachtungen:"+bekannteBeobachtungen:length + "/" + anzahl + " " at (0,0).
	wait 1.
}

