
(
//initialize a midi client
MIDIClient.init;

//connect all the possible inputs
MIDIIn.connectAll;


MIDIdef.noteOn(\noteOn,{
	arg veloc,num,chan, vol;
	//vol = LinLin.kr(veloc,0,127,0,1);
	[veloc,num,chan].postln;

	//a = Synth(\bloop);
	~bloop.value(num, veloc);

});

//};

MIDIdef.cc(\cc,{
	arg val, num;
	num.postln;
	{
		var filterFreq = Rand(150,14500);
	var attack = Rand(5,40);
	var release = Rand(30,100);
	var mul = 0.3;
	var q = 1.5;
	var rq = 0.7;

	var sig = EnvGen.ar(Env.perc(attack,release),doneAction: Done.freeSelf) * Dust.ar([20,19],mul);

	BPF.ar(sig,filterFreq,rq);
	}.play;
});
)