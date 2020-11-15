
(
// Simple debounce, with a sort of 'key up' condition...
var last_value = 0;
var debounce = 0.01;

SynthDef(\pinkTest, {
	|out|
	var sig, env;
	env = EnvGen.kr(Env.perc(0.01, 0.5, 1), doneAction:2);
	sig = PinkNoise.ar(env !2);
	sig = sig * env;
	Out.ar(out, sig);
}).add;

OSCdef(\monitor, {
	|msg|
	var sig, synth;
	sig = msg[1].linlin(-1024, 1024, 0, 1);
	// sig.round(0.01).postln;
	case
	{sig >= 0.95 && (last_value == 0)} {~percPink.play} // Routines are played only once and need reset methode.
	{sig <= 0.25 && (last_value == 0)} {~percPink.reset}; // This reset the Routine with a 'key up' condition.
}, "/acc"
);

~percPink = Routine({
	var synth;
	last_value = 1;
	synth = Synth(\pinkTest);
	debounce.wait;
	last_value = 0;
});


)
