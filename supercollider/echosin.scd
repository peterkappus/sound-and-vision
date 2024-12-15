{SinOsc.ar(300)}.play;



(
var pulseWidth = 0.25;

{BPF.ar(Pulse.ar(600,pulseWidth),1200)}.play;

//{BPF.ar(sig,2500)}.play;

//{sig}.play;
//sig.plot;

)

(

//"midi-one-shot.scd".loadRelative;
//"boot.scd".loadRelative;

//Idea, gently modulate the pitch with a kind of tape warble via some LFNoise1?

~bloop = { |note= 70, vel = 0.8 |
	var notes = [1,5,7,9,12,14,16,17];
	//var freq = (Prand(notes,inf).asStream.next + 50).midicps;

	var freq = note.midicps;
	var pulseFreq = LinLin.kr(vel,0,127,0.2,15);
	var sinFeedback = LinLin.kr(vel,0,127,0,pi*0.75);
	//var sinFeedback = vel.linexp(0,127,0,pi/2).value;

	//var pulseFreq = 2;
	var saw = BPF.ar(SawDPW.ar([freq * 3/2,freq]) * LFPulse.kr(pulseFreq)/2,200);
	var sin = SinOscFB.ar([freq,freq * 3/2],sinFeedback) * LFPulse.kr(pulseFreq,0.25)/2;

	var sig = (saw + sin)/2;

	var attack = LinLin.kr(vel,0,127,1,0.0001);
	var release = LinLin.kr(vel,0,127,1,8);
	var amp = LinLin.kr(vel,0,127,0,0.8);
	attack.postln;

	//sig = sin;

	Out.ar(0,
		EnvGen.kr(Env.perc(attack,release), doneAction: Done.freeSelf) * sig * amp;
	);

};

//initialize a midi client
MIDIClient.init;

//connect all the possible inputs
MIDIIn.connectAll;


MIDIdef.noteOn(\noteOn,{
	arg veloc,num,chan, vol;
	//vol = LinLin.kr(veloc,0,127,0,1);
	[veloc,num,chan].postln;

	//a = Synth(\bloop);
	{~bloop.value(num, veloc)}.play;

});


//~connectSynth.value(~bloop);

//a = Synth(\bloop);
//a = Synth(\bloop);


)
