// Halterungen loesen
FOR clamp IN SHIP:PARTSNAMED("launchClamp1") {
  clamp:GETMODULE("LaunchClamp"):DOEVENT("release clamp").
}.