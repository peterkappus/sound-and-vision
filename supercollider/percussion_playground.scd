

//Server.default.options.device = "MacBook Pro Speakers";
Server.default.options.outDevice_("Built-in Output");
Server.killAll;
s.boot;

(


SynthDef(\sawz, { |ffreq = 800, freq = 440 |
	var env = EnvGen.kr(Env.new(times: [3,4]), doneAction: Done.freeSelf);
	var osc =  SinOsc.ar([freq,freq * (1 + Rand.new(0,0.002))]) * 0.5;
	var saw;

	//osc = BPF.ar(osc, 220,0.8);
	osc = LPF.ar(osc, ffreq);

	saw = Saw.ar([freq,freq * (2 + Rand.new(0,0.002))]) * 0.5;

	//osc = BPF.ar(osc, ffreq * 1.25, 1);
	saw = MoogFF.ar(saw,ffreq * 8 * EnvGen.kr(Env.new(times:[3,4])));

	osc = saw + osc;

	Out.ar(0, env * osc * 0.4);
}).add;


fork {
	8.do {
		var f = (66 + 12.rand).midicps;
		var ffreq = 850 + 1500.rand;
		var saw = Synth(\sawz, [freq: f, ffreq: ffreq]);
		var saw2 = Synth(\sawz, [freq: f * 2/3, ffreq: ffreq]);
		var saw3 = Synth(\sawz, [freq: f * 5/[3,4,6,12].choose, ffreq: ffreq]);
		5.wait;
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
	16.do {
		7.do {
			Synth(\kick, [freq: 250 + 30.rand]);
			0.25.wait;

			Synth(\snare, [filterFreq: 12500 + 5500.rand]);
			0.25.wait;
		};

		1.do {
			Synth(\kick, [freq: 250 + 30.rand]);
			0.25.wait;

			Synth(\snare, [filterFreq: 12500 + 5500.rand]);
			0.125.wait;

			Synth(\snare, [filterFreq: 12500 + 5500.rand]);
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
