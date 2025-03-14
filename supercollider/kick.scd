(
{
    var freqEnv, ampEnv, osc, osc2, kick;
	// Optional: Add some noise for a bit of click at the start
	var noise = LPF.ar(WhiteNoise.ar(0.9) * Decay.kr(Impulse.kr(0.2), 0.01), Rand(4800,5500));

    // Frequency envelope for the pitch sweep
    freqEnv = EnvGen.kr(
		Env([250, 20], [0.15, 1], 'exponential'),
		doneAction: Done.none // Free the synth when done
    );

    // Amplitude envelope with a slightly longer release time
    ampEnv = EnvGen.kr(
        Env.perc(0.05, 1,1,-4), // Short attack, longer release
		doneAction: Done.freeSelf // Free the synth when done
    );

    // Sine wave oscillator for the kick
    osc = SinOsc.ar(freqEnv, 0, ampEnv);

    osc = noise + osc + SinOsc.ar(45, 0, ampEnv) * 0.5;


    // Combine the oscillator and the noise
    //kick = osc + noise + osc2 * 0.35;

    // Lowpass filter to shape the sound
    //osc = LPF.ar(osc, 12000);

    // Output
    Out.ar(0, osc!2) // Output to both stereo channels
}.play;
)
