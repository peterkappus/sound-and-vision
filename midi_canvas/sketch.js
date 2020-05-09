"use strict";

var bgColor = 255;

var frame = 0;
//how many frames to capture
var totalFrames = 80000;
var strokeFatness = 0.2; //percentage
var bgAlpha = 255;
var bgAlphaFactor = 1;
var alphaFactor = 1;
var longevityFactor = 0.999;
var dRad = 0.998;

//want to capture?
var doCapture = false;

var canvas;
var capturer;
var spacing = 1; //how close can they get?
var dr = 0.5;
var spawnProbability = 90;
var randSeed = 0;

var controlChannels = [];
var usedChannels = [];

var colorStrings = [
  //my hot calder colors
  "#fc0,#ff5c00,#0066ff,#ee1111,#ff2e00",
  //https://www.colourlovers.com/palette/379413/you_are_beautiful
  "#351330,#424254,#64908A,#E8CAA4,#CC2A41,#351330,#424254,#64908A",
  "#ECD078,#D95B43,#C02942,#542437,#53777A,#ECD078,#D95B43,#C02942",
  //https://www.colourlovers.com/palette/131576/Maddening_Caravan
  "#FAD089,#FF9C5B,#F5634A,#ED303C,#3B8183,#FAD089,#FF9C5B,#F5634A",
  //https://www.colourlovers.com/palette/73612/sakura_and_sumi
  //"#464040,#7C7171,#E4C7CC,#DB929E,#EC4D68,#464040,#7C7171,#E4C7CC",
  //https://www.colourlovers.com/palette/42281/lotus_mandala
  //"#942724,#EF1C23,#F8931D,#EEB949,#FFDA77,#942724,#EF1C23,#F8931D",
  //https://www.colourlovers.com/palette/988529/Cuban_Cherry
  //"#503735,#663230,#7C2C2C,#912627,#A72122,#503735,#663230,#7C2C2C",
  //https://www.colourlovers.com/palette/463395/
  "#042608,#2A5C0B,#808F12,#FAEDD9,#EA2A15,#042608,#2A5C0B,#808F12",
];

var colors = [];
//var colors = ["#eee","#aaa","#111","#333"];

var circs = [];

function setup() {
  colors = random(colorStrings).split(",");
  
  //square
  var canvasHeight, canvasWidth;
  //canvasHeight = canvasWidth = window.innerHeight * 0.8;
  
  //use the shorter of the two dimensions
  if( window.innerHeight > window.innerWidth) {
    canvasHeight = canvasWidth = window.innerWidth * 0.9;
  }  
  //canvas = createCanvas(canvasWidth, canvasHeight);

  //OR 
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
    
    WebMidi.inputs[1].addListener('controlchange', "all", respondToControllerChange);  
    WebMidi.inputs[0].addListener('controlchange', "all", respondToControllerChange);  
    
    WebMidi.inputs[1].addListener('noteon', "all", noteOn);    
    WebMidi.inputs[0].addListener('noteon', "all", noteOn);    
  }
  
});


function noteOn (e) {
          bgColor *= 1.01;
          circs.push(new Circ(e.note.number,e.velocity,circs[circs.length-1]));
          //console.log("Received 'noteon' message (" + e.note.name + e.note.octave + " " + e.note.number + " " + e.velocity + ").");
        }

function respondToControllerChange(e) {
  var controllerNumber = e.controller.number;
  
  console.log("Received 'controlchange' message.", controllerNumber);
  
  'bgAlpha fatness alpha dRad'.split(" ").forEach(name => {
    if(typeof(controlChannels[name]) == "undefined" && typeof(usedChannels[controllerNumber]) == "undefined" ) {
      controlChannels[name] = controllerNumber;
      usedChannels[controllerNumber] = true;
      console.log("assigning " + name + " to " + controllerNumber);
    }
  });
  
  if(controllerNumber == controlChannels['bgAlpha']) {
    bgAlphaFactor = map(e.value, 0,127,0,0.3);
  }
  
  if(controllerNumber == controlChannels['fatness']) {
    strokeFatness = map(e.value,0,127,0,1.5);
  } 
  
  if(controllerNumber == controlChannels['alpha']) {
    alphaFactor = map(e.value,0,127,0.95,1);
  }
  
  if(controllerNumber == controlChannels['dRad']) {
    dRad = map(e.value,0,127,0.95,1.05);
  }
  
  //c3
  /*if(e.controller.number == 19) {
    longevityFactor = map(e.value,0,127,0.99,0.9999);
  }*/
  
}
  
  
function draw() {
  //FUN-> turn this off to "paint"
  
  background(bgColor,bgAlphaFactor * 255);
  
  //gradually fade to black
  //background(bgColor *= 0.999);
  
  //first draw & move 'em
  for(var i in circs){
    circs[i].draw();
    circs[i].step();
  }
  
  //in a separate loop, delete the ones which have wandered off screen... otherwise flickering happens! :(
  for(var i in circs){
    var c = circs[i];
    //remove circs which go offscreen
    if(c.y + (c.rad * 2) < 0 || c.y - (c.rad * 2) > height || c.x - (c.rad * 2) > width || c.x + (c.rad * 2) < 0 || c.life < 0.001 || c.alpha < 0.1) {
      delete circs[i];
      circs.splice(i,1);    
    }
  }
  
  //see if we should shift the breeze
  if(random() < 0.01) {
    //slowly shift the starting point for our perlin noise by adding this to every calculation
    randSeed += 0.01;
    console.log("shift");
  }
}

class Circ{
  constructor(note, vel, link){
    this.life = 1;//degrades from 100%
    this.link = link;
    this.note = note;
    this.vel = vel;
    this.stroke = vel*20*strokeFatness;
    //this.alpha = random(220,250);
    this.randSeed = random(0,0.1);
    this.color = color(random(colors));
    //this.r = random(255);
    //this.g = random(255);
    //this.b = random(255);
    this.alpha = 255;
    this.dalpha = random(0.998,0.9999);
    //lowest note on 88 key keyboard is 21, highest is 108 (on my kawai anyway...)
    //found via console.log(this.note);
    this.x = map(this.note,21,108,0,width);
    this.rad = random(0.8,1.2) * map(this.vel, 0, 1, width/700, width/20);
    this.y = height * random(0.8,0.9);
    //this.dy = random(-0.1,0.5);
    this.dy = random(-1.0,-0.05);
    this.dx = random(-0.5,0.5);
  }
  
  draw() {
    fill(this.color);
    //fill(this.r, this.g, this.b, this.alpha);
    noStroke();
    ellipse(this.x,this.y,this.rad * 2,this.rad * 2);
    if(this.link){
      strokeWeight(this.stroke * this.life);
      stroke(5,1500 * sq(this.link.life));
      line(this.x,this.y,this.link.x,this.link.y);      
    }
  }

  step(){
    //this.rad *= 0.999;
    this.life *= longevityFactor;
    this.rad *= dRad;
    //this.rad *= 0.998;
    //this.alpha *= this.dalpha;
    this.alpha *= alphaFactor;
    //this.alpha *= this.dalpha;
    this.color.setAlpha(this.alpha);
    this.dalpha *= 0.999;
    //this.fill *= 0.9999;
    this.y += this.dy 
    this.x += this.dx;
    this.dx = 1.2 * map(noise(randSeed + this.x * 0.001, this.y * 0.001),0,1,-2,2);
    //accelerate
    this.dy *= 1.002 ;// * (this.y * 0.0001);        
  }
}
