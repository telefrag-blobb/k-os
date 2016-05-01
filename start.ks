// Anzupassende

DECLARE parameter ZIELORBIT is 90000. // Zielorbit in Metern
DECLARE parameter MAXSTUFE is 1. // Letzte Stufe, die aktiviert werden darf.
DECLARE parameter sicherheitsHoehe is 1000. // Minimale hoehe (RADAR, in Metern), unterhalb derer beim Start keine Inklination des Raumschiffes vorgenommen wird.

// Interne Variablen
SET COUNTDOWN TO -10.
SET ABGESCHLOSSEN TO 0.

// Vollgas
LOCK THROTTLE TO 1.0.

// Anzeige
CLEARSCREEN.
PRINT "Schiff: " + SHIP:NAME AT (0,0).
PRINT "Status: " AT (0,1).
PRINT "Zielorbit: " + ZIELORBIT + "m  " AT (0,2).
PRINT "Stufe: " + stage:number AT (0,3).

when true then {
    PRINT "Apoapsis: "+ROUND(SHIP:APOAPSIS,0) + "m " AT (0,4).
    PRINT "Periapsis: "+ROUND(SHIP:PERIAPSIS,0) + "m " AT (0,5).
    PRINT "Geschwindigkeit: "+round(SHIP:VELOCITY:SURFACE:MAG,0) + "m/s " AT (0,6).
    if abgeschlossen=0 {
        return true.
    } else {
        return false.
    }
}

// Countdown
UNTIL COUNTDOWN >= 0 {
    print COUNTDOWN + " " AT (8,1).
    SET COUNTDOWN TO COUNTDOWN+1.
    WAIT 1.
}

// Stufenverwaltung
WHEN MAXTHRUST = 0 AND ABGESCHLOSSEN = 0 THEN {
    SET PRUEFUNG TO (stage:number > MAXSTUFE).
    IF PRUEFUNG {
        STAGE.
        PRINT stage:number + " " AT (7,3).
    }
    RETURN PRUEFUNG.
}.

// Lagebericht
WHEN COUNTDOWN >= 0 THEN {
    PRINT SHIP:STATUS + "                   " AT (8,1).
    IF ABGESCHLOSSEN = 0 {
        return true.
    }
    return false.
}.

// Triebwerke Schub aufbauen lassen
SET totalThrust TO 0.
UNTIL totalThrust < SHIP:MAXTHRUST {
    SET totalThrust TO 0.

    LIST ENGINES IN engList.
    FOR eng IN engList {
        IF eng:IGNITION SET totalThrust TO totalThrust + eng:THRUST.
    }.
    wait 0.5.
}.

// Halterungen loesen
FOR clamp IN SHIP:PARTSNAMED("launchClamp1") {
  clamp:GETMODULE("LaunchClamp"):DOEVENT("release clamp").
}.

// Aufstieg
set aufstiegsWinkel to 90.
SET RUDER TO HEADING(90,aufstiegsWinkel).
LOCK STEERING TO RUDER.
UNTIL SHIP:APOAPSIS > ZIELORBIT {

    // Der Aufstiegswinkel liegt initial bei 90°,
    // und wird relativ zur erreichten Hoehe bzw.
    // Geschwindigkeit bis auf 10° reduziert.

    set aufstiegsWinkel to 90.
    
    // Pruefe, ob Sicherheitshoehe erreicht ist.
    if alt:radar > sicherheitsHoehe {

        // Berechne prozentualen Abstand zur Endgeschwindigkeit (800m/s).
        set Ve to 900.
        set V to SHIP:VELOCITY:SURFACE:MAG.
        if V > Ve {
            set V to Ve.
        }
        set przV to V / Ve. // 0 m/s = 0.0, Ve m/s = 1.0.
        // Berechne prozentualen Abstand zur Atmosphaerenhohe/1.5.
        set przH to 1.
        if ship:body:atm:exists {
            set H to ship:altitude.
            set Ha to (ship:body:atm:height/1.5).
            if H > Ha {
                set H to Ha.
            }
            set przH to H / Ha.
        }

        set aufstiegsWinkel to 90-(80*((przV+przH)/2)).
        print "                                                              " at (0,8).
        
    } else {
        print "Warte auf Erreichen der Sicherheitshoehe ("+sicherheitsHoehe+"m)" at (0,8).
    }

    SET RUDER TO HEADING(90,aufstiegsWinkel).
    PRINT "Aufstiegswinkel: "+round(aufstiegsWinkel,1)+"°   " AT(0,7).
}.

// Schub drosseln
LOCK THROTTLE TO 0.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

// Warte auf Erreichen der Apoapsis
LOCK STEERING TO PROGRADE.

// Berechne Navigationsknoten zur Orbitzirkulation (bislang ungenutzt)
set orbitBody to SHIP:BODY.
set radiusAtAp TO orbitBody:radius + apoapsis.
set orbitalVelocity to orbitBody:radius * sqrt(9.8/(orbitBody:radius + (ZIELORBIT))).
set apVelocity to sqrt(orbitBody:mu * ((2/radiusAtAp)-(1/ship:obt:semimajoraxis))).
set deltaV to (orbitalVelocity - apVelocity).
set circNode to node(time:seconds + eta:apoapsis,0,0,deltaV).
add circNode.

// Knoten ausfuehren
run ausfuehren.

SET ABGESCHLOSSEN TO 1.
LOCK THROTTLE TO 0.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
CLEARSCREEN.
print "Orbit erreicht - gebe Kontrollen frei.".
UNLOCK THROTTLE.
UNLOCK STEERING.
