//MM Eli Fieldsteel's Reverb implementation. (with ServerTree)
//It actually sounds better than Freeverb2.

//My interface options. Change at will.

(
//Server.local.options.device = "ASIO : ASIO PreSonus FireStudio";
Server.local.options.sampleRate=48000;
Server.local.options.hardwareBufferSize=128;
)

//Evaluate reverb.

((
	SynthDef(\verb, {
		|in, predelay=1, revtime=10, lpf=4500,mix=0.5,amp=1,out=0|
		var dry,wet,temp,sig;
		dry = In.ar(in, 2);
		temp = In.ar(in, 2);
		wet=0;
		temp=DelayN.ar(temp, 0.2, predelay);
		32.do {temp=AllpassN.ar(temp, 0.05, {Rand(0.001,0.05)}!2,revtime);
			temp=LPF.ar(temp,lpf);
			wet=wet+temp;
		};
		sig=XFade2.ar(dry,wet,mix*2-1,amp);
		Out.ar(out,sig);
	}).add;
);
)

//After evaluating this. You can hit "CMD+." or even restart the server and the verb will be there. (You'll need to re evaluate only if you restart SC)
(
~reverbBus = Bus.audio(s,2);
~createReverb={~reverbSynth=Synth(\verb, [\in, ~reverbBus])};
ServerTree.add(~createReverb);
)

ServerTree.removeAll;//If you wanna reset the Tree. (aka, no more verb) or prior to change verb paramters.

//For example. Evaluate this then hit "CMD+." you'll hear the reverb tail is now shorter.
(
ServerTree.removeAll;
~createReverb={~reverbSynth=Synth(\verb, [in: ~reverbBus,  revtime: 0.01])};
ServerTree.add(~createReverb);
)

//The Synth.
(
SynthDef(\tri, {
	|gate=1, amp=1, freq=200, panpos=0, envdur=1|
	var sig, pan;
	sig=LFTri.ar(freq,0,EnvGen.ar(Env.perc(0.001,envdur,amp,-15),gate,doneAction:2));
		pan=Pan2.ar(sig,panpos,1);
		Out.ar(~reverbBus,pan)
}).add
)

//Test your synth.
Synth(\tri, [\panpos, 0]);