"use strict";

var bgColor = 255;
var frame = 0;
//how many frames to capture
var totalFrames = 80000;
var strokeFatness = 0.0; //percentage
var bgAlpha = 255;
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
var assignedParams = [];

var params = [];

var paramNames = "red green blue dAlpha shrinkFactor longevityFactor bgAlphaFactor strokeFatness";
  paramNames.split(" ").forEach(name => {
    //assign to an object so we can reference it from our channels array, too
    params[name] = {
        value: 0,
        name: name
    };
  });


var bg;

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

var objects = [];

function setup() {
  bg = color(255,253,0,255);
  //colors = ["#fff"];
  //random(colorStrings).split(",");
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
  
  //occasionally make a burst of many circles
  /*if(random() < 0.1) {
    for(var i =0; i < random(8); i++){
      objects.push(new Circ(e.note.number,e.velocity,objects[objects.length-1],random(0.2,0.7)));
    }
  }else{
    objects.push(new Circ(e.note.number,e.velocity,objects[objects.length-1],1));
  }
  */

  objects.push(new MyLine(e.note.number, e.velocity));
  
  //console.log("Received 'noteon' message (" + e.note.name + e.note.octave + " " + e.note.number + " " + e.velocity + ").");
}

function respondToControllerChange(e) {
  var controllerNumber = e.controller.number;
  
  //console.log("Received 'controlchange' message.", controllerNumber);
  var controlObject = controlChannels[controllerNumber];
  
  //first learn each controller and assign it to a param
  paramNames.split(" ").forEach(name => {
    
    if(typeof(controlChannels[controllerNumber]) == "undefined" && typeof(assignedParams[name]) == "undefined" ) {
      console.log(`Assigning number ${controllerNumber} to ${name}`);
      //point the channels array element to the params array element
      controlChannels[controllerNumber] = params[name];
      assignedParams[name] = true;
    }
    
  });
    
  //update the value
  if(typeof(controlObject) == "object") {
    console.log(`updating ${controlObject.name}`);
    controlObject.value = map(e.value,0,127,0,255);
  }
  
}
  
function getParam(name) {
  if(defined(params[name])) {
    return(params[name].value);
  } else {
    return(0);
  }
}

function defined(thing){
  return(typeof(thing) != "undefined");
}
  
function debug(msg){
  console.log(msg);
}

function draw() {
   background(getParam("red"),getParam("green"),getParam("blue"), map(getParam("bgAlphaFactor"),0,255,24,0));
   
  //gradually fade to black
  //background(bgColor *= 0.999);
  
  //first draw & move 'em
  for(var i in objects){
    objects[i].draw();
    objects[i].step();
  }
  
  //in a separate loop, delete the ones which have wandered off screen... otherwise flickering happens! :(
  for(var i in objects){
    var c = objects[i];
    //remove objects which go offscreen
    if(c.y + (c.rad * 2) < 0 || c.y - (c.rad * 2) > height || c.x - (c.rad * 2) > width || c.x + (c.rad * 2) < 0 || c.life < 0.001 || c.alpha < 0.1) {
      delete objects[i];
      objects.splice(i,1);    
    }
  }
  
  //see if we should shift the breeze
  if(random() < 0.01) {
    //slowly shift the starting point for our perlin noise by adding this to every calculation
    randSeed += 0.01;
  }
}

class MyLine {
  constructor(note, vel){
    this.note = note;
    this.vel = vel;
    this.stroke = vel * getParam("strokeFatness")/255;
    //this.alpha = random(220,250);
    this.randSeed = random(0,0.1);
    //this.color = color(random(colors));

    this.color = color(255);
    //lowest note on 88 key keyboard is 21, highest is 108 (on my kawai anyway...)
    this.y = map(this.note,21,108,height, height/2) ;
    this.x = map(this.note,21,108,0,width);
    console.log(this.note);
    //this.dy = random(-0.1,0.5);
    this.dy = random(-1.0,-0.05);
    this.alpha = 255;
    this.life = 1 ;
    this.rad = map(this.vel,0,1,height/500,height/20);
  }

  draw() {
    stroke(this.color);
    strokeWeight(this.life * 3);
    //stroke(5,1500 * sq(this.life));
    line(0,this.y, width, this.y);

    fill(0);
    ellipse(this.x,this.y,this.rad);
    //console.log('draw!');
    //console.log(this.y);
  }

  step() {
    this.y += this.dy;
    //this.life *= map(getParam("longevityFactor"),0,255,0.999,0.99999);
    this.life *= 0.999;
    this.alpha = 255 * this.life;//map(getParam("dAlpha"),0,255,254,255) * this.life;
    this.dy *= 1.001;

  }
}

class Circ{
  constructor(note, vel, link, scale=1){
    this.life = 1;//degrades from 100%
    this.link = link;
    this.note = note;
    this.vel = vel;
    this.stroke = vel * 20 * getParam("strokeFatness")/255;
    //this.alpha = random(220,250);
    this.randSeed = random(0,0.1);
    this.color = color(random(colors));
    //this.r = random(255);
    //this.g = random(255);
    //this.b = random(255);
    this.alpha = 255;
    //lowest note on 88 key keyboard is 21, highest is 108 (on my kawai anyway...)
    this.x = map(this.note,21,108,0,width);
    this.rad = random(0.8,1.2) * map(this.vel, 0, 1, width/700, width/20) * scale;
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
    this.life *= map(getParam("longevityFactor"),0,255,0.999,0.99999);
    this.rad *= map(getParam("shrinkFactor"),0,255,0.95,1.05);
    //this.rad *= 0.998;
    //this.alpha *= this.dalpha;
    this.alpha *= this.life;//map(getParam("dAlpha"),0,255,254,255) * this.life;
    //this.alpha *= this.dalpha;
    this.color.setAlpha(this.alpha);
    //this.fill *= 0.9999;
    this.y += this.dy 
    this.x += this.dx;
    //Gently wander side to side
    this.dx = 1.2 * map(noise(randSeed + this.x * 0.001, this.y * 0.001),0,1,-2,2);
    //accelerate
    this.dy *= 1.002 ;// * (this.y * 0.0001);        
  }
}
