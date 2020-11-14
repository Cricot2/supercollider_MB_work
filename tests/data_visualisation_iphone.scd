// IPHONE DATA WORK........................................................................
// Quelques test avec un accelérometre d'iphone pour apprendre à travailler avec des datas.
// => On pourrais essayer avec la classe MBDeltaTrig (à installler) pour voir un peux.


// Accelerometer.
// ANTIS REBONDS
// 1 =>  Anti rebonds qui coupe jusqu'a la fin du son "NodeWatcher".
(
OSCdef(\x_bang, {
	|msg|
	if (msg[1] >= 0.5 && (~test.isPlaying == false), {

		3.do{
			~test = { Pulse.ar([420, 440],
				LFNoise1.kr(100).range(0.2, 0.6),
				EnvGen.kr(Env.perc(0.01, 1, 0.3), doneAction:2))
			}.play;
		};
		NodeWatcher.register(~test);
	});
}, "/gyrosc/thegame/accel"
)
)

// 2 => Anti rebonds avec delay.
// C'est un systeme qui combine ~last_value + wait;
(
//debounce time:
~debounce = 0.2;
~last_value = 0;

~test2 = {
	Pulse.ar([420, 440] / 2,
		LFNoise1.kr(100).range(0.2, 0.6),
		EnvGen.kr(Env.perc(0.01, 1, 0.3), doneAction:2))
};

OSCdef(\bang, {
	|msg|
	if (msg[1] >= 0.5 && (~last_value == 0), {
		fork{
			3.do{~test2.play;};
			~last_value = 1;
			~debounce.wait;
			~last_value = 0;
		};
	});
}, "/gyrosc/thegame/accel"
)
)



// Giroscope.
// 1 = tangage.
// 2 = roulis.
// 3 = lacet.
// Donc is on prends en compte le roulis avec une boite à meuh...
// Mais on peux trouver d'autres combinaisons.

(
~up = 0;
~me = Buffer.read(s, "/Users/macbook/Documents/SuperCollider/sc_Projects/sensor_mouvement/tests/meh.wav");

OSCdef(\giro, {
	|msg|
	if (msg[2] >= 3 && (~up == 0), {
		"180°".postln;
		x = {Pan2.ar(PlayBuf.ar(1, ~me, doneAction:2), level: 1.5)}.play;
		~up = 1;
	});

	if (msg[2] <= 0.1 && (~up == 1), {
		~up = 0;
	});

}, "/gyrosc/thegame/gyro"
)
)


// Compas.
// Try to make a simple panning example.

(
fork{

	SynthDef(\pan_test, {
		|pan|
		Out.ar(0, Pan2.ar(PinkNoise.ar(0.1), pan));
	}).add;

	0.1.wait;
	p = Synth(\pan_test);

	OSCdef(\comp, {
		|msg|
		var pan_msg;
		//try to avoid abrupt pos change.
		pan_msg = msg[1].linlin(0, 330, 45, 90);
		p.set(\pan, pan_msg.linlin(45, 90, -1, 1));
	}, "/gyrosc/thegame/comp"
	)
}
)



























