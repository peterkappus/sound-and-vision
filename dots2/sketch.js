"use strict";

var playing = false;

//seconds
var reverbTime = 5;

var previousNote;
var note;
var attackLevel = 0.5; //low to prevent clipping in captured file
var releaseLevel = 0;

var attackTime = 0.0001;
var decayTime = 0.2;
var susPercent = 1;
var releaseTime = 0.1;
var octaves = 5;

var cols = 7;


//var notes = [0,6,7,9,12,14,16,19,24];
//var notes = [ 0, 2, 4, 7, 9, 11 ];
//var notes = [0, 2, 4, 7, 9, 11, 14];

var notes = [0,1,3,7,8]; //Pelog

//notes = [0,2,4,5,8];
//var notes = [0,5,7];

// make a deep copy (not just the reference!)
var notesLeft = notes.slice(0,notes.length);

//lowest note
var bottom_pitch = 45;

var env, osc, reverb, osc2;

//how often to make a new note & dot
var frameInterval = 10;

//frame counter
var frame = 0;
var i = 0;

var bgColor; 

//my hot calder colors
var colors = "#fc0,#ff5c00,#0066ff,#ee1111,#ff2e00".split(",");


function setup() {
  bgColor = color("#362d20");
  background(bgColor);      

  createCanvas(window.innerWidth, window.innerHeight);

  env = new p5.Env();
  env.setADSR(attackTime, decayTime, susPercent, releaseTime);
  env.setRange(attackLevel, releaseLevel);

  osc = getOsc(env);
  osc2 = getOsc(env);


  frameRate(60);

  //avoid clipping in captured audio
  masterVolume(0.5)

}

function getOsc(envelope) {
  var myOsc = new p5.Oscillator('sine');
  myOsc.amp(envelope);

  reverb = new p5.Reverb();
  reverb.process(myOsc,reverbTime,1);

  return(myOsc);
}


function draw() {
  //var index = Math.round(random(notes.length));

  if(playing && frame % frameInterval == 0) {
    
    if(!osc.started) {
      osc.start();
      osc2.start();
    }

    //circles
    //fill(randColor());
    //fill(0,0,0,150);
    var thisColor = random(colors);
    fill(thisColor);
    noStroke();
    var margin = width/(cols*4);
    var diam = (width-margin*2)/cols;
    var rows = (height-margin*2)/diam;
    /*if(thisColor == "#ff2e00") {
      diam = (width-margin*2)/(cols * 2);
      ellipse(margin + Math.round(random(cols-1)) * diam * 2,margin+ Math.round(random(rows-1)) * diam * 2,diam*0.8);        
    }else{
      ellipse(margin+ Math.round(random(cols-1)) * diam + (diam/2),margin+ Math.round(random(rows-1)) * diam + (diam/2),diam*0.8);
    }*/
    
    ellipse(margin+ Math.round(random(cols-1)) * diam + (diam/2),margin+ Math.round(random(rows-1)) * diam + (diam/2),diam*0.8);

    
    var octave = Math.round(random(0,octaves));

    //don't repeat notes...
    while(note == previousNote) {
      note = random(notes);          
    }
    
    
    //or pull random notes out one by one from a buffer
    //out of notes? Refresh our "notes left" list from the master notes list
    /*if (notesLeft.length == 0 ) {
      notesLeft = notes.slice(0,notes.length); //deep copy
    }
    
    //or randomly pull out one at a time
    //note = notesLeft.splice(random(notesLeft.length),1)[0];
    */
    
    
    //or follow a predictable pattern
    //octave = 2; 
    //note = notes[i++ % notes.length];
    
    
    //console.log("prev:" + previousNote);
    var freq = midiToFreq(bottom_pitch + (octave * 12) + note);
    osc.freq(freq);
    //osc2.freq(freq * random([1,2,3,5,0.5])/4);
    //osc2.freq(freq*7/5);

    //two octaves down
    osc2.freq(freq/4);

    //creepy
    //osc2.freq(freq*7/11);
    
    if(!playing && osc.started){
      env.triggerRelease();
      osc.stop();
      osc2.stop();
    }

    //console.log(note);
    previousNote = note;
      
  }

  //fade....
  fill(color(bgColor._getRed(),bgColor._getGreen(),bgColor._getBlue(),15));
  //fill("rgba(0,0,0,5)");
  rect(0,0,width,height);


  
  frame++;

}

function mousePressed() {
  if (!playing) {
    //startRecording();
    env.triggerAttack();
    playing = true;
  } else {
    env.triggerRelease();
    //stop recording after reverbtime + 10%
    /*setTimeout(function() {
      debug('stopping recording (after reverb stops)');
    stopRecording()}, (reverbTime + releaseTime) * 1000 * 1.1);*/
    playing = false;
  }
}
