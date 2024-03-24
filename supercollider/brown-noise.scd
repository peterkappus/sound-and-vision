

//Each of the below will slowly fade in and then out.
// Call each block multiple times to create nice layered sounds


//Brown noise
(
{
	var filterFreq = Rand(150,12500);
	var attack = Rand(15,50);
	var release = [20,40,80].choose;
	filterFreq.value;
	EnvGen.ar(Env.perc(attack,release),doneAction: Done.freeSelf) * LPF.ar(BrownNoise.ar([LFNoise1.kr(0.1,0.2,0.4),LFNoise1.kr(0.1,0.2,0.4)]),LFNoise2.kr(0.5,0.8,filterFreq)) * 0.3;


}.play;
)



// Crackling Dust
(
{
	var filterFreq = Rand(150,14500);
	var attack = Rand(5,40);
	var release = Rand(30,100);
	var mul = 0.3;
	var q = 1.5;
	var rq = 0.7;

	var sig = EnvGen.ar(Env.perc(attack,release),doneAction: Done.freeSelf) * Dust.ar([20,19],mul);

	BPF.ar(sig,filterFreq,rq);
	//Resonz.ar(sig, filterFreq,0.5);
	//RLPF.ar(sig, filterFreq,0.12);
	//BMoog.ar(sig,filterFreq,0.01,2.5,0.9);

}.play;
)


//Sine waves (play with the ratio in the frequency. e.g. 3/12, 5/12, 4/12, 7/12, etc)

(
{
	var attack = Rand(5,40);
	var release = Rand(20,80);

	var filterFreq = Rand(150,12500);
	var freq = 440 * 4 * 1/12;
	var diff = Rand(0.001,0.002);

	//LFNoise2.kr(0.05,0.1,filterFreq);
	EnvGen.ar(Env.perc(attack, release),doneAction: Done.freeSelf) * LPF.ar(SinOsc.ar([freq * (1-Rand(0.01,diff)), freq * (1+Rand(0.01,diff))]),filterFreq) * 0.2;

}.play;
)

(
// when using with musicbox.scd
// ~goArp.value;
)

s.meter;
s.count;
