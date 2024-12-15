//Wowel synth choir. 2020 Matias Monteagudo.
//Vox humana choir like synth.

//My interface options. Change at will.

(
//Server.local.options.device = "ASIO : ASIO PreSonus FireStudio";
Server.local.options.sampleRate=48000;
Server.local.options.hardwareBufferSize=128;
)

//For this synth is important to raise the amount of Wire buffers, do this before booting the server.

Server.local.options.numWireBufs=128

//Add reverb to start with. Makes everything more pleasant ;-)
((
SynthDef(\FreeVerb2x2, { |out, mix = 0.25, room = 0.15, damp = 0, amp = 1.0|
    var signal;

    signal = In.ar(out, 2);

    ReplaceOut.ar(out,
        FreeVerb2.ar( // FreeVerb2 - true stereo UGen
            signal[0], // Left channel
            signal[1], // Right Channel
            mix, room, damp, amp
        )
    );

}).add;
);

z = Synth(\FreeVerb2x2, [\outbus, 0,\room,1], addAction:\addToTail);
)

//Connect MIDI devices. (0,6) is my keyboard under a vir tual MIDI cable. You probably need to evaluate only "MIDIIn.connectAll"
MIDIClient.init;
MIDIIn.connectAll;

/*
MIDIIn.disconnect(0,6);
MIDIIn.connectAll
*/

//The Synth. It will crossfade across vowels. It uses formant charts from female and male German speakers. https://www.ipds.uni-kiel.de/kjk/pub_exx/aipuk32/mpas.pdf

(
SynthDef(\vowelsynth,{
    | vel=1,fq=440,bend=0,gate=1,vow=0 |
    var a,b,c,d,e,
	vib1,vib2,vib3,vib4,vib5,vib6,vib7,vib8,
	gen1,gen2,gen3,gen4,gen5,gen6,gen7,gen8,ngen, env,
	ah1,eh1,ih1,oh1,uh1,
	ah2,eh2,ih2,oh2,uh2,
	ah3,eh3,ih3,oh3,uh3,
	ah4,eh4,ih4,oh4,uh4,
	ah5,eh5,ih5,oh5,uh5,
	ah6,eh6,ih6,oh6,uh6,
	ah7,eh7,ih7,oh7,uh7,
	ah8,eh8,ih8,oh8,uh8,
	mod1,mod2,mod3,mod4,mod5,mod6,mod7,mod8,
	pan1,pan2,pan3,pan4,pan5,pan6,pan7,pan8;

	vib1=SinOsc.ar(5,0,EnvGen.kr(Env([0,2],[0.2],4),1));
	vib2=SinOsc.ar(5.2,0,EnvGen.kr(Env([0,1],[0.3],4),1));
	vib3=SinOsc.ar(4.3,0,EnvGen.kr(Env([0,2],[0.4],4),1));
	vib4=SinOsc.ar(5.4,0,EnvGen.kr(Env([0,1],[0.5],4),1));
	vib5=SinOsc.ar(4.5,0,EnvGen.kr(Env([0,2],[0.6],4),1));
	vib6=SinOsc.ar(5.25,0,EnvGen.kr(Env([0,1],[0.7],4),1));
	vib7=SinOsc.ar(4.35,0,EnvGen.kr(Env([0,2],[0.8],4),1));
	vib8=SinOsc.ar(5.45,0,EnvGen.kr(Env([0,1],[0.9],4),1));

	mod1=SinOsc.ar(0.1,mul:1);
	mod2=SinOsc.ar(-0.23,mul:1);
	mod3=SinOsc.ar(0.34,mul:1);
	mod4=SinOsc.ar(-0.44,mul:1);
	mod5=SinOsc.ar(0.5,mul:1);
	mod6=SinOsc.ar(-0.6,mul:1);
	mod7=SinOsc.ar(0.73,mul:1);
	mod8=SinOsc.ar(-0.81,mul:1);

	gen1=LFPulse.ar(fq*bend.midiratio+mod1+vib1,0,0.4*mod8/8+0.2,0.15,0);
	gen2=LFPulse.ar(fq*bend.midiratio+mod2+vib2,0,0.4*mod7/8+0.2,0.15,0);
	gen3=LFPulse.ar(fq*bend.midiratio+mod3+vib3,0,0.4*mod6/8+0.2,0.15,0);
	gen4=LFPulse.ar(fq*bend.midiratio+mod4+vib4,0,0.4*mod5/8+0.2,0.15,0);
	gen5=LFPulse.ar(fq*bend.midiratio+mod5+vib5,0,0.4*mod4/8+0.2,0.15,0);
	gen6=LFPulse.ar(fq*bend.midiratio+mod6+vib6,0,0.4*mod3/8+0.2,0.15,0);
	gen7=LFPulse.ar(fq*bend.midiratio+mod7+vib7,0,0.4*mod2/8+0.2,0.15,0);
	gen8=LFPulse.ar(fq*bend.midiratio+mod8+vib8,0,0.4*mod1/8+0.2,0.15,0);
	ngen=Pulse.ar(220)*GrayNoise.ar(0.005);

	//Female vowel charts.

	ah1=BBandPass.ar(gen1, 751,0.075) + BBandPass.ar(gen1, 1460,0.075) + BBandPass.ar(gen1, 2841,0.075);
	eh1=BBandPass.ar(gen1, 431,0.075) + BBandPass.ar(gen1, 2241,0.075) + BBandPass.ar(gen1, 2871,0.075);
	ih1=BBandPass.ar(gen1, 329,0.075) + BBandPass.ar(gen1, 2316,0.075) + BBandPass.ar(gen1, 2796,0.075);
	oh1=BBandPass.ar(gen1, 438,0.075) + BBandPass.ar(gen1, 953,0.075) + BBandPass.ar(gen1, 2835,0.075);
	uh1=BBandPass.ar(gen1, 350,0.075) +BBandPass.ar(gen1, 1048,0.075) + BBandPass.ar(gen1, 2760,0.075);

	ah2=BBandPass.ar(gen2, 751,0.075) + BBandPass.ar(gen2, 1460,0.075) + BBandPass.ar(gen2, 2841,0.075);
	eh2=BBandPass.ar(gen2, 431,0.075) + BBandPass.ar(gen2, 2241,0.075) + BBandPass.ar(gen2, 2871,0.075);
	ih2=BBandPass.ar(gen2, 329,0.075) + BBandPass.ar(gen2, 2316,0.075) + BBandPass.ar(gen2, 2796,0.075);
	oh2=BBandPass.ar(gen2, 438,0.075) + BBandPass.ar(gen2, 953,0.075) + BBandPass.ar(gen2, 2835,0.075);
	uh2=BBandPass.ar(gen2, 350,0.075) + BBandPass.ar(gen2, 1048,0.075) + BBandPass.ar(gen2, 2760,0.075);

	ah3=BBandPass.ar(gen3, 751,0.075) + BBandPass.ar(gen3, 1460,0.075) + BBandPass.ar(gen3, 2841,0.075);
	eh3=BBandPass.ar(gen3, 431,0.075) + BBandPass.ar(gen3, 2241,0.075) + BBandPass.ar(gen3, 2871,0.075);
	ih3=BBandPass.ar(gen3, 329,0.075) + BBandPass.ar(gen3, 2316,0.075) + BBandPass.ar(gen3, 2796,0.075);
	oh3=BBandPass.ar(gen3, 438,0.075) + BBandPass.ar(gen3, 953,0.075) + BBandPass.ar(gen3, 2835,0.075);
	uh3=BBandPass.ar(gen3, 350,0.075) + BBandPass.ar(gen3, 1048,0.075) + BBandPass.ar(gen3, 2760,0.075);

	ah4=BBandPass.ar(gen4, 751,0.075) + BBandPass.ar(gen4, 1460,0.075) + BBandPass.ar(gen4, 2841,0.075);
	eh4=BBandPass.ar(gen4, 431,0.075) + BBandPass.ar(gen4, 2241,0.075) + BBandPass.ar(gen4, 2871,0.075);
	ih4=BBandPass.ar(gen4, 329,0.075) + BBandPass.ar(gen4, 2316,0.075) + BBandPass.ar(gen4, 2796,0.075);
	oh4=BBandPass.ar(gen4, 438,0.075) + BBandPass.ar(gen4, 953,0.075) + BBandPass.ar(gen4, 2835,0.075);
	uh4=BBandPass.ar(gen4, 350,0.075) + BBandPass.ar(gen4, 1048,0.075) + BBandPass.ar(gen4, 2760,0.075);

	//Male vowel charts

	ah5=BBandPass.ar(gen5, 608,0.075) + BBandPass.ar(gen5, 1309,0.075) + BBandPass.ar(gen5, 2466,0.075);
	eh5=BBandPass.ar(gen5, 372,0.075) + BBandPass.ar(gen5, 1879,0.075) + BBandPass.ar(gen5, 2486,0.075);
	ih5=BBandPass.ar(gen5, 290,0.075) + BBandPass.ar(gen5, 1986,0.075) + BBandPass.ar(gen5, 2493,0.075);
	oh5=BBandPass.ar(gen5, 380,0.075) + BBandPass.ar(gen5, 907,0.075) + BBandPass.ar(gen5, 2415,0.075);
	uh5=BBandPass.ar(gen5, 309,0.075) +BBandPass.ar(gen5, 961,0.075) + BBandPass.ar(gen5, 2366,0.075);

	ah6=BBandPass.ar(gen6, 608,0.075) + BBandPass.ar(gen6, 1309,0.075) + BBandPass.ar(gen6, 2466,0.075);
	eh6=BBandPass.ar(gen6, 372,0.075) + BBandPass.ar(gen6, 1879,0.075) + BBandPass.ar(gen6, 2486,0.075);
	ih6=BBandPass.ar(gen6, 290,0.075) + BBandPass.ar(gen6, 1986,0.075) + BBandPass.ar(gen6, 2493,0.075);
	oh6=BBandPass.ar(gen6, 380,0.075) + BBandPass.ar(gen6, 907,0.075) + BBandPass.ar(gen6, 2415,0.075);
	uh6=BBandPass.ar(gen6, 309,0.075) + BBandPass.ar(gen6, 961,0.075) + BBandPass.ar(gen6, 2366,0.075);

	ah7=BBandPass.ar(gen7, 608,0.075) + BBandPass.ar(gen7, 1309,0.075) + BBandPass.ar(gen7, 2466,0.075);
	eh7=BBandPass.ar(gen7, 372,0.075) + BBandPass.ar(gen7, 1879,0.075) + BBandPass.ar(gen7, 2486,0.075);
	ih7=BBandPass.ar(gen7, 290,0.075) + BBandPass.ar(gen7, 1986,0.075) + BBandPass.ar(gen7, 2493,0.075);
	oh7=BBandPass.ar(gen7, 380,0.075) + BBandPass.ar(gen7, 907,0.075) + BBandPass.ar(gen7, 2415,0.075);
	uh7=BBandPass.ar(gen7, 309,0.075) + BBandPass.ar(gen7, 961,0.075) + BBandPass.ar(gen7, 2366,0.075);

	ah8=BBandPass.ar(gen8, 608,0.075) + BBandPass.ar(gen8, 1309,0.075) + BBandPass.ar(gen8, 2466,0.075);
	eh8=BBandPass.ar(gen8, 372,0.075) + BBandPass.ar(gen8, 1879,0.075) + BBandPass.ar(gen8, 2486,0.075);
	ih8=BBandPass.ar(gen8, 290,0.075) + BBandPass.ar(gen8, 1986,0.075) + BBandPass.ar(gen8, 2493,0.075);
	oh8=BBandPass.ar(gen8, 380,0.075) + BBandPass.ar(gen8, 907,0.075) + BBandPass.ar(gen8, 2415,0.075);
	uh8=BBandPass.ar(gen8, 309,0.075) + BBandPass.ar(gen8, 961,0.075) + BBandPass.ar(gen8, 2366,0.075);

	//Summing them all

	a = [ah1+ah2+ah3+ah4+ah5+ah6+ah7+ah8];
	b = [eh1+eh2+eh3+eh4+eh5+eh6+eh7+eh8];
	c = [ih1+ih2+ih3+ih4+ih5+ih6+ih7+ih8];
	d = [oh1+oh2+oh3+oh4+oh5+oh6+oh7+oh8];
	e = [uh1+uh2+uh3+uh4+uh5+uh6+uh7+uh8];

	//Panning and adding crossfading bwteeen vowels.

	pan1=Pan2.ar(LinSelectX.ar(vow, [a,b,c,d,e]+ngen,0).sum,-1,1);
	pan2=Pan2.ar(LinSelectX.ar(vow, [a,b,c,d,e]+ngen,0).sum,-0.8,1);
	pan3=Pan2.ar(LinSelectX.ar(vow, [a,b,c,d,e]+ngen,0).sum,-0.6,1);
	pan4=Pan2.ar(LinSelectX.ar(vow, [a,b,c,d,e]+ngen,0).sum,-0.4,1);
	pan5=Pan2.ar(LinSelectX.ar(vow, [a,b,c,d,e]+ngen,0).sum,0.4,1);
	pan6=Pan2.ar(LinSelectX.ar(vow, [a,b,c,d,e]+ngen,0).sum,0.6,1);
	pan7=Pan2.ar(LinSelectX.ar(vow, [a,b,c,d,e]+ngen,0).sum,0.8,1);
	pan8=Pan2.ar(LinSelectX.ar(vow, [a,b,c,d,e]+ngen,0).sum,1,1);
    env = EnvGen.ar(Env.asr(2, vel, 0.005), gate, doneAction: 2);
	Out.ar(0, pan1+pan2+pan3+pan4+pan5+pan6+pan7+pan8*env)
}).add;
)


//You can test the vowels here. Use the .free lines to avoid killing the reverb.

a=Synth(\vowelsynth, [\fq, 220, \vow, 0]); //ah
a.free;
e=Synth(\vowelsynth, [\fq, 220, \vow, 1]); //eh
e.free
i=Synth(\vowelsynth, [\fq, 220, \vow, 2]); //ih
i.free
o=Synth(\vowelsynth, [\fq, 220, \vow, 3]); //oh
o.free
u=Synth(\vowelsynth, [\fq, 220, \vow, 4]); //uh
u.free

//MIDI functions. Play the synth with a keyboard. (Or equivalent MIDI controller) CC1 crossfades between vowels.

(
~notes = Array.newClear(128);
~liftednotes = Array.newClear(128);
~pedaldown = 0;
~cc1= 0;
~bend = 8192;

MIDIdef.noteOn(\noteOn, {
	arg vel, nn, chan, src;
	if(~notes[nn] != nil){ //release notes if you're trying to repeat them
		~notes[nn].set(\gate, 0); ~notes[nn] = nil
	};

	~notes[nn] = Synth.new(\vowelsynth,
		[
			\fq, nn.midicps,
			\gate, 1,
			\vel, vel/100,
			\vow, ~cc1.linlin(0, 127, 0, 4), //This uses the last used value from cc1
			\bend, ~bend.linlin(0, 16383, -2, 2),//This uses the last used value from your pitch bend wheel.
		]
	);
});

MIDIdef.noteOff(\noteOff, {
	arg vel, nn;
	if(~pedaldown == 127) {//if pedal is down:
		~liftednotes[nn] = ~notes[nn];
	}
	{//else if pedal is up:
		~notes[nn].set(\gate,0);
		~notes[nn] = nil;
	}
} );

MIDIdef.cc(\cc1, {
	arg val, chan, src;
	['ModWheel', val].postln;
	~cc1 = val; //This will store the last used cc1 value.
	~notes.do{arg synth; synth.set(\vow, val.linlin(0, 127, 0, 4))}; //send value to all active nodes, also rescale 0,127(values) to 0,8(Hz)
},ccNum:1, chan: 0);

MIDIdef.bend(\bend, {
	arg val, chan, src;
	['bend', val, chan, src].postln;  // [ bend, 11888, 0, 1 ]
	~bend = val;//This will store the last used bend value.
	// also update any notes currently in ~notes
	~notes.do{arg synth; synth.set(\bend, val.linlin(0, 16383, -2, 2))};
}, chan: 0);

MIDIdef.cc(\pedal,{
	arg val, key;
	['pedal',val].postln;
	if(key ==64) { //only worry about pedal control messages
	~pedaldown = val;
	if(val == 0) {
		~liftednotes.do{arg synth;synth.set(\gate, 0); synth = nil;
			}
	};
	}
},ccNum:64);
)