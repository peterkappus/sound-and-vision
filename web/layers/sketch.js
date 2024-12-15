"use strict";

var playing = false;

//seconds
var reverbTime = 15;

var previousNote;
var note;
var attackLevel = 0.2; //low to prevent clipping in captured file
var releaseLevel = 0;

var attackTime = 0.01;
var decayTime = 1.5;
var susPercent = 1;
var releaseTime = 2;

//var notes = [0,6,7,9,12,14,16,19,24];
//var notes = [ 0, 2, 4, 7, 9, 11 ];
var notes = [0, 2, 4, 7, 9, 11, 14];

//lowest note
var bottom_pitch = 45;

//frame counter
//var frame =0;
var rate = 6;

var bgColor;

var i;
var running = false;


function ding(freq) {
  
  let myOsc = new p5.Oscillator('sine');

  /*let reverb = new p5.Reverb();
    reverb.process(myOsc,reverbTime,1);
  */

  myOsc.pan(-0.5 + random(1));
  myOsc.freq(freq);

  myOsc.start();
  myOsc.amp(0,0.5);
  myOsc.stop(1);
  setTimeout(function() {}, 3000)
  //env.triggerAttack();
  
 }


function setup() {

  // mimics the autoplay policy
  getAudioContext().suspend();

  let mySynth = new p5.MonoSynth();

  // This won't play until the context has resumed
  mySynth.play('A6');

  frameRate(rate);
  i = 0;
}
function draw() {
  background(220);
  textAlign(CENTER, CENTER);
  
  text(getAudioContext().state, width/2, height/2);

  if(running && i < 12) {
    ding(midiToFreq([23,25,27,30,45].sample));
    i++;
    console.log(i);
  }
  
}
function mousePressed() {
  userStartAudio();
  running = !running;
}

