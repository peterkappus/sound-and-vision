//Midi-scaffolding
//Include this file with any synth you want to play with a midi controller
//It handle's note-on/off events and continuous control signals

// *****SERVER SETUP ******
//kill any running server
//Server.killAll;

//reboot a fresh server
//s.boot;


// **** MIDI SETUP ***

//initialize a midi client
MIDIClient.init;

//connect all the possible inputs
MIDIIn.connectAll;

~sustainValue = 0;

~activenotes = nil!128; //make Array of 128 slots, initially with nil objects in to represent nothing


~notes = List.new();

~noteOnSynth;

~notes.size;

~releasefunction = {|index|
	//called without an argument means we've released the sustain pedal.
	if(index.isNil){
		//iterate through all notes and release each one

		for(0,~notes.size-1, {|i|
			~notes.pop().release;
		});

	} {
		//release existing note if present already
		if(~activenotes[index].notNil) {
			~activenotes[index].release; //will send gate=0
			~activenotes[index] = nil; //make sure now empty slot ready
		}
	}
};


//some utility methods

//broadcast a parm change to all current notes
~broadcastParam = {|key, value|

	("Updating: " + key + " to " + value).postln;

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
	vol = veloc.linexp(0,127,0.03,1);

	synth = Synth.new(~noteOnSynth, [
		\freq, num.midicps,
		\vol, vol,
		\filterFreq, ~controllers[~paramsToChans.at(\filterFreq)].at(\current),
		\detuneAmt, ~controllers[~paramsToChans.at(\detuneAmt)].at(\current),
		\pan, 0.8.rand2
	]);

	/*
	// Replace "\tone" with your SynthDef and pass any params
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
	*/


});

//broadcast a parm change to all current notes
~broadcastParam = {|key, value|

	("Updating: " + key + " to " + value).postln;

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


MIDIdef.cc(\ccFunc, {
	arg ccNum, chan;
	~newValue = 0;
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
	} {
		~newValue = ccNum.linexp(0,127,~controllers[chan].at(\min),~controllers[chan].at(\max));
		~controllers[chan].put(\current,~newValue);
		~broadcastParam.value(~controllers[chan].at(\argName),~newValue);
	}



});
