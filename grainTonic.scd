(
fork{

/*	GRAIN-TONIC                                               ,----,
                                                           ,/   .`|
  ,----..                                                ,`   .'  :
 /   /   \                        ,--,                 ;    ;     /                      ,--,
|   :     :   __  ,-.           ,--.'|         ,---, .'___,/    ,'  ,---.        ,---, ,--.'|
.   |  ;. / ,' ,'/ /|           |  |,      ,-+-. /  ||    :     |  '   ,'\   ,-+-. /  ||  |,
.   ; /--`  '  | |' | ,--.--.   `--'_     ,--.'|'   |;    |.';  ; /   /   | ,--.'|'   |`--'_       ,---.
;   | ;  __ |  |   ,'/       \  ,' ,'|   |   |  ,"' |`----'  |  |.   ; ,. :|   |  ,"' |,' ,'|     /     \
|   : |.' .''  :  / .--.  .-. | '  | |   |   | /  | |    '   :  ;'   | |: :|   | /  | |'  | |    /    / '
.   | '_.' :|  | '   \__\/: . . |  | :   |   | |  | |    |   |  ''   | .; :|   | |  | ||  | :   .    ' /
'   ; : \  |;  : |   ," .--.; | '  : |__ |   | |  |/     '   :  ||   :    ||   | |  |/ '  : |__ '   ; :__
'   | '/  .'|  , ;  /  /  ,.  | |  | '.'||   | |--'      ;   |.'  \   \  / |   | |--'  |  | '.'|'   | '.'|
|   :    /   ---'  ;  :   .'   \;  :    ;|   |/          '---'     `----'  |   |/      ;  :    ;|   :    :
 \   \ .'          |  ,     .-./|  ,   / '---'                             '---'       |  ,   /  \   \  /
  `---`             `--`---'     ---`-'                                                 ---`-'    `----'
*/



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

	//=> Grain SynthDef with gate and reverb.
	SynthDef(\t_grain, {
		|out = 0, buf, posLo = 0.0, posHi = 1.0, rel = 0.1,
		posRate = 1, posDev = 0.01, trigRate = 100, granDur = 0.1, rate = 1.0,
		panMax = 1, amp = 0.2, interp = 4|

		var trig, pan, pos, bufDur, bufDurSection, posDif, env;

		posDif = posHi - posLo;
		bufDur = BufDur.kr(buf);
		bufDurSection = bufDur * posDif;
		env = EnvGen.kr(Env.perc(0.01, releaseTime: rel), doneAction:2);
		trig = Impulse.kr(trigRate);
		pos = posLo * bufDur +
		(Phasor.ar(0, BufRateScale.kr(buf) * posRate / SampleRate.ir, posLo * bufDur, posHi * bufDur) +
			(TRand.kr(-0.5 * posDev, 0.5 * posDev, trig) * bufDur)).mod(bufDurSection);
		pan = Demand.kr(trig, 0, Dseq([panMax, panMax.neg],inf) * 0.999);
		Out.ar(out, FreeVerb.ar(
			TGrains.ar(2, trig, buf, rate, pos, granDur, pan, 1, interp) * env * amp, mix: 0.45));

	}).add;

	//=> Background sound with more reverb.
	SynthDef(\t_grain2, {
		|out = 0, buf, posLo = 0.0, posHi = 1.0, rel = 0.1,
		posRate = 1, posDev = 0.01, trigRate = 100, granDur = 0.1, rate = 1.0,
		panMax = 1, amp = 0.2, interp = 4, gate=0|

		var trig, pan, pos, bufDur, bufDurSection, posDif, env;

		posDif = posHi - posLo;
		bufDur = BufDur.kr(buf);
		bufDurSection = bufDur * posDif;
		env = EnvGen.kr(Env.adsr(0.01, releaseTime: rel), gate, doneAction:2);
		trig = Impulse.kr(trigRate);
		pos = posLo * bufDur +
		(Phasor.ar(0, BufRateScale.kr(buf) * posRate / SampleRate.ir, posLo * bufDur, posHi * bufDur) +
			(TRand.kr(-0.5 * posDev, 0.5 * posDev, trig) * bufDur)).mod(bufDurSection);
		pan = Demand.kr(trig, 0, Dseq([panMax, panMax.neg],inf) * 0.999);
		Out.ar(out, FreeVerb.ar(
			TGrains.ar(2, trig, buf, rate, pos, granDur, pan, 1, interp) * env * amp, mix: 0.7, room: 1));

	}).add;

	s.sync;
	g = Group.new;
	h = Group.new;
	a = [];
	b = [];

	//launch background sound.
	z = Synth(\t_grain2, [
		\gate, 0,
		\buf, ~sounds[2],
		\amp, 0.25,
		\rate, 1.75,
	], h);

	//initialise global variable:
	~last_value = 0;
	~trame = 0;

	OSCdef(\acc, {
		|msg|
		if (msg[3] >= 1000 && (~last_value == 0) && (a.size <= 1), {

			a.add(Synth.new(\t_grain, [
				\buf, ~sounds[1],
				\amp, 2,
				\rate, rrand(-0.75, -2.0),
				\rel, rrand(1.5, 3.5) ]
			));

			~last_value = 1;
		});

		if (msg[3] <= 0 && (~last_value == 1) && (b.size <= 1), {

			// trigger only one time background sound.
			if (~trame == 0, {z.set(\gate, 1)});

			b.add(Synth.new(\t_grain, [
				\buf, ~sounds[0],
				\amp, 2,
				\rate, rrand(-0.5, -1.5),
				\rel, rrand(1.5, 3.5) ]
			));

			~last_value = 0;
		});

	}, "/acc"
	);

	// some litle modulation.
	OSCdef(\acc_ctrl, {
		|msg|
		g.set(
			\trigRate, msg[2].linlin(-1024, 1024, 200, 30));

	},"/acc"
	);

	// modulation of the baking sound.
	OSCdef(\acc_ctrl2, {
		|msg|
		h.set(
			\trigRate, msg[1].linlin(-1024, 1024, 200, 30),
			\posHi, msg[2].linlin(-1024, 1024, 1, 0));

	},"/acc"
	);
}
)
