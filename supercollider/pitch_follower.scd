//Pitch tracker



// Sending audio parameters over a network via OSC
// Since SendReply can only respond to the host, this shows how
// to send data to a separate target through sclang.
(
SynthDef(\amplitudeAnalysis, {|in=0, rate=60|
    var input = SoundIn.ar(in);
    var amp = Amplitude.kr(input);
    var freq = Pitch.kr(input);
    var trig = Impulse.kr(rate);
   SendReply.kr(trig, '/analysis', [amp, freq[0], freq[1]]);
}).add;


// example target address - insert your target host & port here
~testNetAddr = NetAddr("127.0.0.1", 5000);
~mySynth = Synth(\amplitudeAnalysis);


OSCdef(\listener, {|msg|
    var data = msg[3..];
 //   data.postln;
	//var level = msg[3];

	var freq = msg[4].postln;
	{
		var env = EnvGen.kr(Env.perc(releaseTime:0.8), doneAction: Done.freeSelf);
		var sig = Saw.ar(freq ! 2);
		sig = sig * env;
		//Resonz.ar(sig,freq*0.8, bwr: 0.5, mul:0.2);
		LPF.ar(sig,900,mul:0.2);
	}.play;//);
    ~testNetAddr.sendMsg("data", data);
}, '/analysis');


~mySynth.set(\rate, 20); // slow it down...
)

//{Env.perc(0.01,2) * SinOsc.ar(200,mul:0.2)}.play


	//SinOsc.ar({Rand(f * (1 - detuneAmt), f * (1 + detuneAmt)) } ! 2) * 0.2  * EnvGen.kr(Env.perc(releaseTime:~releaseTime), doneAction: Done.freeSelf);
