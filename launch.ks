CLEARSCREEN.

function printData {

	PRINT "TARGET ORBIT " + orbt + " " at (0,0).
	PRINT "APOAPSIS " + round(APOAPSIS,0) + " " at (0,1).
	PRINT "INCLINATION CURRENT " + round(orbit:inclination,5) + "      " at (0,2).
	PRINT "INCLINATION DESIRED " + round(incl,5) + "      " at (0,3).
	PRINT "CORRECTING BY " + round(crrct,5) + "      " at (0,4).
	PRINT "COMPENSATING BY " + round(compensate,5) + "      " at (0,5).
	PRINT "COS " + round(COS(hdng),5) + "      " at (0,6).
}

//SETUP

//initial state
SET MY_VESS to SHIP.
SAS OFF.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
lock throttle to 1.

//declare Paramaters

PARAMETER orbt is 100.
PARAMETER incl is 0.
PARAMETER AGG is 1.4.

//fixing heading and orbit

when incl > 180 then {
	set incl to incl - 360.
	Preserve.
}

if incl = 0 {
	set incl to incl + 0.01.
}
set hdng to 90 - incl.
set orbt to orbt * 1000.

//declare Functions

//cuts engines in current stage
function cutoff {
	LIST ENGINES IN engineList.
	FOR eng IN engineList {
		IF eng:STAGE = stage:number {
			eng:shutdown.
			lock thrust to 0.
			wait 1.
			eng:activate.
		}
	}
}

//backgroundroutines

//stages on flamout.
set flameoutindicator to 0.
WHEN flameoutindicator = 1 THEN {
	set flameoutindicator to 0.
	stage.
	lock thrust to 1.
	preserve.
}

WHEN MAXTHRUST = 0 THEN {
	stage.
	preserve.
}

//checks for flamout, put wherever stagecheck is needed
function stagecheck {
	list engines in engineList.
	for eng in engineList {
		if eng:flameout = true {
			set flameoutindicator to 1.
		}
	}
}

//MAINPROGRAM

//GRAVITYTURN and INCLINATION

//setting variables
set compensate to -20*COS(hdng).
LOCK TICTOC to 1.
SET exit to 0.

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
run releaseclamp.

//routine

until APOAPSIS > orbt {

	stagecheck.

	until exit = 6 or APOAPSIS > orbt {

		stagecheck.

		if orbit:inclination > ABS(incl) and TICTOC = 1 {
			set compensate to compensate * -0.5.
			LOCK TICTOC to 0.
			set exit to exit + 1.
		}

		if orbit:inclination < ABS(incl) and TICTOC = 0 {
			set compensate to compensate * -0.5.
			LOCK TICTOC to 1.
			set exit to exit + 1.
		}

		set incltol to 1 - (orbit:inclination/ ABS(incl)).
		set crrct to -20*COS(hdng)* incltol.
		set PZ to APOAPSIS/orbt.
		LOCK STEERING to HEADING(crrct+hdng+compensate,90-MIN(90,(PZ*AGG*90))).

		//debug routine
		printData().
		WAIT 0.01.
	}

	set PZ to APOAPSIS/orbt.
	LOCK STEERING TO HEADING(hdng,90-MIN(90,(PZ*AGG*90))).

	//debug routine
	printData().
	WAIT 0.01.
}
lock throttle to 0.

//CIRCULARIZATION

//initial state

add node(time:seconds+eta:apoapsis,1,0,0).

//routine

lock steering to nextnode:deltav.

UNTIL nextnode:orbit:periapsis/apoapsis > 0.99 {
	set nextnode:prograde to nextnode:prograde + 0.05 +1*(1-(max(1,nextnode:orbit:periapsis))/apoapsis).
}

run burntime(nextnode:eta).
run maneuvernode.
CLEARSCREEN.
