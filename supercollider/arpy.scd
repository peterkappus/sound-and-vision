(


Server.default.options.device = "UMC404HD 192k";

Server.killAll;
s.boot;


//initialize a midi client
MIDIClient.init;

//connect all the possible inputs
MIDIIn.connectAll;

//array of running arps

~arps = List.new;

//~cutoff= 100;


SynthDef(\arpySynth,	{
    arg freq, trig, reset, seq, amp = 0.1, cutoff = 12000, bottomNote= 72;

	//ocassionally drop by a full tone... but why?
	//sounds terrible, commenting out...
	//bottomNote = Prand([72,70,72,72]).asStream.next;

	//Trigger rate, change value for faster/slower (e.g. try 5, 15, 20)
	trig = Impulse.kr(Prand([0.75,1.25,5,10,2.5]).asStream.next);

	seq = Dswitch1(
        [
			//try 70 as the low note, remove high notes to start
            Dseq(
				[
					bottomNote,
					bottomNote + 3,
					bottomNote + 7 ,
					Drand(
						[
							bottomNote + 10,
							bottomNote + 12,
							bottomNote + 14,
							bottomNote + 17,
							bottomNote + 19,
							bottomNote + 22,
							bottomNote + 26

						]
					)
				], inf)
            //Dseq([72, 75, 79, Drand([82,84,86])], inf)

        ],
		LFPulse.kr(0.2);
    );
    freq = Demand.kr(trig, 0, seq.midicps);

	//Try LFTri, Saw, etc.
	//change numerator in fraction below
	//[0,0.7] provides some stereo chorusing
	//BLowPass.ar(SinOsc.ar(freq * Prand([2,3,4,8]).asStream.next/5 + [0,0.7]) * amp, cutoff,0.5);
	~sin = SinOsc.ar(freq * Prand([2,3,4,8]).asStream.next/5 + [0,0.7]) * amp;
	~tri = LFTri.ar(freq * Prand([2,3,4,8]).asStream.next/5 + [0,0.7]) * amp;
	//~saw = RLPF.ar(Saw.ar([100,250],0.1), XLine.kr(8000,400,5), 0.05);
	Prand([~sin,~tri]).asStream.next;

}).add;


MIDIdef.noteOn(\noteOn, {
	arg vel, num, chan;

	~arps.add(~arpySynth.play);
	[vel, num, chan].postln

});


//handle continuous control messages
// use a virtual midi surface to create and remove arps.

/*
MIDIdef.cc(\ccFunc, {
	arg ccNum, chan;

	//if it's the first slider
	if(chan == 0){
		//print the value
		//translate the midi note value to cycles per second and assign this to the frequency
		//~cutoff = LinLin.kr(ccNum,0,127,20,12000);
		//~arps.last.set(\cutoff, ~cutoff);

	};

	/*
	//for the second slider, control the volume
	if(chan == 1){
		//print the value
		ccNum.postln;
		//map the linear midi slider range (from 0 to 127) to a linear volume from 0 to 0.5
		x.set(\amp, LinLin.kr(ccNum,0,127,0,0.5));
	};
	*/


	//if it's the first red button
	if (chan == 11 && ccNum == 0) {
		//chan.postln;
		//~arp.play;
		~arps.size.postln;

		if(~arps.size > 0) {
			x = ~arps.pop;
			x.free;
		};
	};

	//if it's the first green button
	if (chan == 113 && ccNum == 127) {
		~arps = ~arps.add(~arpySynth.play);
		~arps.size.postln;
	};

	//second red button, remove from the front of the list of arps
	if (chan == 116 && ccNum == 0) {
		//chan.postln;
		//~arp.play;

		if(~arps.size > 0) {
			x = ~arps.removeAt(0);
			x.free;
		};

		~arps.size.postln;

	};

	//print the num & chan regardless
	[ccNum, chan].postln;
});
*/


~addArp ={
	~arps.add(~arpySynth.play);
	~arps.size.postln;
};

~removeLastArp = {
	~arps.pop.release;
	~arps.size.postln;
};

~removeFirstArp = {
	~arps.removeAt(0).release;
};

~hello ={
	"hello".postln;
};


//create a UI here to play with
w = Window.new("Arp maker");

b = Button(w, Rect(20, 20, 340, 30))
        .states_([
            ["Create arp", Color.black, Color.yellow]
		])
        .action_({ arg butt;
			~addArp.value;
        });

c = Button(w, Rect(20,55,340,30))
	.states_([
		["Remove last arp",Color.white, Color.blue]
	])
	.action_({arg butt;
		if(~arps.size > 0) {
			~removeLastArp.value;
		};
});

c = Button(w, Rect(20,90,340,30))
	.states_([
		["Reboot!",Color.black, Color.red]
	])
	.action_({arg butt;
		s.reboot;
});

t = TextView(w,Rect(20,125,340,200));
t.string = "Use your keyboard to create and remove arps.\na => Add an arp\nf => Remove oldest arp\nj => remove newest arp\nESC => reboot";
t.setFont(Font("Helvetica Neue", 12));

//w = Window.new("Keyboard control!");
w.view.keyUpAction= {
	arg doc, char, modifiers, unicode, keycode, key;
	 //for degbugging
	[doc, char, modifiers, unicode, keycode, key].postln;

	// using "char == 'a'" didn't work :(
	// trying with unicode values

	// a
	//if(char.toLower == "a") {
	if(unicode == 97){
		~addArp.value;
	};

	// f
	if(unicode == 102){
	//if(char == "f") {
		~removeFirstArp.value;
	};

	//j
	if(unicode == 106){
	//if(char == "j") {
		~removeLastArp.value;
	};

	//esc
	if(unicode == 27){
	//if(key == 74) {
		s.reboot;
	};

};

//show our window
w.front;


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

fork{
	5.wait;
	//instantiate our freeverb (replacing our usual output)
	z = Synth(\FreeVerb2x2, [\outbus, 0, \room, 1], addAction:\addToTail);
}

)

