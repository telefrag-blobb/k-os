run lib_menu.

// Gibt eine Liste freier Andockports des spezifizierten Typs (bzw. "egal") zurueck.
function ermittlePorts {
	parameter schiff is ship.
	parameter portTyp is "egal".

	set rueckgabeListe to list().

	set andockportListe to schiff:dockingports.
	for andockPort in andockportListe {
		if (portTyp = "egal" or andockPort:nodetype = portTyp) {
			if(andockPort:state = "Ready") {
				rueckgabeListe:add(andockPort).
			}
		}
	}
	return rueckgabeListe.
}

function waehlePorts {

	// Ziel
	parameter ziel is target.

	// Eigener Andockport
	parameter eigenerPort is "egal".
	
	// Konstanten
	set FORTFAHREN to "[fortfahren]".
	set ABBRUCH to "[abbrechen]".
	
	// Abbruchvariable
	//set fertig to 0.

	// Port ermitteln
	if (eigenerPort = "egal") {
	
		set portListe to ermittlePorts().
		if (portListe:LENGTH = 0) {
			// Nichts zu machen ...
			print "Andocken nicht moeglich -- kein passender freier Andockport am eigenen Schiff vorhanden.".
			return 1.
		}
		
		// Abbruch-Option hinzufuegen
		portListe:add(ABBRUCH).
		
		// Manuelle Portauswahl
		set eigenerPort to open_menu("Mit welchem Port andocken?",portListe).

		if (eigenerPort = ABBRUCH) {
		  print "Breche ab.".
		  return 1.
		}
		
		print "Eigenen Port ausgewaehlt: "+eigenerPort.
		
		set eigenerPortPfeil TO VECDRAW(
			eigenerPort:POSITION,
			(eigenerPort:portfacing:VECTOR*5),
			RGB(0,0,1),
			"",
			1.0,
			TRUE,
			0.2
		).
		
	}

	print "Gewaehltes Ziel ist vom Typ "+ziel:typename.
	set zielPort to "n/v".

	// Ziel pruefen
	if not (ziel:typename = "DockingPort") {
		print "Es ist kein Andockport als Ziel ausgewaehlt.".

		// Ist ein Schiff ausgewaehlt?
		if (ziel:typename = "Vessel") {
		
			// Suche nach Andockport
			set zielPortListe to ermittlePorts(ziel,eigenerPort:nodetype).
			
			// Abbrechen, wenn kein passender freier Port gefunden wurde
			if (zielPortListe:LENGTH = 0) {
				// Nichts zu machen ...
				print "Andocken nicht moeglich -- kein passender freier Andockport am Zielschiff vorhanden.".
				unset eigenerPortPfeil.
				return 1.
			}
			
			// Abbruch-Option hinzufuegen
			zielPortListe:add(ABBRUCH).
			
			// Manuelle Portauswahl
			set zielPort to open_menu("An welchen Port andocken?",zielPortListe).

			if (zielPort = ABBRUCH) {
				print "Breche ab.".
				unset eigenerPortPfeil.
				return 1.
			}
		
			print "Zielport ausgewaehlt: "+zielPort.
		
			set zielPortPfeil TO VECDRAW(
				zielPort:POSITION,
				(zielPort:portfacing:VECTOR*5),
				RGB(0,1,0),
				"",
				1.0,
				TRUE,
				0.2
			).
		}
	} else {
		set zielPort to ziel.
	}

	if (zielPort = "n/v") {
		// Nichts zu machen ...
		print "Andocken nicht moeglich -- kein passender freier Andockport am Ziel vorhanden.".
		unset eigenerPortPfeil.
		return 1.
	}

	set auswahl to open_menu("Mit den gewaehlten Ports fortfahren?",list(FORTFAHREN,ABBRUCH)).
	unset eigenerPortPfeil.
	unset zielPortPfeil.
	if (auswahl = ABBRUCH) {
		return 1.
	}
	
	return list(eigenerPort,zielPort).
}.