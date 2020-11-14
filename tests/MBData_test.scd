~mb = (9..16);
~mbData = IdentityDictionary.new;
~mb.do{|id| ~mbData.put(id, MBData.new(id))};
MBDeltaTrig.mbData = ~mbData;


(
 ~sine = {|dt, minAmp, maxAmp|
    {
        Pan2.ar(
            SinOsc.ar(
                freq: 440,
                mul: EnvGen.kr(Env.perc(0.1, 2.0))
                )
                * dt.linlin(0.0, 1.0, minAmp, maxAmp),
            0
        )
    }.play
 };

 ~testMB = MBDeltaTrig.new(
    speedlim: 0.5,
    threshold: 0.10,
    minibeeID: 9,
    minAmp: -32.dbamp,
    maxAmp: 0.dbamp,
    function: ~sine
    ).play;
)


