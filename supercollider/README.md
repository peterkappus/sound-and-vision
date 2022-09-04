# SuperCollider Instruments

These are very much works in progress. Still quite messy and needing some clean up before they're actually useful.

Massive thanks to Eli Fieldsteel for his amazing [youtube tutorials](https://www.youtube.com/watch?v=yRzsOOiJ_p4&list=PLPYzvS8A_rTaNDweXe6PX4CXSGq4iEWYC)


## A note on audio channels and audio interfaces:

When capturing audio for streaming or screen/audio recording, you need to use the BlackHole audio driver as the input source to your video recording

In order to hear what super collider is playing, you'll need to create an aggregated audio device 

1. `open -a 'Audio MIDI Setup'`
2. Create an aggregated device called 'SC'
3. Add your external audio interface, or built-in output, PLUS the Blackhole 2ch interface
4. In your SC instruments, make sure you use this device and set the right numnber of outputs: 

```
Server.default.options.device = "SC";
s.options.numOutputBusChannels=6; //4 channels for UMC404HD + 2 channels for BlackHole audio  
```

## Handy Sox tricks
After making a recording, strip the silence from beginnign and end like so:
`sox FILENAME OUT.mp3 silence 1 0.1 1% 1 0.1 1%`

To split a file into multiple files based on silence:

sox 1662325763.9707.aiff snippet.flac silence 1 3 0.5% 1 2 0.005% : newfile : restart

silence params: above periods, above min duration, above threshold, below periods, below duration, below threshold.
In the above case, 1 period of 3 seconds of audio above 0.005% volume and 1 period of 3 seconds below 0.005% of volume.

Thanks https://madskjeldgaard.dk/posts/sox-tutorial-split-by-silence/


