lock steering to srfretrograde.
set tthrottle to 0.

//housekeeping

when ship:maxthrust = 0 and round(stage:liquidfuel,1) = 0 then
stage.

//time to impact

lock currentG to constant:g*body:mass/(altitude+body:radius)^2.
lock decc to currentG.
lock TTI to max(-ppq/2+SQRT(((ppq/2)^2)-qpq),-ppq/2-SQRT(((ppq/2)^2)-qpq)).
lock heightleft to alt:radar.
lock ppq to abs(verticalspeed) * 2/decc.
lock qpq to -heightleft*2/decc.

//burntime

run ispcurrent.
lock mfinal to ship:mass * constant:E^(-abs(verticalspeed) / (ISPcurrent * 9.81)).
lock mpropellant to ship:mass - mfinal.
lock burnpt to ship:maxthrust / (ISPcurrent * 9.81).
lock burntime to mpropellant/burnpt.

set oben to ship:facing.

lock steering to oben.

lock throttle to tthrottle.

wait until TTI*1.7-0.5 < burntime.

set tthrottle to 1.

wait until abs(verticalspeed) < 10.

set tthrottle to currentG/(ship:maxthrust/ship:mass).

wait until alt:radar < 10.

until round(verticalspeed,1) = 0 and alt:radar < 10 {

	if abs(verticalspeed) > 2 {
		set tthrottle to min(1,tthrottle + 0.001).
	}

	else {
		set tthrottle to max(tthrottle - 0.1,currentG/(ship:maxthrust/ship:mass)).
	}
}

lock throttle to 0.
