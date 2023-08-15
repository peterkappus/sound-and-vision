

//Each of the below will slowly fade in and then out.
// Call each block multiple times to create nice layered sounds


//Brown noise
(
{
	var filterFreq = Rand(150,12500);
	var duration = 40;
	filterFreq.postln;
	EnvGen.ar(Env.perc(40,80),doneAction: Done.freeSelf) * LPF.ar(BrownNoise.ar([LFNoise1.kr(0.1,0.2,0.4),LFNoise1.kr(0.1,0.2,0.4)]),LFNoise2.kr(0.5,0.8,filterFreq)) * 0.3;


}.play;
)



// Crackling Dust
(
{
	BPF.ar(EnvGen.ar(Env.perc(10,20),doneAction: Done.freeSelf) * Dust.ar([20,19],0.9),Rand(500,12500),0.05)
}.play;
)


//Sine waves (play with the ratio in the frequency. e.g. 3/12, 5/12, 4/12, 7/12, etc)

(
{
	var duration = 10;
	var filterFreq = Rand(150,12500);
	var freq = 440 * 2 * 1/12;
	var diff = Rand(0.001,0.002);

	//LFNoise2.kr(0.05,0.1,filterFreq);
	EnvGen.ar(Env.perc(duration, duration),doneAction: Done.freeSelf) * LPF.ar(SinOsc.ar([freq * (1-Rand(0.01,diff)), freq * (1+Rand(0.01,diff))]),filterFreq) * 0.3;

}.play;
)

s.meter;
s.count;
