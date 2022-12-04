"use strict";


//my hot calder colors
var colors = "#fc0,#ff5c00,#0066ff,#ee1111,#ff2e00".split(",");
//var tones = [0,1,5,8];
//var tones = [0,7];
var tones = [0, 2, 4, 7, 9, 11];
//var tones = [0];

var bars = [];
var octaves = 4;
var bgColor;
var reverbTime = 1;
var playing= false;
var lowestNote = 30;
var highestNote;
var reverb;
var maxBars = 30;
var targetBars = 1;

//increment with each draw
var masterCounter = 0;
var dMasterCounter = 0.002;

//debounce our touches since mobile counts a press event on release...
var debounceTime = 5;
var timeSinceTouch = debounceTime;

function setup() {
  bgColor = color("#fff");  
  //reverb = new p5.Reverb();

  background(bgColor);      

  createCanvas(window.innerWidth, window.innerHeight);

  frameRate(10);

  //avoid clipping in captured audio
  masterVolume(0.7)
  
  highestNote = lowestNote + max(tones) + (octaves * 12);

  
}


class Bar{
  constructor(){
    this.maxThickness = height/3;
    this.age = 0;
    this.level = 0;
    this.maxLevel = random(0.3,1);
    this.maxAge = random(100,200);
    this.amp = 0;
    //start at 3PI/2 
    this.position = 0;
    
    this.osc = new p5.Oscillator('sine');
    this.osc.amp(this.level);
    
    this.note = lowestNote + random(tones) + (12 * Math.round(random(octaves)));
    this.osc.freq(midiToFreq(this.note));
    //detune slightly...
    this.osc.freq(midiToFreq(this.note) * random(0.995,1.005));
    this.osc.pan(-0.8 + random(1.6)); //pan -0.8 to 0.8
    //this.osc.pan(-1);
    this.osc.start();
    this.color = color(random(colors));
    this.lfoRate = random(0.02,0.05); //slow & low, that is the tempo.

  }
  
  
  draw() {
    //var level = noise(this.position);  //use perlin noise...
  
    //constrain sine wave from 0-1
    this.level = this.maxLevel * boundedSin(this.position);

    this.osc.amp(this.level * 0.3); //attenuate to avoid clipping
    //this.osc.pan(); //pan around a bit.
    this.position += this.lfoRate;
    this.age++;

    
    //top note based on setFreq params above
    this.y = map(this.note, lowestNote, highestNote, height, 0, true);
    //this.y = map(this.note, lowestNote, highestNote, height, 0, true);
    fill(this.color);
    noStroke();
    rect(0, this.y - (this.level * this.maxThickness/2), width, this.level * this.maxThickness );
        
    //console.log(this.age + " " + this.maxAge + " " + this.level);
  }  
}

function draw() {
  
  timeSinceTouch++;
  

  background("rga(255,255,255,10)");
  
  for(var i in bars){
    bars[i].draw();
  }  
  

  //in a separate loop, delete the ones which have wandered off screen... otherwise flickering happens! :(
  for(var i in bars){
    //if it's tiny and our age % 3 == 0 (to debounce the switch slightly)
    var bar = bars[i];
    if(bar.level < 0.0005 && bar.age >= bar.maxAge) {
      bar.osc.stop();
      delete bars[i];
      bars.splice(i,1);    
    }
  }
  
  //maybe make a new bar...
  if(playing && random() > 0.9 && bars.length <  targetBars){
    bars.push(new Bar());
  }
  
  targetBars = maxBars * boundedSin(masterCounter);
  
  //increment...
  masterCounter += dMasterCounter;
  
  
  //targetBars = 1 + ( maxBars / 2.5 * Math.pow(masterCounter,2/masterCounter));
  
  //targetBars = maxBars * ((Math.pow(masterCounter, 2/(masterCounter*15)) / 2) * sin(10/masterCounter) + 0.5);
  
  //y=x^{|_frac_{{2};{15|_cdot_x}}}|_cdot_|_frac_{{1};{2}}|_cdot_ sin({|_frac_{{10};{x}}})+0.5
  
}

//sine wave from 0 to 1 starting at the bottom of the curve (where x = 3*PI/2)
function boundedSin(x){
    x += 3 * Math.PI / 2;
    return ((sin(x) + 1) / 2);      
}


function mousePressed() {
  if(timeSinceTouch > debounceTime){
    playing = !playing;
    timeSinceTouch = 0;
    
    //first bar
    if(bars.length < 1) {
      masterCounter = 0;
      
      bars.push(new Bar());
    }
  }
}
