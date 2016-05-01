set nd to nextnode.
print "Node in: " + round(nd:eta) + ", DeltaV: " + round(nd:deltav:mag).
set max_acc to ship:maxthrust/ship:mass.
set burn_duration to nd:deltav:mag/max_acc.
print "Crude Estimated burn duration: " + round(burn_duration) + "s".
wait until nd:eta <= (burn_duration/2 + 60).
set np to nd:deltav. //points to node, don't care about the roll direction.
lock steering to np.
//wait until abs(np:pitch - facing:pitch) < 0.15 and abs(np:yaw - facing:yaw) < 0.15.
wait until nd:eta <= (burn_duration/2).
set tset to 0.
lock throttle to tset.
set done to False.
set dv0 to nd:deltav.
until done
{
    set max_acc to ship:maxthrust/ship:mass.
    set tset to min(nd:deltav:mag/max_acc, 1).
    if vdot(dv0, nd:deltav) < 0
    {
		print "MARKE1".
        print "End burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
		print "MARKE8".
        lock throttle to 0.
		print "MARKE9".
        break.
    }
    if nd:deltav:mag < 0.1
    {
		print "MARKE2".
        print "Finalizing burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
		print "MARKE3".
        wait until vdot(dv0, nd:deltav) < 0.5.
		print "MARKE4".
        lock throttle to 0.
		print "MARKE5".
        print "End burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
		print "MARKE6".
        set done to True.
		print "MARKE7".
    }
}
print "MARKE10".
unlock steering.
unlock throttle.
wait 1.
print "MARKE11".
remove nd.
print "MARKE12".
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
print "MARKE13".