parameter dV is nextnode:deltav:mag.
run ISPcurrent.
if ship:maxthrust > 0 {
	set mfinal to ship:mass * constant:E^(-dV / (ISPcurrent * 9.81)).
	set mpropellant to ship:mass - mfinal.
	set burnpt to ship:maxthrust / (ISPcurrent * 9.81).
	set burntime to mpropellant/burnpt.
}	
set timeto to burntime/2.

