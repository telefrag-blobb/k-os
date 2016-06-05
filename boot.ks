
set dateiListe to list("burntime.ks","circorbit.ks","deorbit.ks","ispcurrent.ks","lander.ks","launch.ks","maneuvernode.ks","releaseclamp.ks","rendezvous.ks","docken.ks").
print "Kopiere "+dateiListe:length+" Dateien aus Archiv.".
wait 2. // Warte auf Initialisierung aller Teile.
set listenIterator to dateiListe:iterator.
listenIterator:reset().
until not listenIterator:next {
	print "Kopiere "+listenIterator:value.
	copy listenIterator:value from 0.
}
print "Dateien kopiert.".
list files.

