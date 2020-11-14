// trouvé!! => NodeWatcher.register(node_to_monitor)
// Pour panner des fichiers stéréo utiliser Splay.ar => center arg.
// On peux utiliser .register pour appller NodeWatcher avec Synth.

(
fork{

	~sounds = Array.new;
	~relative_path = resolveRelative("");
	~folder = PathName.new(~relative_path+/+"soundfiles");
	~folder.entries.do({
		arg path;
		~sounds = ~sounds.add(Buffer.read(s, path.fullPath));
	});

	SynthDef(\player_mono, {
		|pan=0, amp=0.5, buf, rate=1|
		var sig, mix;
		sig = PlayBuf.ar(1, buf, rate, doneAction:2);
		Out.ar(0, Pan2.ar(sig, pan, amp));
	}).add;

	SynthDef(\player_st, {
		|pan=0, amp=0.5, buf, rate=1|
		var sig;
		sig = PlayBuf.ar(2, buf, rate, doneAction:2);
		Out.ar(0, Splay.ar(sig, 0, amp, center: pan));
	}).add;

	s.sync;

	OSCdef(\one_shot, {
		|msg|
		if (msg[1] == 1 && (x.isPlaying.not), {
			x = Synth(\player_mono, [\buf, ~sounds[0], \amp, 0.5, \pan, 0.0]).register;
		});
	}, "/b1"
	);
}
)


// Stéréo pannig test :
x = Synth(\player_st, [\buf, ~sounds[1], \pan, 0.5]);
x = Synth(\player_st, [\buf, ~sounds[1], \pan, -0.5]);
