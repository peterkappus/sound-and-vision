(
{
    var freqEnv, ampEnv, osc, kick;
	// Optional: Add some noise for a bit of click at the start
    var noise = WhiteNoise.ar(0.2) * Decay.kr(Impulse.kr(1), 0.01);

    // Frequency envelope for the pitch sweep
    freqEnv = EnvGen.kr(
        Env([150, 50], [0.5, 0.5], 'exponential'), // Start at 50 Hz, drop to 20 Hz
        doneAction: 2 // Free the synth when done
    );

    // Amplitude envelope with a slightly longer release time
    ampEnv = EnvGen.kr(
        Env.perc(0.1, 2.295), // Short attack, longer release
        doneAction: 2 // Free the synth when done
    );

    // Sine wave oscillator for the kick
    osc = SinOsc.ar(freqEnv, 0, ampEnv);



    // Combine the oscillator and the noise
    kick = osc + noise;

    // Lowpass filter to shape the sound
    kick = LPF.ar(kick, 2000);

    // Output
    Out.ar(0, kick!2) // Output to both stereo channels
}.play;
)
