lock ptam to target:mass*target:velocity:orbit.
lock tam to vcrs(ptam,target:position-body:position).
lock pam to ship:mass*ship:velocity:orbit.
lock am to vcrs(pam,-body:position).
lock nv to vcrs(am,tam).
lock sgp to constant:g * Body:Mass.
lock ev to vcrs(velocity:orbit,vcrs(orbit:position,velocity:orbit))/sgp - orbit:position/orbit:position:mag.
lock ta to arccos(ev*nv/ev:mag/nv:mag)-90.

when maxthrust = 0 then {
	stage.
	preserve.
}

if round(ta/abs(ta)) = -1 {
	lock steering to lookdirup(vcrs(body:position,ship:velocity:orbit),ship:facing:topvector).

}

else {
	lock steering to lookdirup(-vcrs(body:position,ship:velocity:orbit),ship:facing:topvector).
}

set warp to 1.
wait 1.
set warp to 2.
wait until abs(ta) < 10.
set warp to 0.

set timer to 5.5.



until abs(target:orbit:inclination - ship:orbit:inclination) < 0.1 {

	
	if abs(ta) < timer {
		lock throttle to 1.
		print "grad: " + (abs(round(ta,1))+0.5).
		print "timer: " + timer.
	}
	
	else {
		
		set timer to max(timer - 0.5,0.1).
		
		lock throttle to 0.
		
		until abs(round(ta)) < timer {
			clearscreen.
			print "grad: " + (abs(round(ta,1))+0.5).
			print "timer: " + timer.
		}		
	}
}

lock throttle to 0.
lock steering to lookdirup(ship:velocity:orbit, ship:facing:topvector).
rcs on.

until round(ship:orbit:trueanomaly) = 90 or round(ship:orbit:trueanomaly) = 270 {
	print ship:orbit:trueanomaly.
}

wait 5.

until abs(ship:orbit:argumentofperiapsis - target:orbit:argumentofperiapsis) < 1 or abs(ship:orbit:argumentofperiapsis - target:orbit:argumentofperiapsis) > 179 {
	
	if ship:orbit:argumentofperiapsis > target:orbit:argumentofperiapsis {
		set ship:control:fore to -1.
	}
	
	else {
		set ship:control:fore to 1.
	}
}

set ship:control:neutralize to true.

add node(0,0,0,0).

rcs off.

if eta:apoapsis < eta:periapsis {
	set nextnode:eta to eta:apoapsis.
	set nodeflag to 1.
}

else{
	set nextnode:eta to eta:periapsis.
	set nodeflag to 0.
}




if abs(ship:orbit:argumentofperiapsis - target:orbit:argumentofperiapsis) < 10 and nodeflag = 1 {					//Orbit Apoapsis, gleiche Seiten
	
	if target:orbit:periapsis > ship:orbit:apoapsis {
		until abs(target:orbit:periapsis - nextnode:orbit:apoapsis) < 100 {
			set nextnode:prograde to nextnode:prograde + 0.01.
		}
	}

	else if target:orbit:periapsis < ship:orbit:apoapsis {
		until abs(nextnode:orbit:periapsis- target:orbit:periapsis) < 100 {
			set nextnode:prograde to nextnode:prograde + 0.01 * (target:orbit:periapsis-nextnode:orbit:periapsis)/abs(target:orbit:periapsis-nextnode:orbit:periapsis).
		}
	}

}

else if abs(ship:orbit:argumentofperiapsis - target:orbit:argumentofperiapsis) < 10 and nodeflag = 0 {				//Orbit Periapsis, gleiche Seiten
	
	if ship:orbit:periapsis > target:orbit:apoapsis {
		until abs(ship:orbit:periapsis - target:orbit:apoapsis) < 100 {
			set nextnode:prograde to nextnode:prograde - 0.01.
		}
	}
	
	else if ship:orbit:periapsis < target:orbit:apoapsis	{
		until abs(ship:orbit:apoapsis - target:orbit:apoapsis) < 100 {
			set nextnode:prograde to nextnode:prograde + 0.01 * (target:orbit:apoapsis-nextnode:orbit:apoapsis)/abs(target:orbit:apoapsis-nextnode:orbit:apoapsis).
		}
	}

}

else if abs(ship:orbit:argumentofperiapsis - target:orbit:argumentofperiapsis) > 10 and nodeflag = 1 {				//Orbit Apoapsis, getauscht

	if ship:orbit:periapsis > target:orbit:apoapsis {
		until abs(ship:orbit:periapsis - target:orbit:apoapsis) < 100 {
			set nextnode:prograde to nextnode:prograde - 0.01.
		}
	}
	
	else if ship:orbit:periapsis < target:orbit:apoapsis	{
		until abs(ship:orbit:apoapsis - target:orbit:apoapsis) < 100 {
			set nextnode:prograde to nextnode:prograde + 0.01 * (target:orbit:apoapsis-nextnode:orbit:apoapsis)/abs(target:orbit:apoapsis-nextnode:orbit:apoapsis).
		}
	}
	
}

else if abs(ship:orbit:argumentofperiapsis - target:orbit:argumentofperiapsis) > 10 and nodeflag = 0 {				//Orbit Periapsis, getauscht

	if target:orbit:periapsis > ship:orbit:apoapsis {
		until abs(target:orbit:periapsis - nextnode:orbit:apoapsis) < 100 {
			set nextnode:prograde to nextnode:prograde + 0.01.
		}
	}

	else if target:orbit:periapsis < ship:orbit:apoapsis {
		until abs(nextnode:orbit:periapsis- target:orbit:periapsis) < 100 {
			set nextnode:prograde to nextnode:prograde + 0.01 * (target:orbit:periapsis-nextnode:orbit:periapsis)/abs(target:orbit:periapsis-nextnode:orbit:periapsis).
		}
	}
	
}

run maneuvernode.

set warp to 5.
wait ship:orbit:period/3.
set warp to 0.

lock steering to lookdirup(ship:velocity:orbit,ship:facing:topvector).
rcs on.

warpto(time:seconds + min(eta:periapsis,eta:apoapsis) -20).

if eta:apoapsis < eta:periapsis {
	set nodeflag to 1.
	wait until eta:apoapsis < 1.
	set tposdif to abs(target:orbit:trueanomaly-180).
}

else{
	set nodeflag to 0.
	wait until eta:periapsis < 1.
	set tposdif to target:orbit:trueanomaly.
}





set ttimedif to -ship:orbit:period * tposdif / 360.
set ttimeshift to (target:orbit:period - ship:orbit:period) * (ship:orbit:period /target:orbit:period).
print ttimeshift.
set n to 1.


until abs(ttimedif)/n < ship:orbit:period / 40 or abs(ship:orbit:period-ttimedif)/n < ship:orbit:period / 40{

	set n to n + 1.
	set ttimedif to ttimedif + ttimeshift.
	if ttimedif > ship:orbit:period {
		set ttimedif to ttimedif - ship:orbit:period.
	}
	else if ttimedif < 0 {
		set ttimedif to ttimedif + ship:orbit:period.
	}
	print ttimedif .
	print abs(ship:orbit:period-ttimedif).
}

if ttimedif/n < ship:orbit:period / 40 {
	set tvz to 1.
}

else {
	set tvz to -1.
}


set timechange to min(abs(ship:orbit:period-ttimedif)/n,ttimedif/n).

print n - 1.
print timechange.
set desperiod to ship:orbit:period + tvz*timechange.


until abs(ship:orbit:period - desperiod) < 0.1 {
	if ship:orbit:period < desperiod {
		set ship:control:fore to 1.
	}
	else {
		set ship:control:fore to -1.
	}
}

set ship:control: neutralize to true.

wait 2.

warpto(time:seconds + (n - 1) * ship:orbit:period - 30).

lock trgtprograde to ship:velocity:orbit - target:velocity:orbit.
lock steering to lookdirup(-trgtprograde,ship:facing:topvector).
wait (n - 1) * ship:orbit:period - 30.

set grade to 2000000000.
set jetzt to 1000000000.
 
until grade < jetzt {
	set grade to jetzt.
	set jetzt to target:distance.
}
print grade.
print jetzt.

until trgtprograde:mag < 0.1 {
	set ship:control:fore to 1.
	lock throttle to 1.
}

set ship:control: neutralize to true.
lock throttle to 0.

lock steering to lookdirup(trgtprograde,ship:facing:topvector).

wait 5.

Lock trel to target:position * ship:facing.

until true {

}






