s.boot;

(
var notes, on, off;

MIDIClient.init;
MIDIIn.connectAll;

notes = Array.newClear(128);    // array has one slot per possible MIDI note

on = MIDIFunc.noteOn({ |veloc, num, chan, src|
  notes[num] = Synth(\tone, [\freq, num.midicps,
    \amp, veloc * 0.00315]);
});

off = MIDIFunc.noteOff({ |veloc, num, chan, src|
    notes[num].release;
});

q = { on.free; off.free; };
)

Synth Def.new("tutorial-SinOsc", { Out.ar(0, SinOsc.ar(440, 0, 0.2)) }).play;

// when done:
q.value;


(
SynthDef.new(\tone, {
	arg freq = 440, amp= 0.3;
	var sig, env;
	sig = LFTri.ar(freq*2) !2;
	env = EnvGen.kr(Env.perc, doneAction: 2);
	sig = sig * env * amp;
	Out.ar(0,sig);
}).add;
)