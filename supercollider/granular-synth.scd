///////////////////////////////////////////////////////////////////////////////

// Granulator with GUI - 2021 Matias Monteagudo

///////////////////////////////////////////////////////////////////////////////

(
//Server.local.options.device = "ASIO : ASIO PreSonus FireStudio";
Server.local.options.sampleRate=48000;
Server.local.options.hardwareBufferSize=128;
)

//Reverb.
((
	SynthDef(\verb, {
		|in, predelay=1, revtime=2, lpf=4500,mix=0.5,amp=1,out=0|
		var dry,wet,temp,sig;
		dry = In.ar(in, 2);
		temp = In.ar(in, 2);
		wet=0;
		temp=DelayN.ar(temp, 0.2, predelay);
		32.do {temp=AllpassN.ar(temp, 0.05, {Rand(0.001,0.05)}!2,revtime);
			temp=LPF.ar(temp,lpf);
			wet=wet+temp;
		};
		sig=XFade2.ar(dry,wet,mix*2-1,amp);
		Out.ar(out,sig);
	}).add;
);
)

//After evaluating this. You can hit "CMD+." or even restart the server and the verb will be there. (You'll need to re evaluate only if you restart SC)
(
~revBus = Bus.audio(s,2);
~createReverb={~reverbSynth=Synth(\verb, [\mix,0.23, \in, ~revBus])};
ServerTree.add(~createReverb);
)

ServerTree.removeAll;//If you wanna empty the Tree.


// not working yet, use midi to control GUI
(


)


//Evaluate this chunk to load the Synth and it's GUI. (You need to have the reverb running unless you wanna specify a different out)
(
(
//~f="/Users/peterk/temp/kalimba-norm.wav"; //Change sample here
//~f="/Users/peterk/temp/1.wav"; //Change sample here
~f="/Users/peterk/code/sound-and-vision/supercollider/k4.wav";


d=Buffer.readChannel(s,~f,channels:0);
e=Buffer.readChannel(s,~f,channels:1);
);


(
~x=SynthDef(\gloop2,{
    | tfq=0.01,vel=1,fq=1,pos=0,apos=0,pmean=0,gate=1,bal=0, vol=1,bend=0,lpCutoff=10000,lpRes=0,hpCutoff=30,hpRes=0,tDev=0|
    var sig, env, sigL, sigR ,ggt, env2;
	ggt = Impulse.kr(tfq+Latch.ar(WhiteNoise.ar(tDev),Pulse.ar(50)));
	sigL = GrainBuf.ar(1,ggt,1/tfq*2,d,fq* bend.midiratio,(Latch.ar(WhiteNoise.ar(0.5,0.5),ggt)*pmean)+(LFTri.ar(0.05,0,0.5)*apos)+pos,4);
	sigR = GrainBuf.ar(1,ggt,1/tfq*2,e,fq* bend.midiratio,(Latch.ar(WhiteNoise.ar(0.5,0.5),ggt)*pmean)+(LFTri.ar(0.05,0,0.5)*apos)+pos,4);
	env = EnvGen.ar(Env([0,vel,vel,0],[0.01,1/tfq-0.02,0.01]), ggt);
	env2= EnvGen.ar(Env.adsr(0.005, 0.005,1,0.1,vel,[-10,10]),gate,doneAction:2);
	bal = Balance2.ar(sigL,sigR,Latch.ar(WhiteNoise.ar(1),ggt)*bal,vol);
	sig=LPF18.ar(bal,lpCutoff.lag(0.05),lpRes);
	sig=RHPF.ar(sig, hpCutoff.lag(0.05), hpRes* -1+1);
	Out.ar(~revBus, (sig*env)*env2)
}).add;
);




MIDIClient.init;
MIDIIn.connectAll;

MIDIdef.cc(\cc1, {
	arg val, chan,  src;
	['ModWheel', val].postln;
	//~cc1 = val; //This will store the last used cc1 value.
	//~notes.do{arg synth; synth.set(\vow, val.linlin(0, 127, 0, 4))}; //send value to all active nodes, also rescale 0,127(values) to 0,8(Hz)

	if(~x.isPlaying,
		{
			~x.set(\pos, val.linlin(0,127,0,1));
			//~numberBox.value_(val.linlin(0,127,0,1));
		};

	);

	//~numberBox.value_(val.linlin(0,1,0,1));

},ccNum:1, chan: 0);



////////////////////////////////////////////////////////////////////////////////////////////////////
//GUI

(
Window.closeAll;
w=Window("GRANULATOR", Rect(546, 132, 1330, 349.0),false).front.alwaysOnTop_(true)
.background_(Color(0.6,0.6,0.6));

~slider=Slider(w, Rect(110,40,1120,40))
	.background_(Color(0.7,0.8,0.4))
	.action_({
		|obj|
		var tfq;
		tfq=obj.value.postln;
	if(~x.isPlaying,
		{~x.set(\pos, tfq)}
	);
	~numberBox.value_(obj.value.linlin(0,1,0,1));
	~slider.background_(Color(obj.value*0.3+0.7,0.8,0.4));
});

~numberBox=NumberBox(w, Rect(1240,20,80,30))
.clipLo_(0)
.clipHi_(616072)
.font_(Font("Monaco", 16))
.decimals_(6)
.action_({
	|obj|
	~slider.valueAction_(obj.value.linlin(1,0,0,1))
});

~image = Image.openSVG("C:/Audio/SC/Mat SC/Finished/grid.svg"); // YOU NEED TO CHANGE THIS PATH TO LOAD THE GRID IMAGE IN THE  X / Y CONTROLS.

~xyLP=Slider2D(w, Rect(725, 90,240, 240))
 .setBackgroundImage(~image, 10, 1)
.y_(1.0)
.x_(0.0)
.step_(0.001)
.background_(Color(0.5,0.5,0.4))
.knobColor_(Color(0.7,0.8,0.4))
.action_({|obj|
	var valx,valy;
	valx=obj.x.value.postln;
	valy=obj.y.value.linexp(0,1,20,10000).postln;
	if(~x.isPlaying,
		{~x.set(\lpRes,valx,\lpCutoff,valy)};
	);
	~xyLP.background_(Color(obj.x.value*0.3+0.5,obj.y.value*0.15+0.5,0.4));
});

~xyHP=Slider2D(w, Rect(990, 90,240, 240))
 .setBackgroundImage(~image, 10, 1)
.y_(0.0)
.x_(0.0)
.step_(0.001)
.background_(Color(0.5,0.5,0.4))
.knobColor_(Color(0.7,0.8,0.4))
.action_({|obj|
	var valx,valy;
	valx=obj.x.value.postln;
	valy=obj.y.value.linexp(0,1,20,10000).postln;
	if(~x.isPlaying,
		{~x.set(\hpRes,valx,\hpCutoff,valy)};
	);
	~xyHP.background_(Color(obj.x.value*0.3+0.5,obj.y.value*0.15+0.5,0.4));
});

~view=SoundFileView(w, Rect(112, 17,1100, 20));
~file=SoundFile.new;
~file.openRead(~f);
~file.readData(~f = Signal.newClear(~file.numFrames * ~file.numChannels));
~file.numChannels = 1;
~view.soundfile = ~file;
~view.read(0,~file.numFrames);
~view.gridOn = false;
~view.rmsColor = Color(0.7,0.8,0.4);
~view.peakColor = Color(0.9,1,0.6);
~view.background_(Color.clear);
~view.drawsBoundingLines=false;
~view.setEditableSelectionStart(0, false):
~view.setEditableSelectionSize(0, false);
~view.setData(~f, startFrame: 0, channels: 1);
~view.refresh;

~knobPan=Knob(w, Rect(550,130,140,140))
.background_(Color(1,0.8,0.4))
.value_(1)
.action_({
	|obj|
	var val;
	val=obj.value.postln;
	if(~x.isPlaying,
		{~x.set(\bal, val)}
	);
	~knobPan.background_(Color(obj.value*0.3+0.7,0.8,0.4));
});

~knobGsize=Knob(w, Rect(390,130,140,140))
.background_(Color(0.76,0.8,0.4))
.value_(0.2)
.action_({
	|obj|
	var tfq;
	tfq=obj.value.linexp(0,1,60,0.01).postln;
	if(~x.isPlaying,
		{~x.set(\tfq, tfq)}
	);
	~knobGsize.background_(Color(obj.value*0.3+0.7,0.8,0.4));
});

~knobPmean=Knob(w, Rect(230,130,140,140))
.background_(Color(0.7,0.8,0.4))
.value_(0)
.action_({
	|obj|
	var val;
	val=obj.value.linexp(0.00000001,1,0.00000001,1).postln;
	if(~x.isPlaying,
		{~x.set(\pmean, val)}
	);
	~knobPmean.background_(Color(obj.value*0.3+0.7,0.8,0.4));
});

~knobLPC=Knob(w, Rect(20,100,80,80))
.background_(Color(1,0.8,0.4))
.value_(10000)
.action_({
	|obj|
	var qual;
	qual=obj.value.linexp(0,1,20,10000).postln;
	if(~x.isPlaying,
		{~x.set(\lpCutoff, qual)}
	);
	~knobLPC.background_(Color(obj.value*0.3+0.7,0.8,0.4));
});

~knobHPC=Knob(w, Rect(120,100,80,80))
.background_(Color(0.7,0.8,0.4))
.value_(0.001)
.action_({
	|obj|
	var qual;
	qual=obj.value.linexp(0,1,20,10000).postln;
	if(~x.isPlaying,
		{~x.set(\hpCutoff, qual)}
	);
	~knobHPC.background_(Color(obj.value*0.3+0.7,0.8,0.4));
});

~knobLPR=Knob(w, Rect(20,210,80,80))
.background_(Color(0.7,0.8,0.4))
.value_(0)
.action_({
	|obj|
	var qual;
	qual=obj.value.postln;
	if(~x.isPlaying,
		{~x.set(\lpRes, qual)}
	);
	~knobLPR.background_(Color(obj.value*0.3+0.7,0.8,0.4));
});

~knobHPR=Knob(w, Rect(120,210,80,80))
.background_(Color(0.7,0.8,0.4))
.value_(0)
.action_({
	|obj|
	var val;
	val=obj.value.postln;
	if(~x.isPlaying,
		{~x.set(\hpRes, val)}
	);
	~knobHPR.background_(Color(obj.value*0.3+0.7,0.8,0.4));
});

~knobTdev=Knob(w, Rect(440,85,40,40))
.background_(Color(0.7,0.8,0.4))
.value_(0)
.action_({
	|obj|
	var val;
	val=obj.value.postln;
	if(~x.isPlaying,
		{~x.set(\tDev, val.linlin(0,1,0,20))}
	);
	~knobTdev.background_(Color(obj.value*0.3+0.7,0.8,0.4));
});

~button=Button(w, Rect(20,20,80,28))
.states_([
	["OFF", Color.black, Color.gray(0.8)],
	["ON", Color.white, Color(0.7,0.8,0.4)] ])
.font_(Font("Monaco",18))
.action_({
	|obj|
	if(obj.value == 1,
		{~x=Synth(\gloop2, [
			\pos, ~slider.value,
			\pmean, ~knobPmean.value.linexp(0,1,0,1),
			\tfq, ~knobGsize.value.linexp(0,1,60,0.01),
			\lpCutoff, ~knobLPC.value.linexp(0,1,20,10000),
			\hpCutoff, ~knobHPC.value.linexp(0,1,20,10000),
			\bal, ~knobPan.value,
			\lpRes, ~knobLPR.value,
			\hpRes, ~knobHPR.value,
			\apos, ~button2.value,
			\tDev, ~knobTdev.value
		]).register;
		},
		{~x.free}
	);
});

~button2=Button(w, Rect(20,51,80,28))
.states_([
	["Static", Color.black, Color.gray(0.8)],
	["Auto Position", Color.black, Color(0.7,0.8,0.4)] ])
.font_(Font("Monaco",11))
.action_({
	|obj|
	var val;
	val=obj.value;
	if(~x.isPlaying,
		{~x.set(\apos, val).postln});
});

~positionLabel=StaticText(w,Rect(1240,55,80,20))
.string_("POSITION")
.font_(Font("Monaco", 14))
.align_(\center);

~panLabel=StaticText(w,Rect(550,210,140,140))
.string_("Panning spread")
.font_(Font("Monaco", 14))
.align_(\center);

~grainsizeLabel=StaticText(w,Rect(390,210,140,140))
.string_("Grain Size")
.font_(Font("Monaco", 14))
.align_(\center);

~posmeanLabel=StaticText(w,Rect(230,210,140,140))
.string_("Position Meandering")
.font_(Font("Monaco", 14))
.align_(\center);

~lpCutoffLabel=StaticText(w,Rect(20,180,80,20))
.string_("LP Cutoff")
.font_(Font("Monaco", 14))
.align_(\center);

~hpCutoffLabel=StaticText(w,Rect(120,180,80,20))
.string_("HP Cutoff")
.font_(Font("Monaco", 14))
.align_(\center);

~lpResLabel=StaticText(w,Rect(20,290,80,40))
.string_("LP Resonance")
.font_(Font("Monaco", 14))
.align_(\center);

~hpResLabel=StaticText(w,Rect(120,290,80,40))
.string_("HP Resonance")
.font_(Font("Monaco", 14))
.align_(\center);

~tDevLabel=StaticText(w,Rect(475,82,90,40))
.string_("Grain Time variation")
.font_(Font("Monaco", 14))
.align_(\center);

~xyLPLabel=StaticText(w,Rect(725,317,160,40))
.string_("LP Filter: X=Res / Y=Cut")
.font_(Font("Monaco", 14))
.align_(\center);

~xyHPLabel=StaticText(w,Rect(1030,317,160,40))
.string_("HP Filter: X=Res / Y=Cut")
.font_(Font("Monaco", 14))
.align_(\center);
)
)

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Eli Fieldsteel's original tutorial + additions.

(
Window.closeAll;
w=Window(\Window, Rect(1046.0, 132.0, 801.0, 449.0),false)
.front
.alwaysOnTop_(true);

~slider=Slider(w, Rect(20,20,150,30))
)

GUI.current;

Window.closeAll

w.background_(Color(0.85,0.85,0.85,1)); //Default background color.
w.background_(Color(0.35,0.35,0.35,1));
w.background_(Color(0.85,0.85,0.35,1));
w.background_(Color(0.85,0.35,0.85,1));
w.background_(Color(0.35,0.85,0.85,1));


w.background_(Color(rrand(0,1), rrand(0,1), rrand(0,1),1));//Chooses a random color but only using primary colors.
w.background_(Color(rrand(0.0, 1), rrand(0.0,1), rrand(0.0,1),1)); //Chooses truly a random color. Note the float "0.0" specified on each color.

w.bounds; //Retrieves the boundaries.

~slider.value_(0.0);
~slider.value_(0.5);
~slider.visible_(false);
~slider.visible_(true);
~slider.thumbSize_(20);//Default
~slider.thumbSize_(100);
~slider.bounds_(Rect(100,100,150,30));
~slider.bounds_(Rect(100,100,150,10));
~slider.bounds_(Rect(100,100,500,10));
~slider.bounds_(Rect(100,100,500,200));
~slider.bounds_(Rect(100,100,250,100)).thumbSize_(100); //You can adjust more than one thing in an expression.
~slider.bounds_(Rect(20,20,150,30));

~slider.bounds; //Retireves bounds.
~slider.thumbSize; //Retireves handle size.
~slider.background; //Retrieves background color.
~slider.knobColor_(Color.red);//Sets the color of the handle center.
~slider.knobColor_(Color.blue);
~slider.knobColor_(Color.magenta);
~slider.knobColor_(Color.rand);
~slider.knobColor;//Retrieves the color info.

(
~slider.action_({
	|obj|
	obj.value.postln;
})
)

~slider.background_(Color(1,0.5,0))
~slider.background_(Color.green)
~slider.background_(Color.magenta)
~slider.background_(Color.blue)
~slider.background_(Color.red)
~slider.background_(Color.white)
~slider.background_(Color.gray)//Note two ways for gray  / grey.
~slider.background_(Color.grey)
~slider.background_(Color.cyan)
~slider.background_(Color.yellow)
~slider.background_(Color.hsv(0.36, 0.4, 1, alpha: 1));
~slider.background_(Color.new255(1,127,100).vary(val: 0.1, lo: 0.3, hi: 0.9, alphaVal: 0))
~slider.background_(Color.magenta(0.3))
~slider.background_(Color.rand)
~slider.background;

//To affect the color of the background as you move the slider.
(
~slider.action_({
	|obj|
	w.background_(Color(obj.value*0.3+0.7,0.8,0.4));
	obj.value.postln;
})
)

(
~slider.action_({
	|obj|
	~slider.background_(Color(obj.value*0.3+0.7,0.8,0.4));
	obj.value.postln;
})
)

~slider.knobColor_(Color.rand);
~slider.thumbSize_(50);

(
SynthDef(\simplebpf, {
	|freq=440, rq=0.2|
	var sig;
	sig=PinkNoise.ar(1!2);
	sig=BPF.ar(sig, freq.lag(0.2), rq.lag(0.2),1/rq.sqrt.lag(0.2)); //Note "lag"
	Out.ar(0, sig);
}).add;
)

(
Window.closeAll;
w=Window("SimpleBPF GUI", Rect(1046.0, 132.0, 801.0, 449.0),false).front.alwaysOnTop_(true);

~slider=Slider(w, Rect(20,20,200,30))
	.background_(Color.magenta(0.3))
	.action_({
		|obj|
		var cf;
		cf=obj.value.linexp(0,1,100,4000).postln;
	if(~x.isPlaying,
		{x.set(\freq, cf)}
	);
	~numberBox.value_(obj.value.linexp(0,1,100,4000));
});

~freqLabel=StaticText(w,Rect(250,55,80,20))
.string_("FREQ")
.font_(Font("Monaco", 14))
.align_(\center)
.background_(Color.white)
.stringColor_(Color.red);

~numberBox=NumberBox(w, Rect(250,20,80,30))
.value_(199)
.clipLo_(100)
.clipHi_(4000)
.font_(Font("Monaco", 16))
.decimals_(2)
.action_({
	|obj|
	~slider.valueAction_(obj.value.explin(100,4000,0,1))
});

~knob=Knob(w, Rect(20,70,80,80))
.action_({
	|obj|
	var qual;
	qual=obj.value.linexp(0,1,1,100).reciprocal.postln;
	if(~x.isPlaying,
		{x.set(\rq, qual)}
	);
});

~button=Button(w, Rect(430,20,50,30))
.states_([
	["OFF", Color.black, Color.gray(0.8)],
	["ON", Color.white, Color.magenta(0.3)] ])
.font_(Font("Monaco",18))
.action_({
	|obj|
	if(obj.value == 1,
		{x=Synth(\simplebpf, [
			\freq, ~slider.value.linexp(0,1,100,4000),
			\rq, ~knob.value.linexp(0,1,1,100).reciprocal
		]).register;
		},
		{x.free}
	);
})
)

x=Synth(\simplebpf);
x=Synth(\simplebpf, [\freq, ~slider.value.linexp(0,1,100,4000)]);
x.free;


//Popup Menu
(
~obj.remove;
~obj=PopUpMenu(w, Rect(20,170,120,30))
.items_(["", "one", "two", "three"]);
)

//Range slider.
(
~obj2.remove;
~obj2=RangeSlider(w, Rect(20,220,320,30))
)

//Text Field.
(
~obj3.remove;
~obj3=TextField(w, Rect(20,260,320,30))
)

//Text View. Allows for multiple lines of text.
(
~obj4.remove;
~obj4=TextView(w, Rect(20,290,320,80))
)

//Slider 2D (X-Y)
(
~obj5.remove;
~obj5=Slider2D(w, Rect(200,100,320,80))
)

// MultiSliderView
(
~obj6.remove;
~obj6=MultiSliderView(w, Rect(360,200,320,80))
.size_(24)
)

//SoundFileView
(
~obj7.remove;
~obj7=SoundFileView(w, Rect(360,300,320,80));
)

//Flow Decorator.

(
Window.closeAll;
w=Window("flow", Rect(1300,300,400,400))
.front
.alwaysOnTop_(true);

w.view.decorator_(FlowLayout(w.bounds, Point(15,15), Point(7,7)));//15x15 border around the objects. 7x7 distance between objects.
)

w.view.decorator_(FlowLayout(w.bounds, 15@15, 7@7)); //Can also be written this way

Knob(w, 40@40)
Knob(w, 60@40)
Knob(w, 20@20)
Knob(w, 20@40)
Knob(w, 40@10)
Knob(w, [10,20,30,40,50,60].choose@[10,20,30,40,50,60].choose); //Creates one knob with random size.
60.do{Knob(w, [10,20,30,40,50,60].choose@[10,20,30,40,50,60].choose)};

w.view.decorator.nextLine; //To force next object in a new line.

20.do{Knob(w, 30@30)};
10.do{Knob(w, 60@60)};

w.view.children.collect(_.value_(rrand(0.0,1.0)));//Sets random values to all knobs.

w.view.removeAll
w.view.close

w.refresh