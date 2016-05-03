run burntime.
set node to nextnode:deltav.
lock steering to nextnode:deltav.
wait 2.
wait until ship:angularmomentum:mag < 0.01 .

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


if altitude < body:atm:height {
	set warpmode to "physics".
	set warp to 3.
}
WAIT until altitude > body:atm:height or nextnode:eta < (timeto + 5).
set warp to 0.
wait 1.
set warpmode to "rails".
WARPTO(time:seconds + nextnode:eta - timeto - 5).
WAIT until nextnode:eta < (timeto + 5).

UNTIL nextnode:deltav:mag < 1 {

	stagecheck.
	
	if nextnode:eta < timeto {
		lock throttle to 1.
	}
		
}
lock throttle to 0.
remove nextnode.