

{SinOsc.ar(800, mul: 100).tanh * 0.1}.plot;
{LFSaw.ar(1200) * SinOsc.ar(440)}.play;
{BPF.ar(Hasher.ar(Sweep.ar), 2320, 0.3) * Env.perc(1e-3,0.02).ar * 10.dbamp}.play;

{WhiteNoise.ar}.play;


// { SinOsc.ar(20, mul: MouseX.kr(1, 100, 1)).tanh * 0.1 }.play;

(
SynthDef(\kick, {
	var snd;
	snd = SinOsc.ar(20 * (1 + Env.perc(0,0.03).ar));
	snd = snd.tanh;
	snd = snd * (1 + (3 * Env.perc(0,0.05).ar));
	snd = snd + (BPF.ar(Hasher.ar(Sweep.ar), 8320, 0.3) * Env.perc(0.001, 0.01).ar);
	snd = snd * Env.perc(0,0.3).ar(Done.freeSelf);
	snd = snd * -10.dbamp;
	snd = snd ! 2;
	Out.ar(\out.kr(0), snd);
}).add;

Synth(\kick);

)

	Synth(\kick);



(

	SynthDef.new(\blip,
		{ | out, freq = 440 |

		var sig, wobble, env;

		//reverse envelope
		~rev = Env.perc(1,0.01,1,4);

		//normal nvelope
		~fwd = Env.perc(0.01,1.5,1,-4);

		env = EnvGen.kr(~fwd, doneAction:Done.freeSelf);

		//sig = SinOsc.ar(freq/4, 5) * 0.5;

		wobble = [(LFNoise2.kr(100) * 20), (LFNoise2.kr(100) * 20)];

		//sig = SinOsc.ar(freq/2 + wobble, mul: XLine.kr(100,1,0.3)).tanh * 0.25 ;
		//sig =  (LFSaw.ar(freq*12/5) * SinOsc.ar(freq + wobble/2)).tanh * 0.5 ;
		//sig =  (LFSaw.ar(freq/2 + wobble/2) * SinOsc.ar(freq/2)) * 0.5 ;

		sig =   SinOsc.ar(freq + wobble/2) * 0.5 ;

		//cruncy attack
		//sig = sig + BPF.ar(Hasher.ar(Sweep.ar), 2320, 0.3) * Env.perc(1e-3,0.02).ar;


		//sig = BPF.ar(WhiteNoise.ar(),freq,0.02);
		sig = sig + Resonz.ar(PinkNoise.ar ! 2,freq  * 2,0.05) * 0.75;
		//sig = sig * -10.dbamp;


		Out.ar(out, env * sig);

		}).add;

)

(

~notes=[55,62,65,67,74,79,82,47,84,86];

m.stop;

m = Pbind(\type, \note,
	\instrument, \blip,
	\midinote, Prand(~notes,inf).asStream,
	//\freq, Pseq([400,600,900],inf),
	\dur, 0.25
).play;





)



