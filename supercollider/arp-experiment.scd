// An automagical kind of "music box"



(

//use our default out device, probably not necessary to explicitly specify, but I've had issues in the past when switching devices.
Server.default.options.outDevice_("Default");

// just to be safe, kill everything and then reboot
Server.killAll;
s.boot;


// Sometimes it's nice to record the output every time and then comb through and save the ones I like.
//s.record();

//initialize a midi client
MIDIClient.init;

//connect all the possible inputs
MIDIIn.connectAll;


//we'll use this slightly detuned sine wave as the basic building block.
~detuneSine = {|f=440|
	var detuneAmt = 0.005;
	//each stereo bit detuned slightly differently played via a percussion envelope
	SinOsc.ar({Rand(f * (1 - detuneAmt), f * (1 + detuneAmt)) } ! 2) * 0.2  * EnvGen.kr(Env.perc(releaseTime:4), doneAction: Done.freeSelf);

	//uncomment this if you want to remove all the bell sounds (by returning silence) so you can focus on shaping the noise plunks.
	//0;
};


~bell = {|f=440, vel = 0.8 |

	//spinning oscillator variance (hz)
	var lfoAmt = 4500;

	//signal
	var sig = ~detuneSine.value(f);

	//tiny bit of noise at the front
	var plunkFilterEnv = EnvGen.kr(Env.perc(attackTime: 0.001, releaseTime: 0.5));
	var plunkFreq = 3000;

	// an alternative pluck/plunk

	/*
	var plunkFreqEnv = EnvGen.kr(Env.perc(attackTime: 0.001, releaseTime: 0.5));
	var plunkWav = Pulse.ar({plunkFreq * Rand.new(0.99,1.01) * plunkFreqEnv} ! 2,0.5);
	*/

	// Try a tiny high pitched square wave
	//var plunkWav = Pulse.ar({plunkFreq * Rand.new(0.80,1.2)} ! 2,0.5);

	// Or a high-pitched saw
	var plunkWav = Saw.ar({plunkFreq * Rand.new(0.85,1.15)} ! 2,0.5);
	var plunk = BPF.ar(plunkWav, 250 + (Rand(300,1000) * plunkFilterEnv),0.5) * 0.8 * EnvGen.ar(Env.perc(attackTime: 0.01, releaseTime: 0.25));

	//A bit of white, pink brown, or gray noise are nice, too!
	var noisePlunkWave = PinkNoise.ar();
	var noisePlunkEnv = EnvGen.kr(Env.perc(attackTime: 0.001, releaseTime: 0.2));

	var noisePlunk = {BPF.ar(noisePlunkWave, 20 + (Rand(20,500) * noisePlunkEnv),0.85) * 0.35 * EnvGen.ar(Env.perc(attackTime: 0.01, releaseTime: 0.25))} ! 2;


	//add some nice/weird otherworldly weird harmonics using simple math ratios

	sig = sig + (~detuneSine.value(f * 1/4) * 0.2);
	sig = sig + (~detuneSine.value(f * 8) * 0.1);
	sig = sig + (~detuneSine.value(f * 7/5) * 0.01);
	sig = sig + (~detuneSine.value(f * 16) * 0.1);

	sig = sig + noisePlunk + plunk;

	// uncomment to only listen to the plunk
	//sig = plunk;

	// multiply by velocity
	sig = sig * vel;

	// low pass filter based on velocity + a wobbly, spinning sounding higher filter from 1.5 to 8 hz
	// DANGER! If LPF freq gets close to zero, there will be LOUD artefacts.
	// Ensure values for "vel" don't get too low...

	sig = LPF.ar(sig, lfoAmt + (5500 * vel) + (lfoAmt * SinOsc.kr(Rand(1.5,12))));

	//compand w/ defaults
	// nah, let's keep all the dynamics!
	//sig = CompanderD.ar(sig);

	Out.ar(0, sig);

};


// a nice plunky automagic arpy thing. Get's triggered when you hit a low, low A (see below)
~goArp = {

	fork {

		var tempo = 40;
		//var tempo = 40;

		//various notes
		var notes = #[57,59,61,64,67,71,73,74,76,78,79,81,83,85,86,88,90,93,95];
		//var notes = #[75,77,85,88,93,95];

		var i = 57;

		//useful for transposing
		var baseNote = 0;

		//whole tone scale
		//var noteStream = Pxrand({25 + i; i=i + 2} ! 20, inf).asStream;


		var noteStream = Prand(notes,inf).asStream;

		128.do {
			{
				//DANGER! low velocity can really mess with the LPF on the bell
				var velocity = Rand(0.1,1);

				// var crackle = Crackle.ar(1.7,0.2);
				// Dust with band pass filter to shave off the harsh edges
				// var dust = BPF.ar({Dust.ar(10, 0.2) ! 2}, 1500,0.8);
				// Thought a bit of dust might sound cool like an old record but it just annoys me ;-)
				// I'd rather have it beutifully crisp and pristine!

				//var octave = Pxrand(#[-2,-1,0,1,2],inf).asStream.next;
				var octave = #[-2,-1,0,1,2].choose;
				//var octave = 0;

				// random tone * random octave
				var f = ( (octave * 12) + baseNote + noteStream.next).midicps;

				//var f = ( (octave * 12) + baseNote + Pxrand(notes, inf).asStream.next).midicps;
				~bell.value(f,velocity);
			}.play;

			// Don't repeat the same delay twice. This actually doesn't sound as good because it's too random
			//(60/tempo * Pxrand([1/4, 1/2, 1/4, 1/8, 3/8, 1/2],inf).asStream.next).wait;

			// short delay to create some rhythm
			(60/tempo * [1/4,1/4, 1/2].choose).wait;
		};

	};
};



MIDIdef.noteOn(\noteOn,{
	arg veloc,num,chan, vol;
	//vol = LinLin.kr(veloc,0,127,0,1);
	[veloc,num,chan].postln;
	{~bell.value(num.midicps,veloc.linexp(0,127,0.1,1)) * 0.2}.play;

	// Use the bottom key on my digital piano as a simple "button" to trigger the arp
	if(num == 21) {
		~goArp.value;
	}
});


// if you opt for automatic recording, enable this to stop when the notes are done.

// let our notes finish
//5.wait;

//stop recording
//s.stopRecording;

)
