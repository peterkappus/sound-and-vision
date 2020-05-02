(

//credit: Eli Fieldsteel
//transcribed from this: https://www.youtube.com/watch?v=ZVTbRNu2BI0


//midi stuff
//initialize a midi client
MIDIClient.init;

//connect all the possible inputs
MIDIIn.connectAll;


MIDIdef.noteOn(\noteOn,{
	arg veloc,num,chan, vol;
	[veloc,num,chan].postln;
	//vol = LinLin.kr(veloc,0,127,0,1);
	vol = veloc.linexp(0,127,0.03,1);
	//~bandwidth.postln;

	x = Synth.new(\tone, [\vol,vol, \nharm, veloc.linexp(0,127,1,15), \pan,0.5.rand2, \freq,num.midicps]);

	/*Synth(\ping, [\vol, veloc.linexp(0,127,0.01,1),
		\note, num,
		\harmonics, ~harmonic_channels.asPairs.asAssociations(SortedList).collect{|item| item.value},
		\release, ~release,
		\cutoff, ~cutoff,
		\bandwidth, ~bandwidth
		//\harmonic_channels, ~harmonic_channels
	]);*/

});


ServerOptions.devices;
//Server.default.options.device = "HD 4.50BTNC";
Server.default.options.device = "UMC404HD 192k";
//Server.default.options.device = "Built-in Output";
//Server.default.options.device


// FreeVerb2 - demo synthdef
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

SynthDef.new(\tone, {

	arg freq=40, nharm=12, detune=0.2, pan=0, vol=1, out=0;
	var sig, env;
	//env = EnvGen.kr(Env.adsr(0.5,0.1, 0.5, 1),gate,doneAction: 2);
	env = EnvGen.ar(Env([0,1,0],[0.01,1]),doneAction:2);

	//env = XLine.kr(1,0,0.5,doneAction: 2);


	sig = Blip.ar(freq * LFNoise1.kr(0.1!16).bipolar(detune.neg, detune).midiratio,nharm);
	sig = sig * LFNoise1.kr(1!16).exprange(0.2,1);
	sig = Splay.ar(sig);
	sig = Balance2.ar(sig[0],sig[1],pan);
	sig = sig * env * vol;
	Out.ar(out,sig);
}).add;
)

/*
fork{
//5.wait;
//instantiate our freeverb (replacing our usual output)
z = Synth(\FreeVerb2x2, [\outbus, 0], addAction:\addToTail);
//z.set(\mix, 0.23);
//z.set(\damp, 0.4);
}
*/


x = Synth.new(\tone, [\nharm,3, \freq, Pxrand([400,600,800,1200]));

x;
b = {Blip.ar(40,20) * [0.2,0.2]}.play
x = {LFSaw.ar(2300) * 0.2}.play
x.free();
b.free();

s.boot
Server.killAll