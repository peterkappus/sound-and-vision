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

