(

Server.killAll;

//reboot a fresh server
s.boot;

//mapping of param names to midi channels (must match info below)
~paramsToChans = Dictionary.newFrom([
	\filterFreq,17,
	\detuneAmt,41
]);

~noteOnSynth = \iter;

~controllers = nil!100; //an array to hold controller data (one slot per channel)

// array using channel Id's for indices, each slot contains a dictionary with min, max, current value, and arg name to pass into synth
~controllers[~paramsToChans.at(\filterFreq)] = Dictionary.newFrom([\min, 200,\max, 8000,\current, 1200, \argName,\filterFreq]);
~controllers[~paramsToChans.at(\detuneAmt)] = Dictionary.newFrom([\min, 1.001,\max, 1.2,\current, 1.02, \argName,\detuneAmt]);

this.executeFile(Document.current.dir ++ "/utils.scd");

//controller mapping



SynthDef.new(\iter, {
	arg freq = 40, vol = 1, filterFreq = 200, detuneAmt = 0.7, pan = 0;
	var temp, sum, env;
	//var addFreq = LFNoise0.kr(10).range(800,1600);

	sum = 0;
	env = EnvGen.kr(
		Env.perc(0.01, {Rand(1,4)} , 1, -2),
		doneAction:2
	);

	20.do {
		temp = VarSaw.ar(
			freq * {Rand(detuneAmt,detuneAmt.reciprocal)}!2,
			{Rand(0.0, 1.0)}!2,
			{ExpRand(0.005, 0.05)}!2
		);
		sum = sum + temp;
	};


	sum = sum * 0.05 * env * vol;

	sum = RLPF.ar(sum,filterFreq);

	sum = Balance2.ar(sum[0],sum[1],pan);

	Out.ar(0,sum);
}).add;


//Synth.new(\iter,[\freq, [30,68,57,45,66,52,42,56].choose.midicps]);


//0.5.reciprocal;


)