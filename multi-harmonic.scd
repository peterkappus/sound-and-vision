(

//credit: Eli Fieldsteel
//transcribed from this: https://www.youtube.com/watch?v=ZVTbRNu2BI0

ServerOptions.devices;
//Server.default.options.device = "HD 4.50BTNC";
//Server.default.options.device = "UMC404HD 192k";
Server.default.options.device = "Built-in Output";
//Server.default.options.device

SynthDef.new(\tone, {

	arg freq=40, nharm=12, detune=0.2, gate=0, pan=0, amp=1, out=0;
	var sig, env;
	//env = EnvGen.kr(Env.adsr(0.5,0.1, 0.5, 3),gate);
	env = XLine.kr(1,0,0.5,doneAction: 2);

	sig = Blip.ar(freq * LFNoise1.kr(0.2!16).bipolar(detune.neg, detune).midiratio,nharm);
	sig = sig * LFNoise1.kr(0.5!16).exprange(0.1,1);
	sig = Splay.ar(sig);
	sig = Balance2.ar(sig[0],sig[1],pan);
	sig = sig * env * amp;
	Out.ar(out,sig);
}).add;
)

x = Synth.new(\tone, [\gate,1, \nharm,10, \freq, 40]);

x;
{Blip.ar(40,20) * 0.2}.play
{LFSaw.ar(2300) * 0.2}.play

s.boot
Server.killAll