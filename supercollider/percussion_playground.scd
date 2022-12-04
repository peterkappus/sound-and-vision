

//Server.default.options.device = "MacBook Pro Speakers";
Server.default.options.outDevice_("Built-in Output");
Server.default.options.outDevice_("UMC404HD 192k");


Server.killAll;
s.boot;

{Splay.ar( SinOsc.ar({rand(438,440)} ! 8), level: 0.2)}.play;

{Splay.ar( SinOsc.ar({ LFNoise2.kr(0.2).exprange(220,880)} ! 8), level: 0.2)}.play;

{Splay.ar( SinOsc.ar({ 440 * [1,2,3,5,7,8,9].choose / [1,2,3,5,7,9,12,14].choose} ! 8), level: 0.2)}.play;

{Splay.ar( SinOsc.ar({ 440 * [1,3,6,8].choose / [1,2,3,4,6,12].choose} ! 8), level: 0.2)}.play;


(


SynthDef(\sawz, { |ffreq = 800, freq = 440, duration = 5 |
	var env = EnvGen.kr(Env.new(times: [duration * 0.4,duration * 0.6]), doneAction: Done.freeSelf);
	var osc =  SinOsc.ar([freq,freq * (1 + Rand.new(0,0.002))]) * 0.5;
	var saw;

	//osc = BPF.ar(osc, 220,0.8);
	osc = LPF.ar(osc, ffreq);

	saw = Saw.ar([freq,freq * (2 + Rand.new(0,0.002))]) * 0.5;

	//osc = BPF.ar(osc, ffreq * 1.25, 1);
	saw = MoogFF.ar(saw,ffreq * 2 * EnvGen.kr(Env.new(times:[duration * 0.4, duration * 0.6])));

	osc = saw + osc;

	Out.ar(0, env * osc * 0.4);
}).add;



/*
SynthDef(\FreeVerb2x2, { |out, mix = 0.25, room = 0.15, damp = 0.2, amp = 1.0|
    var signal;

    signal = In.ar(out, 2);

    ReplaceOut.ar(out,
		//GVerb.ar(signal, 10, 4, 0.5, 0.5, 10, 0.2);
      FreeVerb2.ar( // FreeVerb2 - true stereo UGen
            signal[0], // Left channel
            signal[1], // Right Channel
            mix, room, damp, amp
        );
    ); // same params as FreeVerb 1 chn version

}).add;
*/

fork{
	/*3.wait;
	//instantiate our freeverb (replacing our usual output)
	z = Synth(\FreeVerb2x2, [\outbus, 0, \room, 2], addAction:\addToTail);
	*/

	16.do {
		var f = (66 + [2,4,6,7,8,10].choose).midicps;

		//var duration = [2,3,4,5,7,8].choose;

		//sounds better if they're all uniform
		var duration = 7;

		var filterFreq = 850 + 1500.rand;
		var saw = Synth(\sawz, [duration: duration, freq: f, ffreq: filterFreq]);
		var saw2 = Synth(\sawz, [duration: duration, freq: f * 2/3, ffreq: filterFreq]);
		var saw3 = Synth(\sawz, [duration: duration, freq: f * [1,2,3,5,7,9].choose/[3,4,6,12].choose, ffreq: filterFreq]);
		//5.wait;
		(duration * 0.71).wait;
	}
}



)

//Env.perc(0.001,3).plot;

(

SynthDef(\kick, { | freq = 440 |

	//var freqEnv = EnvGen.kr(Env.perc(0.01,0.2)) * 200;
	var freqEnv = Env([0,1,0.25,0],[0.001,0.08,1.5,0.1],\cubed);
	freqEnv = EnvGen.kr(freqEnv) * 1.2;

	Out.ar(0, 0.8 * EnvGen.kr(Env.perc(0.01,0.5), doneAction: Done.freeSelf) * SinOsc.ar([freqEnv * freq,freqEnv * freq * 1.02]));
}).add;


SynthDef(\snare, { | filterFreq = 1400 |

	//var freqEnv = EnvGen.kr(Env.perc(0.01,0.2)) * 200;
	var freqEnv = Env([0,1,0.25,0],[0.001,0.02,1,0.1],\cubed);
	freqEnv = EnvGen.kr(freqEnv, doneAction: Done.freeSelf) * 2;

	Out.ar(0, EnvGen.kr(Env.perc(0.01,0.5), doneAction: Done.freeSelf) * MoogFF.ar(WhiteNoise.ar([0.2,0.2]),filterFreq,0.01,1.2));
	//Out.ar(0, EnvGen.kr(Env.perc(0.01,0.5)) * Resonz.ar(WhiteNoise.ar([0.2,0.2]),filterFreq,1,1.2));
}).add;


fork {
	2.do {
		3.do {
			Synth(\kick, [freq: 150 + 30.rand]);
			0.25.wait;

			Synth(\snare, [filterFreq: 12500 + 5500.rand]);
			0.25.wait;
		};

		1.do {
			Synth(\kick, [freq: 150 + 30.rand]);
			0.25.wait;

			Synth(\snare, [filterFreq: 12500 + 5500.rand]);
			0.125.wait;

			Synth(\snare, [filterFreq: 10500 + 2500.rand]);
			0.125.wait;
		};
	}
}


//x=60;y=65;a=[x,x,62,x];play{GrainSin.ar(1,Impulse.ar(8),1/9,Dseq(a++[y,64,0]++a++[67,y,0,x,x,72,69,y,y,64,62,70,70,69,y,67,y]).midicps)%4e0}

//play{{a=SinOsc;l=LFNoise2;a.ar(666*a.ar(l.ar(l.ar(0.5))*9)*RLPF.ar(Saw.ar(9),l.ar(0.5).range(9,999),l.ar(2))).cubed}!2} //oscillators argue

//play{f={|o,i|if(i>0,{SinOsc.ar([i,i+1e-4]**2*f.(o,i-1),f.(o,i-1)*1e-4,f.(o,i-1))},o)};f.(60,6)/60}

//a=LFTri;play{|f=99|Pan2.ar(a.ar(f+{200.rand+216}.dup(8),{-2pi.rand+2pi}.dup(8),0.01+a.ar({0.01.rand+0.1}.dup(8),0,0.1)),0)}// #SuperCollider

//play{GVerb.ar(x=LFNoise0.ar(0.1!2,2.5,3.5);SplayAz.ar(2,LatoocarfianL.ar(SampleRate.ir/2+16.rand,x,x,x,x)!66,x),9+x,9*x)*0.001}

)
