(

//credit: Eli Fieldsteel
//transcribed from this: https://www.youtube.com/watch?v=ZVTbRNu2BI0

//slick way to open audio settings from SC...
//"open -a 'Audio MIDI Setup'".unixCmd; // execute this to launch it


//Server.default.reboot;
ServerOptions.devices;
//Server.default.options.device = "HD 4.50BTNC";
//Server.default.options.device = "UMC404HD 192k";
//Server.default.options.device = "Jabra EVOLVE 20 MS";
//Server.default.options.device = "Built-in Output";

//aggregated device provides stereo for streaming [0,1] AND 4 outpus of U-Phoria [2,3,4,5]
Server.default.options.device = "SC";
s.options.numOutputBusChannels=4; //4 channels for UMC404HD + 2 channels for BlackHole audio driver

//Server.default.options.device = "Multi-Output Device";
//Server.default.options.device = "Record/Stream";

// Not using this, yet...
/*
//cleanup
Pdef.all.do(_.clear);
Pbindef.all.do(_.clear);
~wt_buf.do(_.free);
t.stop;

//initialization
s = Server.local;
t = TempoClock.new(90/60).permanent_(true);
s.newBusAllocators;
~rbus = Bus.audio(s,2);
*/

//kill any running server
Server.killAll;

//reboot a fresh server
s.boot;

// **** MIDI SETUP ***

//initialize a midi client
MIDIClient.init;

//connect all the possible inputs
MIDIIn.connectAll;

~filterFreq = 8000;
~sustainValue = 0;
~fx;


~delayTime = 0.33;

~activenotes = nil!128; //make Array of 128 slots, initially with nil objects in to represent nothing

~notes = List.new();

~notes.size;

~releasefunction = {|index|
	//called without an argument means we've released the sustain pedal.
	if(index.isNil){
		//iterate through all notes and release each one

		for(0,~notes.size-1, {|i|
			~notes.pop().release;
		});

		/*for(0,127, {|i|
		~activenotes[i].release; //will send gate=0
		//~activenotes[i] = nil; //make sure now empty slot ready
		});*/

	} {
		//release existing note if present already
		if(~activenotes[index].notNil) {
			~activenotes[index].release; //will send gate=0
			~activenotes[index] = nil; //make sure now empty slot ready
		}
	}
};

~broadcastParam = {|key, value|

	//update all sustained notes
	for(0,~notes.size-1, {|i|
		~notes[i].set(key,value);
	});

	//and any we're just playing...
	for(0,~activenotes.size-1, {|i|
		if(~activenotes[i].notNil) {
			~activenotes[i].set(key,value);
		}
	});
};


~isSustained = {
	(~sustainValue > 0);
};

MIDIdef.noteOn(\noteOn,{
	arg veloc,num,chan, vol;
	var synth;
	[veloc,num,chan].postln;
	//vol = LinLin.kr(veloc,0,127,0,1);
	vol = veloc.linexp(0,127,0.03,1);
	//~bandwidth.postln;


	//~releasefunction.value(num);

	synth = Synth.new(\tone, [
		\vol,vol,
		\nharm, veloc.linexp(0,127,1,5),
		\pan, 0.8.rand2,
		\freq,num.midicps,
		\filterFreq, ~filterFreq,
		\squareVol, ~squareVol,
		\detune,~detune,
		\attack, ~attack,
		\release, ~release
	]);

	//synth = Synth.new(\randHarm, [\freq, num.midicps]);


	//num.midicps.postln;

	//put active note in array; function above tidied any existing note on this key
	~activenotes[num] = synth;

	//Synth(\sound,[\freq,midinote.midicps,\amp,velocity/127.0]);


	/*Synth(\ping, [\vol, veloc.linexp(0,127,0.01,1),
		\note, num,
		\harmonics, ~harmonic_channels.asPairs.asAssociations(SortedList).collect{|item| item.value},
		\release, ~release,
		\cutoff, ~cutoff,
		\bandwidth, ~bandwidth
		//\harmonic_channels, ~harmonic_channels
	]);*/


});

//must also look for note offs as indicated end of held note
MIDIdef.noteOff(\noteOff,{
	arg src,num,chan, vol;

	//if we release a note but the sustain pedal is pressed,
	//then transfer these notes to a sustained array to release when we release the pedal
	if(~isSustained.value(0)) {
		~notes.add(~activenotes[num]);
	} {
		//otherwise, just release as normal
		~releasefunction.value(num);
	}

});


~previousSustainValue;
~detune = 0.2;
~squareVol = 0;
~release = 0.001;

MIDIdef.cc(\ccFunc, {
	arg ccNum, chan;
	[ccNum,chan].postln;

	//sustain pedal
	if(chan == 64) {
		//greater than 100...
		~previousSustainValue = ~sustainValue;
		~sustainValue = ccNum;

		//are we letting go?
		if(~sustainValue < ~previousSustainValue) {
			//release all sustained notes
			~releasefunction.value();
		}
	};

	if(chan == 20) {
		~fx.set(\room, ccNum.linexp(0,127,0.01,30));
	};

	if(chan == 19) {
		~filterFreq = ccNum.linexp(0,127,200,12000);

		//update held notes
		~broadcastParam.value(\filterFreq,~filterFreq);
	};

	//central fader
	if(chan == 41) {
		~detune = ccNum.linexp(0,127,0.1,1.2);

		//update held notes
		~broadcastParam.value(\detune,~detune);
	};

	if(chan == 17) {
		~fx.set(\delayTime,ccNum.linexp(0,127,0.0001,4));
	};

	if(chan == 18) {
		~fx.set(\delayFeedback,ccNum.linexp(0,127,0.25,1280));
	};


	if(chan == 23) {
		~fx.set(\delayMix,ccNum.linexp(0,127,0.025,0.65));
	};

	if(chan == 24) {
		~squareVol = ccNum.linexp(0,127,0.001,0.6);

		//update held notes
		~broadcastParam.value(\squareVol,~squareVol);
	};

	if(chan == 21) {
		~attack = ccNum.linexp(0,127,0.0001,5);
	};

	if(chan == 22) {
		~release = ccNum.linexp(0,127,0.05,10);
		//update held notes
		~broadcastParam.value(\release,~release);
	};


});


SynthDef.new(\tone, {

	arg freq=40, nharm=12, filterFreq = 12000, squareVol = 0, detune=0.2, pan=0, vol=1, out=0,gate=1, attack = 0.001, release= 2.5;
	var sig, env, plunk, plunkEnv, sum, temp;

	env= EnvGen.ar(Env.asr(attack,1.0,release),gate,doneAction:2);

	//pan = freq.linlin(30,4000,-0.5,0.5);

	sig = 0;
	//sig = Blip.ar(freq * LFNoise1.kr(0.1!16).bipolar(detune.neg, detune).midiratio,nharm);
	//sig = sig + SinOsc.ar(freq) * 0.5;


	//sig = SinOsc.ar(freq * LFNoise1.kr(0.1!16).bipolar(detune.neg, detune).midiratio) * 0.5;



	sig = LFTri.ar(freq) * 0.5;
	//sig = LFSaw.ar(freq) * 0.5;
	//sig = SinOsc.ar(freq * 2.5/3) * 0.2;
	//sig = sig +  SinOsc.ar(freq * 7/3) * 0.2;
	//sig = sig +  LFTri.ar(freq * 5/3) * 0.1;

	//harmonic
	sig = sig +  SinOsc.ar(freq * LFNoise1.kr(0.1!16).bipolar(detune.neg, detune).midiratio) * 0.5;


	//sig = sig + Dust.ar(10,0.25);
	//filter= Resonz.ar(saw,1000,0.1)*amp;

	//~gendy =  Gendy1.ar(5.rand, 6.rand,0.95,0.95,freq/2 *0.99, freq/2 * 1.01, 0.05,0.08) * 0.5;

	//env for filter...
	//~filterEnv= 1; //EnvGen.ar(Env.perc(0.05,1,1,-3));

	//~filterEnv= EnvGen.ar(Env.perc(0.5,0.2,1,-3));

	//sig = sig + RLPF.ar(Resonz.ar(Saw.ar(freq * LFNoise1.kr(0.1!12).bipolar(detune.neg, detune).midiratio), vol.linexp(0,127,4000,17000) * ~filterEnv,0.8),filterFreq,0.3) * 0.8;

	//sig = sig + RLPF.ar(Saw.ar(freq * LFNoise1.kr(0.1!6).bipolar(detune.neg, detune).midiratio),(filterFreq + vol.linexp(0,127,200,5000)) * ~filterEnv,0.2) * 0.4;

	sig = sig + Resonz.ar(Saw.ar(freq * LFNoise1.kr(0.1!12).bipolar(detune.neg, detune).midiratio), (filterFreq + vol.linexp(0,127,100,2000)) * ~filterEnv,0.8) * 0.8;
// +  vol.linexp(0,127,100,1200)


	//square wave octave below.
	//sig = sig + (RLPF.ar(Pulse.ar(freq/2), filterFreq,0.5) * 0.5 * squareVol);// * LFNoise1.kr(0.1!2).bipolar(detune.neg, detune));

	//sig = sig + (RLPF.ar(Pulse.ar(freq/2 * LFNoise1.kr(0.1!2).bipolar(detune.neg, detune).midiratio), filterFreq,0.5) * 0.3 * squareVol);// * LFNoise1.kr(0.1

	/*
	10.do {
		sum = 0;
		temp = VarSaw.ar(
			freq * {Rand(0.99,1.01)}!2,
			{Rand(0.0,1.0)}!2,
			{ExpRand(0.005,0.05)}!2
		);
		sum = sum + temp;
	};
	sig = sum * 0.5 * env;
	*/


	//assign each of the 16 voices a different amplitude
	//sig = sig * LFNoise1.kr(1!16).exprange(0.2,1);

	sig = Splay.ar(sig);
	sig = Balance2.ar(sig[0],sig[1],pan);
	sig = sig * env * vol;


	sig = LeakDC.ar(sig);


	//Out.ar(out,Mix.new([sig,plunk]));
	Out.ar(out,sig);

}).add;


//https://www.youtube.com/watch?v=fAXETAyrv8s&list=PLPYzvS8A_rTaNDweXe6PX4CXSGq4iEWYC&index=6
SynthDef(\randHarm, {
	arg out = 0, gate = 1, freq = 440;
	var sig, amp, env;
	env= EnvGen.ar(Env.asr(0.001,1.0,0.25),gate,doneAction:2);
	amp = SinOsc.kr({ExpRand(0.2,12)}!8).range(0.1);
	sig = SinOsc.ar({ExpRand(freq,freq * 2.5)}!8);
	sig = sig * amp * env;
	sig = Splay.ar(sig) * 0.5;
	Out.ar(0,sig);
}).add;



// FreeVerb2 - demo synthdef
SynthDef(\FreeVerb2x2, {

	arg out, mix = 0.25, room = 0.15, damp = 0.1, amp = 1.0, delayMix = 0.7, delayTime=0.33, delayFeedback=8;

    var signal, signalToCompress;

	//signal = SplayAz.ar(out,In.ar(0, 2));
	signal = In.ar(out, 2); //Grab up to 20 channels in case we have multiple devices (see the SC aggregated device)

	//use [0,2] to
	ReplaceOut.ar([0,2],
		//GVerb.ar(signal, 10, 4, 0.5, 0.5, 10, 0.2);

		//stereo delay
		//signal = signal + (CombN.ar(signal, 1.5, [delayTime,delayTime*1.25], {delayTime * delayFeedback}) * delayMix);


		signalToCompress = FreeVerb2.ar(
			// FreeVerb2 - true stereo UGen
            signal[0], // Left channel
            signal[1], // Right Channel
            mix, room, damp, amp
        );

	  //probably unnecessary if I compress & normalise after recording...
	  Compander.ar(signalToCompress, signalToCompress,
			thresh: 0.5,
			slopeBelow: 1,
			slopeAbove: 0.0001,
			clampTime:  0.01,
			relaxTime:  0.01,
			mul: 1;
		);

	); // same params as FreeVerb 1 chn version

}).add;


//s.meter(5,4);

//unused...
SynthDef(\rezo,{arg freq=440, amp=0.1, gate=1;
	var saw, filter, env;

	saw= Saw.ar(freq);
	filter= Resonz.ar(saw,1000,0.1)*amp;
	env= EnvGen.ar(Env.asr(0.001,1.0,0.001),gate,doneAction:2);
	Out.ar(0,(filter*env).dup(2))

}).add;


//fork a new process for our reverb... can't remember why.
fork {
	3.wait;
// kick it in
	~fx = Synth(\FreeVerb2x2);
//~fx = Synth(\FreeVerb2x2, [\outbus, 0], addAction:\addToTail);
// experiment with some settings
//~fx.set(\room, 1);
//z.set(\mix, 0.25);
//z.set(\damp, 0.2);
};



//player...
/*
~p = Pbind(
        // the name of the SynthDef to use for each note
    \instrument, \tone,
        // MIDI note numbers -- converted automatically to Hz
    \midinote, Pseq([60, 65, 72], inf),
        // rhythmic values
    \dur, Pseq([0.10], inf),
	\vol, 0.1
).play;
*/





)


//z.set(\damp, 0.3);

// silence
[a, ~fx].do(_.free)