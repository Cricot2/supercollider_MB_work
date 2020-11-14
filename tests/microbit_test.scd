(
/*
Microbit - test 1. Proche de The_game.
BBC : Microbit OSC => BLE.
//////////////////////////
//////////////////////////
TODO :
On peux essayer de changer la SynthDef des sensors. Essayer avec une voix dans un granulateur (PlayBuf) + Reverbe.
S'inspirer de :
https://roosnaflak.com/100-sketches/028-rooftop/
*/

fork{

	// Take the port SC is listening and launch the script with right port.
	// BLE need to be desactivate and reactivate.

	/*~port = NetAddr.langPort;
	~cmd = "cd /Users/macbook/Documents/Code_Script/Atelier_Code/Coding_Club/CBMicroBit/ && ./CBMicroBit"+~port;
	~cmd.runInTerminal;*/

	~last_value = 0;
	OSCdef(\accelBang).disable;

	//SynthDefs
	SynthDef.new(\balls, {
		arg freq=4 ,detune2=1, atk=0.01, dec=0.3, rel=0.5, c1=1, c2=(-1), gate=1,
		mincf=40, maxcf=12000, minrq=0.002,
		maxrq2=0.2, boost2=1.25, amp=1.2, out=0;
		var sig, env;
		env = EnvGen.kr(Env.adsr(atk,dec,0.5,0.6),gate,doneAction:2);
		sig = Saw.ar(
			freq +
			LFNoise1.kr(LFNoise1.kr(0.5!8).range(0.1,1)).bipolar(detune2)
		);
		5.do{sig = (sig*boost2).fold(-1.0,1.0)};
		sig = BPF.ar(
			sig,
			LFNoise1.kr({ExpRand(0.005,0.05)}!8).exprange(mincf,maxcf),
			LFNoise1.kr({ExpRand(0.1,0.75)}!8).range(minrq,maxrq2)
		);
		sig = Splay.ar(sig) * env * amp * 2;
		Out.ar(out, sig);
	}).add;

	SynthDef.new(\osSynth, {
		var sig, freq, env, amp=0.6, widht;
		widht = ExpRand([4, 1],[1,4]);
		env = XLine.kr(1, 0.01,(ExpRand(1,3)), doneAction:2);
		freq = XLine.kr(Rand(220,660), 110, widht, doneAction:2);
		sig = Pulse.ar(freq) * env * amp;
		Out.ar(0, sig);
	}).add;

	0.1.wait;

	g = Group.new;
	a = [];

	//OSCdef
	OSCdef.new(\acc, {
		arg msg;
		g.set(
			\detune2, msg[1].linexp(-1000,1000,0.001,70),
			\maxrq2, msg[2].linexp(-1000,1000,0.01,0.5),
			\boost, msg[3].linlin(-500,1500,1,20)
		);
	}, '/acc',n
	);

	OSCdef.new(\buttonA, {
		arg msg;
		if(msg[1] == 1 && (a.size < 4),{
			a = a.add(Synth.new(\balls,
				[
					\freq, exprand(1,8),
					\atk, exprand(2,8),
					\rel, exprand(2,8)
				],
				g
			))
		});
	}, '/buttonA',n
	);

	OSCdef.new(\buttonB, {
		arg msg;
		if(msg[1]==1 && (a.size>0),{
			while({a.size>0}, {
				a.[0].set(\gate, 0);
				a.removeAt(0)});
		});
	}, '/buttonB',n
	);

	OSCdef.new(\accelBang, {
		arg msg;
		if(msg[2] <= -1000,{
			x = Synth(\osSynth);
		});
	}, '/acc',n
	);

	OSCdef.new(\longPressA, {
		arg msg;
		if(msg[1] == 2 && ~last_value == 1,{
			OSCdef(\accelBang).disable;
			~last_value = 0;
			"disable".postln;
		});
	}, '/buttonA',n
	);

	OSCdef.new(\longPressB, {
		arg msg;
		if(msg[1] == 2 && ~last_value == 0,{
			OSCdef(\accelBang).enable;
			~last_value = 1;
			"enable".postln;
		});
	}, '/buttonB',n
	);

}
)   