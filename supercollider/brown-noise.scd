

//Each of the below will slowly fade in and then out.
// Call each block multiple times to create nice layered sounds



s.scope;
s.freqscope;

(

var signal;
//signal = { SinOsc.ar(MouseX.kr(220, 880)) * 0.2 };

signal = {(Saw.ar(400) + Saw.ar(100)) * 0.2};

// Plot the signal
{signal.value}.plot(0.1);

// Play the signal
{signal.value}.play;

)


{ SinOsc.ar(MouseX.kr(220, 880)) * 0.2 }.play.plot;

{Blip.ar(100,9)}.play;

{XLine.kr(800,100,5)}.plot

{(SinOsc.ar(800) + (20 *  LFNoise2.kr(3000,1))) * 0.12}.play;

(

~notes = [55,62,65,67,74,79,82,47,84,86];

//automatically trigger random sounds at random times
p.stop;

p = Pbind(
	\type, \note,
	\instrument, Prand([\dust,\bell,\bell,\sin,\bish,\bish,\bish,\sin,\dust,\sea,\sea,\sin],inf).asStream.trace,
	\midinote, Prand(~notes,inf).asStream,
	\release, Prand([3,5,10],inf).asStream,
	//\dur, Prand([1,2,0.5,1,0.25,8,4,1,3],inf).asStream,
	\dur, Prand([2,8,4,1,3],inf).asStream,
).play;


)


//Synth.new(\bish);

//stop the automated triggering
//p.stop;

(

SynthDef.new(\bish, { |out, release=4, freq=440|
	//Out.ar(out, BPF.ar(EnvGen.ar(Env.perc(), doneAction: Done.freeSelf) * SinOsc.ar([Rand(200,12000),Rand(200,12000)]) * 0.2, Rand(800,14000), 0.3));
	freq = freq * Prand([0.5,1,2,3,5,9,4,8,16,32],inf).asStream;
	//LinLin.kr(freq,230,587,20,18000);
	Out.ar(out, Resonz.ar(EnvGen.ar(Env.perc(releaseTime: release, curve: -4), doneAction: Done.freeSelf) * PinkNoise.ar() * [0.5,0.5], freq,0.2 ));
}).add;

)


(

w = Window.new("Hello!");

w.view.keyDownAction={
	arg view,char;
	var synthSymbol;

	synthSymbol = switch(char,
		$1,\sea,
		$2,\dust,
		$3,\bell,
		$4,\bish,
		\sin
	);


	synthSymbol.postln;
	Synth.new(synthSymbol,[\freq,Prand(~notes,inf).asStream.midicps, \release, Prand([2,3,5,10],inf).asStream]);


};

w.front;


o = OSCFunc({ |msg| msg.postln }, '/tr', s.addr);
//o.free;

)


(
// Synths

//simple sine bell
SynthDef.new(\bell, { |out, freq = 440, release = 2, sig|

	var octave = Demand.kr(Impulse.kr(0), 0, Dxrand([1,4,2,3/2,4],inf));
	//var lfo = SinOsc.kr(XLine.kr(1,5,Rand(2,5)),mul:XLine.kr(0.5,5,2));

	//random octave
	freq = freq / octave;


	sig = EnvGen.ar(Env.perc(0.01,release), doneAction: Done.freeSelf) *  SinOsc.ar([freq,freq * 3/4 ] ) * 0.1;

	Out.ar(out,sig);

}).add;

//Synth.new(\bell, [\freq, 800]);

)



//Brown noise
(

SynthDef.new(\sea, { | out, filterFreq, attack, release, bandwidth |

	filterFreq = Rand(50,12500);// + LFNoise2.ar(0.2,1,200);
	attack = Rand(7,50);
	release = Rand(10,60);
	bandwidth = Rand(0.1,0.9);

	//~env = Env.new(levels: [0,1,0], times: [attack,Rand(3,20),release]);

	//add a slow warble...
	filterFreq = filterFreq + (filterFreq * 0.2 * LFNoise2.kr(0.1));

	//try replacing LPF w/ Resonz
	Out.ar(out, EnvGen.ar(Env.perc(attack,release), doneAction: Done.freeSelf) * Resonz.ar(BrownNoise.ar([LFNoise1.kr(0.1,0.2,0.4),LFNoise1.kr(0.1,0.2,0.4)]),LFNoise2.kr(0.5,0.8,filterFreq),bandwidth) * 0.5);

}
).add;
)


// Crackling Dust
(
SynthDef.new(\dust, { | out, filterFreq, attack, release, mul, q, rq |

	var sig;
	filterFreq = Rand(150,14500);
	attack = Rand(10,40);
	release = Rand(30,100);
	mul = 0.3;
	q = Rand(0.1,0.9);
	rq = 0.7;


	sig =  EnvGen.ar(Env.perc(attack,release),doneAction: Done.freeSelf) * Dust.ar([20,19],mul);


	//BPF.ar(sig,filterFreq,rq);

	sig = Resonz.ar(sig, filterFreq,q);

	Out.ar(out,sig);
	//RLPF.ar(sig, filterFreq,);
	//BMoog.ar(sig,filterFreq,0.01,2.5,0.9);

}).add;
)


//Slow sines in harmonic intervals
(
SynthDef.new(\sin, { | out, freq=440, harm, filterFreq, attack, release, mul, q, rq |
	var diff = Rand(0.001,0.002);
	var lfoRate = Rand(0.05,5);
	var sig;

	//var lfo = SinOsc.kr(XLine.kr(1,3,Rand(0.2,5)),mul:XLine.kr(0.1,0.2,10));

	//var octive = [0.5];

	attack = Rand(3,20);
	release = Rand(10,80);
	filterFreq = Rand(150,14000);

	harm = Demand.kr(Impulse.kr(0), 0, Dxrand([1/8,1/3,1/4,0.25,0.5,1,2,3,4,2.5,5,6,7,8,9,10,12,16], inf));


	freq = freq/8 * harm;
	//add a slow warble...
	freq = freq + (freq/16 * LFNoise2.kr(0.2));

	sig =
	//LFNoise2.kr(0.05,0.1,filterFreq);
	Out.ar(out, EnvGen.ar(Env.perc(attack, release),doneAction: Done.freeSelf) * LPF.ar(SinOsc.ar([freq * (1-Rand(0.01,diff)), freq * (1+Rand(0.01,diff))]),filterFreq) * 0.1 * SinOsc.kr(lfoRate));


}).add;
)

(
// when using with musicbox.scd
// ~goArp.value;
)

s.meter;
s.boot;
