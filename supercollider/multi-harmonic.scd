(

//credit: Eli Fieldsteel
//transcribed from this: https://www.youtube.com/watch?v=ZVTbRNu2BI0

//slick way to open audio settings from SC...
//"open -a 'Audio MIDI Setup'".unixCmd; // execute this to launch it


//Server.default.reboot;
ServerOptions.devices;
//Server.default.options.device = "HD 4.50BTNC";
Server.default.options.device = "UMC404HD 192k";
//Server.default.options.device = "Jabra EVOLVE 20 MS";
//Server.default.options.device = "Built-in Output";
//Server.default.options.device = "SC";
//Server.default.options.device = "Multi-Output Device";
//Server.default.options.device = "Record/Stream";

Server.killAll;
s.boot;

//s = Server.local;

//midi stuff
//initialize a midi client
MIDIClient.init;

//connect all the possible inputs
MIDIIn.connectAll;

~decay = 0.8;
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
		~activenotes[i].set(key,value);
	});
};


~isSustained = {
	(~sustainValue > 0);
	//false;
};

MIDIdef.noteOn(\noteOn,{
	arg veloc,num,chan, vol;
	var synth;
	[veloc,num,chan].postln;
	//vol = LinLin.kr(veloc,0,127,0,1);
	vol = veloc.linexp(0,127,0.03,1);
	//~bandwidth.postln;


	~releasefunction.value(num);

	synth = Synth.new(\tone, [\vol,vol, \nharm, veloc.linexp(0,127,1,5), \decay, ~decay, \pan, 0.5.rand2, \freq,num.midicps, \filterFreq, ~filterFreq, \squareVol, ~squareVol, \detune,~detune]);

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

	if(~isSustained.value(0)) {
		//transfer notes to sustained array "notes"
		~notes.add(~activenotes[num]);
	} {
		~releasefunction.value(num);
	}

});


~previousSustainValue;
~detune = 0.2;
~squareVol = 0.5;

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
			~releasefunction.value();
		}
	};

	//change room size by tweaking ANY controller
	if(chan == 24) {
		~fx.set(\room, ccNum.linexp(0,127,0.01,15));
	};


	if(chan == 20) {
		~decay = ccNum.linexp(0,127,0.01,2);
	};

	if(chan == 1) {
		~filterFreq = ccNum.linexp(0,127,200,12000);

		//update held notes
		~broadcastParam.value(\filterFreq,~filterFreq);
	};


	if(chan == 41) {
		~detune = ccNum.linexp(0,127,0.1,1.2);

		//update held notes
		~broadcastParam.value(\detune,~detune);
	};


	if(chan == 21) {
		~fx.set(\delayTime,ccNum.linexp(0,127,0.001,4));
	};

	if(chan == 17) {
		~fx.set(\delayFeedback,ccNum.linexp(0,127,0.25,128));
	};

	if(chan == 20) {
		~squareVol = ccNum.linexp(0,127,0.1,0.8);
	};



});


SynthDef.new(\tone, {

	arg freq=40, nharm=12, filterFreq = 12000, squareVol = 0.5, detune=0.2, pan=0, vol=1, out=0, decay = 0.1, gate=1;
	var sig, env, plunk, plunkEnv;

	//env = EnvGen.kr(Env.adsr(0.5,0.1, 0.5, 1),gate,doneAction: 2);
	//env = EnvGen.ar(Env([0,1,0],[0.001,decay]),doneAction:2);
	env= EnvGen.ar(Env.asr(0.001,1.0,0.25),gate,doneAction:2);


	//env = XLine.kr(1,0,0.5,doneAction: 2);
	//pan = freq.linlin(30,4000,-0.5,0.5);

	//pan = 0;

	//sig = Blip.ar(freq * LFNoise1.kr(0.1!16).bipolar(detune.neg, detune).midiratio,nharm);
	//sig = sig + SinOsc.ar(freq) * 0.5;


	sig = SinOsc.ar(freq * LFNoise1.kr(0.1!16).bipolar(detune.neg, detune).midiratio);

	//harmonic
	//sig = sig +  SinOsc.ar(freq * 3/2 * LFNoise1.kr(0.1!16).bipolar(detune.neg, detune).midiratio) * 0.5;


	//sig = sig + Dust.ar(10,0.25);
	//filter= Resonz.ar(saw,1000,0.1)*amp;

	//~gendy =  Gendy1.ar(5.rand, 6.rand,0.95,0.95,freq/2 *0.99, freq/2 * 1.01, 0.05,0.08) * 0.5;

	//env for filter...
	~filterEnv= 1; //EnvGen.ar(Env.perc(0.05,1,1,-3));

	//sig = sig + RLPF.ar(Resonz.ar(Saw.ar(freq * LFNoise1.kr(0.1!12).bipolar(detune.neg, detune).midiratio), vol.linexp(0,127,4000,17000) * ~filterEnv,0.8),filterFreq,0.3) * 0.8;

	sig = sig + RLPF.ar(Saw.ar(freq * LFNoise1.kr(0.1!12).bipolar(detune.neg, detune).midiratio),(filterFreq + vol.linexp(0,127,200,5000)) * ~filterEnv,0.8) * 0.5;

	//sig = sig + Resonz.ar(Saw.ar(freq * LFNoise1.kr(0.1!12).bipolar(detune.neg, detune).midiratio), (filterFreq + vol.linexp(0,127,100,2000)) * ~filterEnv,0.8) * 0.8;
// +  vol.linexp(0,127,100,1200)


	//square wave octave below.
	sig = sig + (RLPF.ar(Pulse.ar(freq/2), filterFreq,0.5) * 0.5 * squareVol);// * LFNoise1.kr(0.1!2).bipolar(detune.neg, detune));

	//assign each of the 16 voices a different amplitude
	sig = sig * LFNoise1.kr(1!16).exprange(0.2,1);

	sig = Splay.ar(sig);
	sig = Balance2.ar(sig[0],sig[1],pan);
	sig = sig * env * vol;


	//Out.ar(out,Mix.new([sig,plunk]));
	Out.ar(out,sig);

}).add;

// FreeVerb2 - demo synthdef
SynthDef(\FreeVerb2x2, { |out, mix = 0.25, room = 0.15, damp = 0.1, amp = 1.0, delayTime=0.33, delayFeedback=8|
    var signal, signalToCompress;

	//signal = SplayAz.ar(out,In.ar(0, 2));
	signal = In.ar(out, 2);

    ReplaceOut.ar(out,
		//GVerb.ar(signal, 10, 4, 0.5, 0.5, 10, 0.2);

		//signal = signal + CombN.ar(signal, 1.5, {Rand([0.25,0.5,0.75,1.5])}, 3)!2;

		signal = signal + (CombN.ar(signal, 1.5, [delayTime,delayTime*1.25], {delayTime * delayFeedback}) * 0.5);


      signalToCompress = FreeVerb2.ar(
			// FreeVerb2 - true stereo UGen
            signal[0], // Left channel
            signal[1], // Right Channel
            mix, room, damp, amp
        );


	  //probably unnecessary if I compress & normalise after recording...
	  Compander.ar(signalToCompress, signalToCompress,
			thresh: 0.7,
			slopeBelow: 1,
			slopeAbove: 200,
			clampTime:  0.01,
			relaxTime:  0.01,
			mul: 1.2
		);

	); // same params as FreeVerb 1 chn version

}).add;

s.meter;
SynthDef(\rezo,{arg freq=440, amp=0.1, gate=1;
	var saw, filter, env;

	saw= Saw.ar(freq);
	filter= Resonz.ar(saw,1000,0.1)*amp;
	env= EnvGen.ar(Env.asr(0.001,1.0,0.001),gate,doneAction:2);
	Out.ar(0,(filter*env).dup(2))

}).add;


fork {
	3.wait;
// kick it in
	~fx = Synth(\FreeVerb2x2);
//~fx = Synth(\FreeVerb2x2, [\outbus, 0], addAction:\addToTail);
// experiment with some settings
~fx.set(\room, 8);
//z.set(\mix, 0.25);
//z.set(\damp, 0.2);
}
)


//z.set(\damp, 0.3);

// silence
[a, ~fx].do(_.free)