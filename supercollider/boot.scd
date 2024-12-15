

// standard boot sequence boot up

(

//use our default out device, probably not necessary to explicitly specify, but I've had issues in the past when switching devices.
Server.default.options.outDevice_("Default");

//ServerOptions.devices;


// just to be safe, kill everything and then reboot
Server.killAll;

//For long CombN delays and lots of synth layers
s.options.memSize= 8192*2;

s.boot;

)