(

//initialize a midi client
MIDIClient.init;

//connect all the possible inputs
MIDIIn.connectAll;

//array of running arps
~arps = [];
//~cutoff= 100;

~arpySynth = {
    arg freq, trig, reset, seq, amp = 0.1, cutoff = 12000, bottomNote= 72;
    bottomNote = Prand([72,70,72,72]).asStream.next;
    //change value for faster/slower (e.g. try 5, 15, 20)
	trig = Impulse.kr(Prand([1.25,5,10,2.5]).asStream.next);
	seq = Dswitch1(
        [
			//try 70 as the low note, remove high notes to start
            Dseq([bottomNote, bottomNote + 3, bottomNote + 7 , Drand([bottomNote + 10, bottomNote + 12,bottomNote + 14, bottomNote + 17, bottomNote + 19, bottomNote + 22, bottomNote + 26])], inf)
            //Dseq([72, 75, 79, Drand([82,84,86])], inf)

        ],
		LFPulse.kr(0.2);
    );
    freq = Demand.kr(trig, 0, seq.midicps);

	//Try LFTri, Saw, etc.
	//change numerator in fraction below
	//[0,0.7] provides some stereo chorusing
	//BLowPass.ar(SinOsc.ar(freq * Prand([2,3,4,8]).asStream.next/5 + [0,0.7]) * amp, cutoff,0.5);
	s = SinOsc.ar(freq * Prand([2,3,4,8]).asStream.next/5 + [0,0.7]) * amp;
	x = LFTri.ar(freq * Prand([2,3,4,8]).asStream.next/5 + [0,0.7]) * amp;
	Prand([s,x]).asStream.next;

};


~deepThing = {
	//TODO....SinO
};

//Drand([1,3,5,3],inf);

//~arp.set(\cutoff,12000);

MIDIdef.noteOn(\noteOn, {
	arg vel, num, chan;

	~arps.add(~arpySynth.play);
	[vel, num, chan].postln

});


//handle continuous control messages
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
)