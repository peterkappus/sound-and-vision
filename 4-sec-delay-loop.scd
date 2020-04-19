// Loope
//credit to Eli Fieldsteel: https://www.youtube.com/watch?v=_2N7lG5uzJI
(

//Server.default.options.inDevice_("Built-in Microph");
//Server.default.options.inDevice_("UMC404HD 192k");
//Server.default.options.outDevice_("UMC404HD 192k");


//4 second loop taking 70 seconds to decay
ServerOptions.outDevices;
~infiniteHoldReverb = {
	arg feedback = 1;
	var sig, local;

	//establish input
	sig = SoundIn.ar(0);
	local = LocalIn.ar(2)+sig.dup; //duplicate to create 2-channel input

	//apply reverb
	1.do{ local = AllpassN.ar(local, 4, 4, 70)};

	//complete feedback loop -- send audio back to LocalIn
	LocalOut.ar( local*0);

	//non-feedback output to speakers
	Out.ar(0, sig+local);
}.play
)

//~infiniteHoldReverb.set(\feedback