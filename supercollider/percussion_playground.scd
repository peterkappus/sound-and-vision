

//Server.default.options.device = "MacBook Pro Speakers";
//Server.default.options.outDevice_("Built-in Output");
//Server.default.options.outDevice_("UMC404HD 192k");

Server.default.options.outDevice_("Default");

Server.killAll;
s.boot;

{Splay.ar( SinOsc.ar({rand(438,440)} ! 8), level: 0.2)}.play;

{Splay.ar( SinOsc.ar({ LFNoise2.kr(10).exprange(220,15880)} ! 8), level: 0.2)}.play;

{Splay.ar( SinOsc.ar({ 440 * [1,2,3,5,7,8,9].choose / [1,2,3,5,7,9,12,14].choose} ! 8), level: 0.2)}.play;

{Splay.ar( SinOsc.ar({ 440 * [1,3,6,8].choose / [1,2,3,4,6,12].choose} ! 8), level: 0.2)}.play;


//{SinOsc.ar(440 + (850 * SinOsc.kr(5)))}.scope;

{LPF.ar(Crackle.ar(1.99,0.5),800)}.play;

{BPF.ar({Dust.ar(30, 0.5) ! 2}, 6000,0.5)}.play;



(

Server.default.options.outDevice_("Default");

Server.killAll;
s.boot;
)


(
//5.wait;

s.record();

//initialize a midi client
MIDIClient.init;

//connect all the possible inputs
MIDIIn.connectAll;


//we'll use this slightly detuned sine wave as the basic building block.
~detuneSine = {|f=440|
	var detuneAmt = 0.005;
	//each stereo bit detuned slightly differently played via a percussion envelope
	SinOsc.ar({Rand(f * (1 - detuneAmt), f * (1 + detuneAmt)) } ! 2) * 0.2  * EnvGen.kr(Env.perc(releaseTime:4), doneAction: Done.freeSelf);
	//0; //useful for "commenting out" the bell sounds altogether.
};



fork {

	var tempo = 110;

	//various notes
	var notes = #[57,59,61,64,67,71,73,74,76,78,79,81,83,85,86,88,90,93,95];
	//var notes = #[75,77,85,88,93,95];

	var i = 57;
	var baseNote = 0;

	//whole tone scale
	//var noteStream = Pxrand({25 + i; i=i + 2} ! 20, inf).asStream;


	var noteStream = Prand(notes,inf).asStream;


	256.do {
		//Synth(\ding);
		{
			var vel = Rand(0.4,1);

			var baseNote = 0;

			//var crackle = Crackle.ar(1.7,0.2);
			// Dust with band pass filter to shave off the harsh edges
			//var dust = BPF.ar({Dust.ar(10, 0.2) ! 2}, 1500,0.8);
			//Thought a bit of dust might sound cool like an old record but it just annoys me ;-)
			//I'd rather have it beutifully crisp and pristine!

			var dust  = 0 ; // leave as zero so it doesn't cause errors below when we try to add "dust" to the signal


			//var octave = Pxrand(#[-2,-1,0,1,2],inf).asStream.next;
			var octave = #[-2,-1,0,1,2].choose;
			//var octave = 0;

			//random tone * random octave
			var f = ( (octave * 12) + baseNote + noteStream.next).midicps;
			//var f = ( (octave * 12) + baseNote + Pxrand(notes, inf).asStream.next).midicps;

			//signal
			var sig = ~detuneSine.value(f);

			//tiny bit of noise at the front
			var plunkFilterEnv = EnvGen.kr(Env.perc(attackTime: 0.001, releaseTime: 0.5));
			var plunkFreq = 5000;

			/*
			var plunkFreqEnv = EnvGen.kr(Env.perc(attackTime: 0.001, releaseTime: 0.5));
			var plunkWav = Pulse.ar({plunkFreq * Rand.new(0.99,1.01) * plunkFreqEnv} ! 2,0.5);
			*/

			//the plunk is actually a tiny high pitched square wave
			var plunkWav = Pulse.ar({plunkFreq * Rand.new(0.80,1.2)} ! 2,0.5);
			var plunk = LPF.ar(plunkWav, 1000 + (Rand(300,2000) * plunkFilterEnv)) * 0.5 * EnvGen.ar(Env.perc(attackTime: 0.01, releaseTime: 0.025));

			//A bit of white, pink brown, or gray noise are nice, too!
			var noisePlunkWave = GrayNoise.ar();
			//var noisePlunk = {BPF.ar(noisePlunkWave, 1500 + (Rand(100,6000) * plunkFilterEnv),0.8) * 0.3 * EnvGen.ar(Env.perc(attackTime: 0.01, releaseTime: 0.25))} ! 2;
			var noisePlunk = {BPF.ar(noisePlunkWave, 20 + (Rand(100,1000) * plunkFilterEnv),0.35) * 0.25 * EnvGen.ar(Env.perc(attackTime: 0.01, releaseTime: 0.25))} ! 2;


			//add some nice otherworldly weird harmonics

			sig = sig + (~detuneSine.value(f * 1/4) * 0.2);
			sig = sig + (~detuneSine.value(f * 8) * 0.1);
			sig = sig + (~detuneSine.value(f * 7/5) * 0.01);
			sig = sig + (~detuneSine.value(f * 16) * 0.1);

			sig = sig + plunk + dust + noisePlunk;

			sig = sig * vel;

			//low pass filter based on velocity + a wobbly higher filter from 1.5 to 8 hz
			// DANGER! If LPF freq gets close to zero, there will be LOUD artefacts.
			sig = LPF.ar(sig, (12500 * vel) + (3500 * SinOsc.kr(Rand(1.5,8))),1);

			//compand w/ defaults
			sig = CompanderD.ar(sig);

			Out.ar(0, sig);

			//(60/tempo * Pxrand([1/4, 1/2, 1/4, 1/8, 3/8, 1/2],inf).asStream.next).wait;
			(60/tempo * [1/4,1/4, 1/2].choose).wait;

		}.play;
	};

// let our notes finish
5.wait;

//stop recording
s.stopRecording;

};

)



(

SynthDef(\ding, { |f = 440, amp = 1 |
	var sig = (SinOsc.ar([Rand(f * 0.99, f * 1.01), Rand(f * 0.99, f * 1.01)]) * amp);
	//Out.ar(0, sig);
}).add;



~detuneSine = {|f=440|
	var wobble = 0.002;
	SinOsc.ar({Rand(f * (1 - wobble), f * (1 + wobble)) } ! 2) * 0.2  * EnvGen.kr(Env.perc(releaseTime:4), doneAction: Done.freeSelf);
};



fork {
	20.do {
		var f = Pxrand(#[25,27,29,31,32,34,35,37,39,40,41,43,45]).asStream.next.midicps;
		f = f * 2;

		{
			//var sig = Synth(\ding, [f:880]); //SinOsc.ar([Rand(f * 0.99, f * 1.01), Rand(f * 0.99, f * 1.01)]);
			var sig = ~detuneSine.value(f * 2);
			sig = sig + (~detuneSine.value(f * 3/4));
			sig = sig + (~detuneSine.value(f * 4));
			sig = sig + (~detuneSine.value(f * 7/5) * 0.1);

			//sig += Synth(\ding ); //SinOsc.ar([Rand(f * 0.99, f * 1.01), Rand(f * 0.99, f * 1.01)]);
			//var sig = (SinOsc.ar([Rand(f * 0.99, f * 1.01), Rand(f * 0.99, f * 1.01)] * 16/3) * 0.3);
			Out.ar(0, sig);
		}.play;
		0.25.wait;
	}
}
)


(


SynthDef(\sawz, { |ffreq = 800, freq = 440, duration = 5 |

	//swelling envelope for sine wave
	var env = EnvGen.kr(Env.new(times: [duration * 0.4,duration * 0.6]), doneAction: Done.freeSelf);

	//stereo sine waves slightly out of tune
	var osc =  SinOsc.ar([freq,freq * (1 + Rand.new(0,0.002))]) * 0.5;

	//add a stereo saw, slightly detuned
	var saw = Saw.ar([freq,freq * (2 + Rand.new(0,0.002))]) * 0.5;

	//osc = BPF.ar(osc, 220,0.8);
	//low pass filter to smooth it out. Is this necessary with sine waves?
	osc = LPF.ar(osc, ffreq);

	//osc = BPF.ar(osc, ffreq * 1.25, 1);
	//filter w/ MoogFF filter which swells using envleope matched to duration
	saw = MoogFF.ar(saw,ffreq * 2 * EnvGen.kr(Env.new(times:[duration * 0.4, duration * 0.6])));

	//combine the two
	osc = saw + osc;

	//output
	Out.ar(0, env * osc * 0.4);
}).add;



/*
//add reverb... but not necessary with such slow waves. just makes it muddy.
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
*/

fork{
	/*3.wait;
	//instantiate our freeverb (replacing our usual output)
	z = Synth(\FreeVerb2x2, [\outbus, 0, \room, 2], addAction:\addToTail);
	*/

	16.do {
		var f = (66 + [2,4,6,7,8,10].choose).midicps;

		//var duration = [2,3,4,5,7,8].choose;

		//sounds better if they're all uniform
		var duration = 7;

		var filterFreq = 850 + 1500.rand;

		//generate 3 waves
		var saw = Synth(\sawz, [duration: duration, freq: f, ffreq: filterFreq]);

		//fifth?
		var saw2 = Synth(\sawz, [duration: duration, freq: f * 2/3, ffreq: filterFreq]);

		//create eerie harmonics using fixed ratios
		var saw3 = Synth(\sawz, [duration: duration, freq: f * [1,2,3,5,7,9].choose/[3,4,6,12].choose, ffreq: filterFreq]);

		//wait based on duration (currently all the same duration but could vary)
		(duration * 0.71).wait;
	}
}



)

//Env.perc(0.001,3).plot;

(

SynthDef(\kick, { | freq = 440 |

	//var freqEnv = EnvGen.kr(Env.perc(0.01,0.2)) * 200;
	var freqEnv = Env([0,1,0.25,0],[0.001,0.08,1.5,0.1],\cubed);
	freqEnv = EnvGen.kr(freqEnv) * 1.2;

	Out.ar(0, 0.8 * EnvGen.kr(Env.perc(0.01,0.5), doneAction: Done.freeSelf) * SinOsc.ar([freqEnv * freq,freqEnv * freq * 1.02]));
}).add;


SynthDef(\snare, { | filterFreq = 1400 |

	//var freqEnv = EnvGen.kr(Env.perc(0.01,0.2)) * 200;
	var freqEnv = Env([0,1,0.25,0],[0.001,0.02,1,0.1],\cubed);
	freqEnv = EnvGen.kr(freqEnv, doneAction: Done.freeSelf) * 2;

	Out.ar(0, EnvGen.kr(Env.perc(0.01,0.5), doneAction: Done.freeSelf) * MoogFF.ar(WhiteNoise.ar([0.2,0.2]),filterFreq,0.01,1.2));
	//Out.ar(0, EnvGen.kr(Env.perc(0.01,0.5)) * Resonz.ar(WhiteNoise.ar([0.2,0.2]),filterFreq,1,1.2));
}).add;


fork {
	2.do {
		3.do {
			Synth(\kick, [freq: 150 + 30.rand]);
			0.25.wait;

			Synth(\snare, [filterFreq: 12500 + 5500.rand]);
			0.25.wait;
		};

		1.do {
			Synth(\kick, [freq: 150 + 30.rand]);
			0.25.wait;

			Synth(\snare, [filterFreq: 12500 + 5500.rand]);
			0.125.wait;

			Synth(\snare, [filterFreq: 10500 + 2500.rand]);
			0.125.wait;
		};
	}
}


//x=60;y=65;a=[x,x,62,x];play{GrainSin.ar(1,Impulse.ar(8),1/9,Dseq(a++[y,64,0]++a++[67,y,0,x,x,72,69,y,y,64,62,70,70,69,y,67,y]).midicps)%4e0}

//play{{a=SinOsc;l=LFNoise2;a.ar(666*a.ar(l.ar(l.ar(0.5))*9)*RLPF.ar(Saw.ar(9),l.ar(0.5).range(9,999),l.ar(2))).cubed}!2} //oscillators argue

//play{f={|o,i|if(i>0,{SinOsc.ar([i,i+1e-4]**2*f.(o,i-1),f.(o,i-1)*1e-4,f.(o,i-1))},o)};f.(60,6)/60}

//a=LFTri;play{|f=99|Pan2.ar(a.ar(f+{200.rand+216}.dup(8),{-2pi.rand+2pi}.dup(8),0.01+a.ar({0.01.rand+0.1}.dup(8),0,0.1)),0)}// #SuperCollider

//play{GVerb.ar(x=LFNoise0.ar(0.1!2,2.5,3.5);SplayAz.ar(2,LatoocarfianL.ar(SampleRate.ir/2+16.rand,x,x,x,x)!66,x),9+x,9*x)*0.001}

)
