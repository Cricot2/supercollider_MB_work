(
fork{
	// Test Grain.
	// Nouvelle essais avec la microBit et le ble.
	// Cette fois ci avec un GrainBuf et une reverbe.
	// Sonne pas trop mal mais on aimerais pouvoir jouer des gammes tempérées et ou plus prcises.

	// Tester avec TGrains.......................................................................

	/*~port = NetAddr.langPort;
	~cmd = "cd /Users/macbook/Documents/Code_Script/Atelier_Code/Coding_Club/CBMicroBit/ && ./CBMicroBit"+~port;
	~cmd.runInTerminal;*/

	~sounds = Array.new;
	~relative_path = resolveRelative("");
	~folder = PathName.new(~relative_path+/+"soundfiles");
	~folder.entries.do({
		arg path;
		~sounds = ~sounds.add(Buffer.read(s, path.fullPath));
	});

	SynthDef(\buf_grain, { |out, gate = 1, amp = 1, buf, envbuf, rate=1, pos=0, pan|
		var env, freqdev, sig, fx;
		pan = pan;
		env = EnvGen.kr(
			Env([0, 1, 0], [1, 2], \sin, 1),
			gate,
			levelScale: amp,
			doneAction: Done.freeSelf);
		sig = GrainBuf.ar(2, Impulse.kr(10.rand), 1, buf, rate,
				pos, 2, pan, envbuf, interp:2);
		fx = JPverb.ar(sig, size:0.4, high: 0.5);
		Out.ar(out, fx * env)
	}).add;

	0.1.wait;
	g = Group.new;

	OSCdef(\acc, {
		|msg|
		g.set(
			\pos, msg[1].linlin(-1024, 1024, 0, 1),
			\rate, msg[2].linlin(-1024, 1024, -1, -0.2)
		)

	}, "/acc",n
	);

	OSCdef.new(\buttonA, {
		arg msg;
		if(msg[1] == 1 && (a.size < 2),{
			a = a.add(Synth.new(\buf_grain, [\buf, ~sounds.choose, \envbuf, -1], g));
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
}
)


// TEST;
x = Synth(\buf_grain, [\buf, ~sounds[2], \envbuf, -1]);
