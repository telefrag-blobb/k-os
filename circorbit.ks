parameter orbitx.

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
		
add node(time:seconds,0,0,0).

wait 0.01.

		if periapsis > orbitx {
			set nextnode:eta to eta:apoapsis.
		}
		else {
			set nextnode:eta to eta:periapsis.
		}

until round(nextnode:orbit:periapsis / orbitx,2) = 1 or round(nextnode:orbit:apoapsis / orbitx,2) = 1 {

	if periapsis > orbitx {
		until round(nextnode:orbit:periapsis / orbitx,2) = 1{
			set nextnode:prograde to nextnode:prograde + (0.05*(1-nextnode:orbit:periapsis / orbitx)/abs(1-nextnode:orbit:periapsis / orbitx)) + 0.05*(1-(nextnode:orbit:periapsis / orbitx)).
		}
	}

	else  {
		until round(nextnode:orbit:apoapsis / orbitx, 2) = 1{
			set nextnode:prograde to nextnode:prograde + (0.05*(1-nextnode:orbit:apoapsis / orbitx)/ abs(1-nextnode:orbit:apoapsis / orbitx)) + 0.05*(1-(nextnode:orbit:apoapsis / orbitx)).	
		}
	}
}

if nextnode:deltav:mag < 0.5 {
	remove nextnode.
}
else {
	run maneuvernode.
}

wait 1.
add node(time:seconds,0,0,0).
wait 1.

		if round(apoapsis / orbitx,2) <> 1 {
			set nextnode:eta to eta:periapsis.
		}
		else  {
			set nextnode:eta to eta:apoapsis.
		}

until round(nextnode:orbit:periapsis / orbitx,1) = 1 and round(nextnode:orbit:apoapsis / orbitx,1) = 1 {

	if round(apoapsis / orbitx,2) <> 1 {
	set nextnode:prograde to nextnode:prograde +(0.02*(1-nextnode:orbit:apoapsis / orbitx)/ abs(1-nextnode:orbit:apoapsis / orbitx)) + 0.02*(1-(nextnode:orbit:apoapsis / orbitx)).
	}
	
	else {
	set nextnode:prograde to nextnode:prograde + (0.02*(1-nextnode:orbit:periapsis / orbitx)/abs(1-nextnode:orbit:periapsis / orbitx)) + 0.02*(1-(nextnode:orbit:periapsis / orbitx)).
	}
	
}
		
		
if nextnode:deltav:mag < 0.5 {
	remove nextnode.
}
else {
	run maneuvernode.
}