

Env.perc(0.001, 1, 1, -8).test.plot

(
s.reboot();
ServerOptions.devices;
//Server.default.options.device = "Peter Kappus’s AirPods P";
Server.default.options.device = "SC";
//ServerOptions.numChannels = 0;


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
	//var env =  EnvGen.kr(Env.perc(releaseTime:release),doneAction:2);
	var env =  EnvGen.kr(Env.perc(0.001, 1, 1, -8),doneAction:2);
	var wave = o * 0.9 * env * vol;

	//wave = Resonz.ar(wave, cutoff, bandwidth);
	wave = LPF.ar(wave,cutoff);

	//wave = wave + 3.do{|i| AllpassL.ar(wave,15,0.2*i,1)};

	//sig + AllpassL.ar(sig,15,0.25,0.21);

	//wave = Mix.new([wave,saw]);

	//limit to 0.9 so we don't blast ourselves...
	Out.ar(out,Limiter.ar(wave!2,0.95));
}).add;

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


fork {
	5.wait;
	z = Synth(\FreeVerb2x2, [\outbus, 0], addAction:\addToTail);
	3.wait;
	Synth(\ping, [\vol, 127,
		\note, 80,
		\harmonics, ~harmonic_channels.asPairs.asAssociations(SortedList).collect{|item| item.value},
		\release, ~release,
		\cutoff, ~cutoff,
		\bandwidth, ~bandwidth
		//\harmonic_channels, ~harmonic_channels
	]);
}


)	