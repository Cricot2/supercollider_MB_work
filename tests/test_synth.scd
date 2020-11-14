// Simple Gate ON / OFF synth with envellopes.

//to control BLE from terminal.
//brew install blueutil

(
fork{

	/*~port = NetAddr.langPort;
	~cmd = "cd /Users/macbook/Documents/Code_Script/Atelier_Code/Coding_Club/CBMicroBit/ && ./CBMicroBit"+~port;
	~cmd.runInTerminal;
*/
	~last_value = 0;

	SynthDef(\starts, {
		|amp=0.8, gate=0, scale=200|
		var sig, env, freq, pan;
		freq = EnvGen.kr(Env.adsr(1, 0.01), gate, scale, 0.1, doneAction:2);
		env = EnvGen.kr(Env.adsr, gate, doneAction:2);
		sig = VarSaw.ar(SinOsc.kr(freq).range(500, 1000), LFNoise1.kr(0.5).range(0, 1)) * env;
		pan = Pan2.ar(sig, SinOsc.kr(0.2).range(-1, 1), amp);
		Out.ar(0, pan);
	}).add;

	0.1.wait;

	OSCdef(\acc, {
		|msg|
		if (msg[3] >= 1000 && (~last_value == 0), {
			x = Synth(\starts, [\gate, 1]);
			~last_value = 1;
		});

		if (msg[3] <= 0 && (~last_value == 1), {
			x.set(\gate, 0);
			~last_value = 0;
		});
	}, "/acc"
	);
}
)


// tests...
t = Synth(\starts, [\gate, 1]);
t.set(\gate, 0);


"cd"++~pyhton_path.postln;