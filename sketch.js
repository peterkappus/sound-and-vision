"use strict";

var bgColor = 255;
var latestNote;

var frame = 0;
//how many frames to capture
var totalFrames = 80000;

//want to capture?
var doCapture = false;

var canvas;
var capturer;
var spacing = 1; //how close can they get?
var dr = 0.5;
var spawnProbability = 90;
var maxAge = 500;

var colors = ["#fc0","#ff5c00","#0066ff","#ee1111","#ff2e00"];
//var colors = ["#eee","#aaa","#111","#333"];

var circs = [];

function setup() {
  //square
  var canvasHeight, canvasWidth;
  canvasHeight = canvasWidth = window.innerHeight * 0.8;
  
  //use the shorter of the two dimensions
  if( window.innerHeight > window.innerWidth) {
    canvasHeight = canvasWidth = window.innerWidth * 0.9;
  }  
  
  canvas = createCanvas(canvasWidth, canvasHeight);
  
  //use whole window
  canvas = createCanvas(window.innerWidth, window.innerHeight);
  
  if(doCapture && totalFrames > 0) {
    //capturer = new CCapture( { format: 'webm', verbose: true } );
    capturer = new CCapture( { format: 'png' } );
    //capturer = new CCapture( { format: 'gif', workersPath: '' } );
    
    capturer.start();
    
  }
  
}

WebMidi.enable(function (err) {

  if (err) {
    console.log("WebMidi could not be enabled.", err);
  } else {
    console.log("WebMidi enabled!");
    
    
    WebMidi.inputs[0].addListener('noteon', "all",
        function (e) {
          latestNote = e;
          bgColor += e.note.number*0.4;
          circs.push(new Circ(e.note.number,e.velocity));
          console.log("Received 'noteon' message (" + e.note.name + e.note.octave + " " + e.note.number + " " + e.velocity + ").");
        }
      );
  }
  
});

  
  
function draw() {
  background(bgColor *= 0.99);
  for(var i in circs){
    circs[i].draw();
    circs[i].step();
    //remove if offscreen
    if(circs[i].y > height-2){
      circs.splice(i,1);
    }
  }
}

class Circ{
  constructor(note, vel){
    this.note = note;
    this.vel = vel;
    this.fill = 255;
    this.x = random(width);
    this.y = random(height/4); //map(this.note, 0, 127, height, 0);
    this.rad = map(this.vel, 0, 1, width/20, width/5);
  }
  
  draw() {
    fill(this.fill);
    ellipse(this.x,this.y,this.rad * 2,this.rad * 2);
  }

  step(){
    this.rad *= 0.99;
    this.fill *= 0.999;
    this.y += (height - this.y) * 0.005;      
    
  }
}
