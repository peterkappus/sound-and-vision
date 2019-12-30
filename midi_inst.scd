(
Server.default.options.device = "BlackHole 16ch";
//Server.default.options.device = "Built-in Output";

//ServerOptions.devices;

//handle large delay sizes
//s.options.memSize= 8192*2;
s.options.memSize = 8192*8;
s.reboot;


//initialize a midi client
MIDIClient.init;

//connect all the possible inputs
MIDIIn.connectAll;

~cutoff = 14000;
~release = 0.5;


~cutoff_chan = 1; //1 = modwheel;
~release_chan = 24;
~reverb_chan = 23;

//harmonics
//~channels = [17,18,19,20,21,22];

// A dictionary of channels with one for each harmonic voice.
// The keys are the channel IDs and values are the harmonic (multiple of the fundamental)
// defaults to 1, goes up to 12 (for now)

~harmonic_channels_start_index = 17;
~harmonic_channels = Dictionary.new;
6.do{
	arg i;
	~harmonic_channels[~harmonic_channels_start_index+i] = 1;
};


//~harmonic_channels.asPairs.asAssociations(SortedList).collect{|item| item.value};

MIDIdef.cc(\ccFunc, {
	arg ccNum, chan;
	[ccNum,chan].postln;
	if(chan == ~cutoff_chan) {
		~cutoff = LinLin.kr(ccNum,0,127,100,8000);
	};

	if(chan == ~release_chan) {
		~release = LinLin.kr(ccNum,0,127,0.05,10);
	};

	if( chan == ~reverb_chan) {
		z.set(\room, LinLin.kr(ccNum, 0,127,0.05,55));
	};

	if( chan >= ~harmonic_channels_start_index && (chan < (~harmonic_channels_start_index.asInteger + ~harmonic_channels.size))) {
		var harmonic = LinLin.kr(ccNum,0,127,1,50);
		~harmonic_channels[chan] = harmonic;
	};

});

MIDIdef.noteOn(\noteOn,{
	arg veloc,num,chan, vol;
	vol = LinLin.kr(veloc,0,127,0,1);
	[veloc,num,chan].postln;
	//~bandwidth.postln;

	Synth(\ping, [\vol, vol,
		\note, num,
		\harmonics, ~harmonic_channels.asPairs.asAssociations(SortedList).collect{|item| item.value},
		\release, ~release,
		\cutoff, ~cutoff,
		\bandwidth, ~bandwidth
		//\harmonic_channels, ~harmonic_channels
	]);

});

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


SynthDef(\thing, {
	arg out, vol = 0.2, note = 78, cutoff = 800, bandwidth=0.75, release = 0.5;
	//note.postln;
	//var a = Resonz.ar((LFSaw.ar(note.midicps) * 0.5 * vol * EnvGen.kr(Env([0.9,1,0],[0.0001,release]), doneAction: 2)), cutoff, bandwidth);

	var wave = (Saw.ar(note.midicps ) * 0.5 * vol * EnvGen.kr(Env([0.9,1,0],[0.0001,release]), doneAction: 2));
	wave = Resonz.ar(wave, cutoff, bandwidth);


	Out.ar(out,Limiter.ar(wave!2,0.8));

}).add;


SynthDef(\ping,	{
	arg out, note, vol=0.5, harmonics=#[1,2,3,4,5,6], release=0.5, bandwidth = 0.75, cutoff = 15000;
	//var a = SinOsc.ar(LFSaw.kr(30).range(1350,350) * 0.1 * EnvGen.kr(Env.perc(releaseTime:0.2),doneAction:2));
	var freq = note.midicps;

	//round to the nearest fundamental
	var frequencies = harmonics.collect({arg harmonic; (freq * harmonic).round(freq)}).asArray();
	//or don't, and let things detune
	//var frequencies = harmonics.collect({arg harmonic; (freq * harmonic)}).asArray();

	var o = Klang.ar(`[frequencies, [0.9,0.1,0.1,0.1,0.1,0.1], pi.dup(6)], 1, 0);
	//var o = Klang.ar(`[frequencies, [0.4,0.2,0.1,0.08,0.05,0.025], Array.fill(harmonics.size, rand(pi))], 1, 0);

	//o = SinOsc.ar(note.midicps*3);
	var env =  EnvGen.kr(Env.perc(releaseTime:release),doneAction:2);
	var wave = o * 0.9 * env * vol;

	//wave = Resonz.ar(wave, cutoff, bandwidth);
	wave = LPF.ar(wave,cutoff);

	//wave = wave + 3.do{|i| AllpassL.ar(wave,15,0.2*i,1)};

	//sig + AllpassL.ar(sig,15,0.25,0.21);

	//wave = Mix.new([wave,saw]);

	//limit to 0.9 so we don't blast ourselves...
	Out.ar(out,Limiter.ar(wave!2,0.95));
}).add;



//instantiate our freeverb (replacing our usual output)
z = Synth(\FreeVerb2x2, [\outbus, 0], addAction:\addToTail);
//z.set(\mix, 0.23);
//z.set(\damp, 0.4);
)

//{SinOsc.ar() * Xline.kr(1,0,2)}.play