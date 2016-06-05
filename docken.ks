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

	// DOCKEN
	rcs off.
	sas off.
	eigenerPort:controlFrom.
	//lock steering to zielPort:portfacing-r(180,0,0).

	// Berechne Zielpunkt mit Sicherheitsabstand
	lock zielPunktA to ((zielPort:facing:vector*30)+zielPort:nodeposition).
	lock steering to zielPunktA.
	
	set auszeit to 8.
	until (auszeit <= 0) {
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

	
	// 1. Aus Zielportrichtung Vektor -> A berechnen.
	// 2. Vektor von eigener Postition zu A berechnen. 
	
	 
	// TODO Ggf. dem Zielschiff ausweichen
	clearscreen.
	
	rcs on.
	set ship:control:fore to 0.5.
	wait 1.
	set ship:control:fore to 0.
	rcs off.

	lock steering to zielPunktA.
	
	set letzterV to zielPunktA.
	//lock korrekturVektor to (letzterV-zielPunktA):direction.
	until (zielPunktA:mag < 3) {
		wait 0.2.
		print "ziel :"+zielPunktA at (0,0).
		print "dist :"+zielPunktA:mag at (0,1).
		print "zielrichtung :"+zielPunktA:direction at (0,2).
		set jetztV to (letzterV - zielPunktA).
		print "eig.richtung :"+jetztV:direction at (0,3).
		set letzerV to zielPunktA.
	}
	rcs on.
	set ship:control:fore to -0.5.
	wait 1.
	set ship:control:fore to 0.
	rcs off.

	print "Erfolgreich angedockt -- beende.".
	return 0.
}.

print dock(target).

when true then {
	print "Pos:"+zielPort:nodeposition.
	wait 1.
	return true.
}.