(

//credit: Eli Fieldsteel
//transcribed from this: https://www.youtube.com/watch?v=ZVTbRNu2BI0

//slick way to open audio settings from SC...
//"open -a 'Audio MIDI Setup'".unixCmd; // execute this to launch it

Server.killAll;
s.boot;

//Server.default.reboot;
ServerOptions.devices;
//Server.default.options.device = "HD 4.50BTNC";
Server.default.options.device = "UMC404HD 192k";
//Server.default.options.device = "Built-in Output";
// Server.default.options.device = "Multi-Output Device";
//Server.default.options.device = "Record/Stream";


//s = Server.local;

//midi stuff
//initialize a midi client
MIDIClient.init;

//connect all the possible inputs
MIDIIn.connectAll;

~decay = 0.8;

/* Not used yet...
~activenotes = nil!128; //make Array of 128 slots, initially with nil objects in to represent nothing

~releasefunction = {|index|
		//release existing note if present already
	if(~activenotes[index].notNil) {
		~activenotes[index].release; //will send gate=0
		~activenotes[index] = nil; //make sure now empty slot ready
	}
};

*/


MIDIdef.noteOn(\noteOn,{
	arg veloc,num,chan, vol;
	[veloc,num,chan].postln;
	//vol = LinLin.kr(veloc,0,127,0,1);
	vol = veloc.linexp(0,127,0.03,1);
	//~bandwidth.postln;


	x = Synth.new(\tone, [\vol,vol, \nharm, veloc.linexp(0,127,1,5), \decay, ~decay, \pan,0.5.rand2, \freq,num.midicps]);

	/*Synth(\ping, [\vol, veloc.linexp(0,127,0.01,1),
		\note, num,
		\harmonics, ~harmonic_channels.asPairs.asAssociations(SortedList).collect{|item| item.value},
		\release, ~release,
		\cutoff, ~cutoff,
		\bandwidth, ~bandwidth
		//\harmonic_channels, ~harmonic_channels
	]);*/

});


MIDIdef.cc(\ccFunc, {
	arg ccNum, chan;
	[ccNum,chan].postln;

	//change room size by tweaking ANY controller
	if(chan == 24) {
		z.set(\room, ccNum.linexp(0,127,0.01,10));
	};


	if(chan == 20) {
		~decay = ccNum.linexp(0,127,0.01,2);
	};

});



// FreeVerb2 - demo synthdef
SynthDef(\FreeVerb2x2, { |out, mix = 0.25, room = 0.15, damp = 0.2, amp = 1.0|
    var signal, signalToCompress;

    signal = In.ar(out, 2);

    ReplaceOut.ar(out,
		//GVerb.ar(signal, 10, 4, 0.5, 0.5, 10, 0.2);

      signalToCompress = FreeVerb2.ar( // FreeVerb2 - true stereo UGen
            signal[0], // Left channel
            signal[1], // Right Channel
            mix, room, damp, amp
        );

	  //probably unnecessary if I compress & normalise after recording...
	  Compander.ar(signalToCompress, signalToCompress,
			thresh: 0.9,
			slopeBelow: 1,
			slopeAbove: 1,
			clampTime:  0.01,
			relaxTime:  0.01,
			mul: 1.2
		);

	); // same params as FreeVerb 1 chn version

}).add;

SynthDef.new(\tone, {

	arg freq=40, nharm=12, detune=0.2, pan=0, vol=1, out=0, decay = 0.1;
	var sig, env;
	//env = EnvGen.kr(Env.adsr(0.5,0.1, 0.5, 1),gate,doneAction: 2);
	env = EnvGen.ar(Env([0,1,0],[0.001,decay]),doneAction:2);

	//env = XLine.kr(1,0,0.5,doneAction: 2);
	pan = freq.linlin(30,4000,-0.5,0.5);


	//sig = Blip.ar(freq * LFNoise1.kr(0.1!16).bipolar(detune.neg, detune).midiratio,nharm);
	//sig = sig + SinOsc.ar(freq) * 0.5;


	sig = SinOsc.ar(freq * LFNoise1.kr(0.1!16).bipolar(detune.neg, detune).midiratio);

	//sig = sig + Saw.ar(freq * LFNoise1.kr(0.1!16).bipolar(detune.neg, detune).midiratio) * 0.5;

	//sig = sig + Pulse.ar(freq * LFNoise1.kr(0.1!16).bipolar(detune.neg, detune).midiratio) * 0.2;
	//sig =  Pulse.ar(freq) * 0.5;

	//sig = Pulse.ar(freq * LFNoise1.kr(0.1!2).bipolar(detune.neg, detune).);


	//assign each of the 16 voices a different amplitude
	sig = sig * LFNoise1.kr(1!16).exprange(0.2,1);

	sig = Splay.ar(sig);
	sig = Balance2.ar(sig[0],sig[1],pan);
	sig = sig * env * vol;

	Out.ar(out,sig);
}).add;

fork {
	3.wait;
// kick it in
z = Synth(\FreeVerb2x2, [\outbus, 0], addAction:\addToTail);
// experiment with some settings
z.set(\room, 8);
//z.set(\mix, 0.25);
//z.set(\damp, 0.2);
}
)


z.set(\damp, 0.3);

// silence
[a, z].do(_.free)