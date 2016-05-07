parameter lattrgt is 0.
parameter lngdefault is -74.

set lngtrgt to lngdefault-2.

set SPTMax to 3.
set lat to geoposition:lat.
set lng to geoposition:lng.

until geoposition:lat + 5 > lattrgt and geoposition:lat - 5 < lattrgt {
	set warp to 3.
}

set warp to 0.

wait until round(lattrgt) = round(geoposition:lat).

set lngShift to 360/body:rotationperiod*orbit:period.

set lngCalc to geoposition:lng - lngShift.
set turns to 1.

set diff to abs(lngCalc-lngtrgt).

until diff/turns < SPTMax or abs(diff-360)/turns < SPTMax {

	set lngCalc to lngCalc - lngShift.

	if lngCalc < -180 {
		set lngCalc to lngCalc + 360.
	}

	print lngCalc.
	set turns to turns + 1.
	set diff to abs(lngCalc-lngtrgt).
	print diff.
}

set SPT1 to diff / turns.
set SPT2 to abs(diff-360)/ turns.
print SPT1.
print SPT2.
print turns.

set OPdiff to min(diff / turns,abs(diff-360)/ turns)/360*body:rotationperiod.
print OPdiff.

if diff < 180 {
	set OPdes to orbit:period + OPdiff*(lngCalc-lngtrgt)/abs(lngCalc-lngtrgt).
}

else {
	set OPdes to orbit:period - OPdiff*(lngCalc-lngtrgt)/abs(lngCalc-lngtrgt).
}

print OPdes.

add node(time:seconds+30,0,0,0).

until round(nextnode:orbit:period,1) = round(OPdes,1) {
	set nextnode:prograde to nextnode:prograde + (0.05*(1-nextnode:orbit:period/OPdes)/abs(1-nextnode:orbit:period/OPdes)) + 1*(1-nextnode:orbit:period/OPdes).
}

run maneuvernode.

wait 1.

add node(0,0,0,0).
set nextnode:eta to (turns-0.5)*orbit:period.
