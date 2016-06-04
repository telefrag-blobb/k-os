// Gibt einen freien Andockport des spezifizierten
// Typs zurueck oder "n/v", wenn kein solcher
// auf dem gewaehlten Schiff verfuegbar ist.
function ermittlePort {
	parameter schiff is ship.
	parameter portTyp is "egal".

	set rueckgabewert to "n/v".

	print "Suche nach freiem Andockport an Schiff '"+schiff:name+"'.".
	set andockportListe to schiff:dockingports.
	for andockPort in andockportListe {
		print "Andockport '"+andockPort:title+"' gefunden -- pruefe Typkompatibilitaet.".
		if not (portTyp = "egal" or andockPort:nodetype = portTyp) {
			print "Typ inkompatibel -- suche weiter.".
		} else {
			print "Typ kompatibel -- pruefe Status.".
			if not (andockPort:state = "Ready") {
				print "Andockport '"+andockPort:title+"' ist bereits belegt -- suche weiter.".
			} else {
				print "Andockport '"+andockPort:title+"' ist frei -- waehle diesen.".
				set rueckgabewert to andockPort.
				break.
			}
		}
	}
	return rueckgabewert.
}

function dock {

	// Ziel
	parameter ziel is target.

	// Eigener Andockport
	parameter eigenerPort is "egal".

	// Port ermitteln
	if (eigenerPort = "egal") {
		set eigenerPort to ermittlePort().
		if (eigenerPort = "n/v") {
			// Nichts zu machen ...
			print "Andocken nicht moeglich -- kein passender freier Andockport am eigenen Schiff vorhanden.".
			return 1.
		}
	}

	print "Gewaehltes Ziel ist vom Typ "+ziel:typename.
	set zielPort to "n/v".

	// Ziel pruefen
	if not (ziel:typename = "DockingPort") {
		print "Es ist kein Andockport als Ziel ausgewaehlt.".

		// Ist ein Schiff ausgewaehlt?
		if (ziel:typename = "Vessel") {
			// Suche nach Andockport
			set zielPort to ermittlePort(ziel,eigenerPort:nodetype).
		}
	} else {
		set zielPort to ziel.
	}

	if (zielPort = "n/v") {
		// Nichts zu machen ...
		print "Andocken nicht moeglich -- kein passender freier Andockport am Ziel vorhanden.".
		return 1.
	}

	print "Docke mit '"+eigenerPort:title+"' an Port '"+zielPort:title+"' von Schiff '"+zielPort:ship:name+"'.".

	print "Rot:"+eigenerPort:rotation.
	print "Fac:"+eigenerPort:portfacing.
	print "!Fc:"+eigenerPort:portfacing:inverse.
	print "Pos:"+eigenerPort:nodeposition.
	print "Sta:"+eigenerPort:state.
	print "Ndt:"+eigenerPort:nodetype.
	print "Rng:"+eigenerPort:acquirerange.
	print "=======".
	print "   Rot:"+zielPort:rotation.
	print "   Fac:"+zielPort:portfacing.
	print "   !Fc:"+zielPort:portfacing:inverse.
	print "   Pos:"+zielPort:nodeposition.
	print "   Sta:"+zielPort:state.
	print "   Ndt:"+zielPort:nodetype.
	print "   Rng:"+zielPort:acquirerange.
	print "=======".

	// DOCKEN
	rcs off.
	sas off.
	eigenerPort:controlFrom.
	lock steering to zielPort:portfacing-r(180,0,0).
	//lock steering to zielPort:portfacing.

	set auszeit to 8.
	until ((auszeit <= 0) or (eigenerPort:portFacing = zielPort:portfacing-r(180,0,0))) {
		//print steering.
		wait 1.
		set auszeit to (auszeit - 1).
	}

	print "Rot:"+eigenerPort:rotation.
	print "Fac:"+eigenerPort:portfacing.
	print "!Fc:"+eigenerPort:portfacing:inverse.
	print "Pos:"+eigenerPort:nodeposition.
	print "Sta:"+eigenerPort:state.
	print "Ndt:"+eigenerPort:nodetype.
	print "Rng:"+eigenerPort:acquirerange.
	print "=======".
	print "   Rot:"+zielPort:rotation.
	print "   Fac:"+zielPort:portfacing.
	print "   !Fc:"+zielPort:portfacing:inverse.
	print "   Pos:"+zielPort:nodeposition.
	print "   Sta:"+zielPort:state.
	print "   Ndt:"+zielPort:nodetype.
	print "   Rng:"+zielPort:acquirerange.
	print "=======".

	rcs on.
	set toleranz to 0.1.
	set vGross to 0.6.
	set vKlein to 0.3.

	set letztesX to zielPort:nodeposition:x.
	set letztesY to zielPort:nodeposition:y.
	set letztesZ to zielPort:nodeposition:z.
	wait 1.

	until (zielPort:nodeposition:x < 1) and (zielPort:nodeposition:x > -1) and (zielPort:nodeposition:y < 1) and (zielPort:nodeposition:y > -1) and (zielPort:nodeposition:z < 1) and (zielPort:nodeposition:z > -1) {
		// Gewuenschte Geschwindigkeit berechnen
		set zielVx to 0.
		set zielVy to 0.
		set zielVz to 0.

		if (zielPort:nodeposition:x < -10) {
			set zielVx to vGross.
		} else if (zielPort:nodeposition:x < -5) {
			set zielVx to vKlein.
		}
		if (zielPort:nodeposition:y < -10) {
			set zielVy to vGross.
		} else if (zielPort:nodeposition:y < -5) {
			set zielVy to vKlein.
		}
		if (zielPort:nodeposition:z < -10) {
			set zielVz to vGross.
		} else if (zielPort:nodeposition:z < -5) {
			set zielVz to vKlein.
		}

		// Relative Geschwindigkeit berechnen.
		set istVx to letztesX-zielPort:nodeposition:x.
		set istVy to letztesY-zielPort:nodeposition:y.
		set istVz to letztesZ-zielPort:nodeposition:z.

		// TODO ... funktionierend machen.
		
		if (istVx < (zielVx-toleranz)) and (istVx < (zielVx+toleranz)) {
			set ship:control:fore to 0.1.
		} else if (istVx < zielVx) {
			set ship:control:fore to -0.1.
		} else {
			set ship:control:fore to 0.
		}
		if (istVy < (zielVy-toleranz)) and (istVy < (zielVy+toleranz)) {
			set ship:control:starboard to 0.1.
		} else if (istVy < zielVy) {
			set ship:control:starboard to -0.1.
		} else {
			set ship:control:starboard to 0.
		}
		if (istVz < (zielVz-toleranz)) and (istVz < (zielVz+toleranz)) {
			set ship:control:top to 0.1.
		} else if (istVz < zielVz) {
			set ship:control:top to -0.1.
		} else {
			set ship:control:top to 0.
		}

		print "istVx :"+istVx.
		print "zielVx:"+zielVx.
		print "ndposx:"+zielPort:nodeposition:x.
		wait 1.
	}

	print zielPort:nodeposition:x.

	print "Erfolgreich angedockt -- beende.".
	return 0.
}.

print dock(target).

when true then {
	print "Pos:"+zielPort:nodeposition.
	wait 1.
	return true.
}.