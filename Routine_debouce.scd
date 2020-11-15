
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
	{sig <= 0.4 && (last_value == 0)} {~percPink.reset}; // This reset the Routine with a 'key up' condition.
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

//With KICK Synth...

(
fork{

	// Simple debounce, with a sort of 'key up' condition...
	var last_value = 0;
	var debounce = 0.01;

	SynthDef(\kick, {arg out = 0, amp = 0.8, sinfreq = 30,
		glissf = 0.9, att = 0.01, rel = 0.5, pan = 0;
		var env, snd, ramp;
		env = Env.perc(att, rel, amp).kr(doneAction: 2);
		ramp = XLine.kr(
			start: sinfreq,
			end: sinfreq * glissf,
			dur: rel
		);
		snd = Pulse.ar(freq: ramp, mul: env);
		snd = Pan2.ar(snd, pan);
		Out.ar(out, snd);
	}).add;

	s.sync;

	OSCdef(\monitor, {
		|msg|
		var sig, synth;
		sig = msg[1].linlin(-1024, 1024, 0, 1);
		// sig.round(0.01).postln;
		case
		{sig >= 0.95 && (last_value == 0)} {~percPink.play}  // Routines are played only once and need reset methode.
		{sig <= 0.6 && (last_value == 0)} {~percPink.reset}; // This reset the Routine with a 'key up' condition.
	}, "/acc"
	);

	~percPink = Routine({
		var synth;
		last_value = 1;
		synth = Synth(\kick);
		debounce.wait;
		last_value = 0;
	});
}
)


