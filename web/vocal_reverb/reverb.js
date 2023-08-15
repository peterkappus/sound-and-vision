
var muted = true;
var reverbTime = 40;
var maxTime = 200;
var reverbs = [];
var recorder;
var red_color = "#c00";
var gray_color = "#999";
var maxVerbs = 8; // start killing 'em off after we have this many
var timeSlider; // a slider for our reverbtime
var mic = null; //initially...
var bg_color = gray_color;

var panning = 0;

//var reverbs = [];

//press "M" to mute
//press ENTER to save

function setup() {
  c = createCanvas(window.innerWidth,window.innerHeight);
  /*a = createDiv('this is some text');
  a.style("font-size: 5rem");
  a.parent("header");
  a.touchStarted(setReverb);
  a.style("width: 20%; min-height: 5rem; background: #00f");
  */
  
  /*timeSlider = createSlider(0, maxTime, reverbTime, 1)
  timeSlider.position(50, 50);
  timeSlider.style('width', '80%');
  */
    
  startRecording();
  createVoice(reverbTime);
}

function touchStarted() {

}

function update(id,value){
  msgTag = select(id);
  msgTag.html(value);
}

function updateVoices () {
  update("#voices","voices: " + reverbs.length);
}

function killAVerb() {
  //disconnect and then remove the oldest reverb on the stack.
  /*env = new p5.Envelope();
  env.setADSR(0, 0, 100, 20);
  env.setRange(1, 1);
*/
  r = reverbs.shift()
  r.amp(0,15);
  debug("fading...");
  setTimeout(function(){
    debug("killing"); 
    r.disconnect();
    updateVoices();
  }, 15000);
}

function setReverb(reverbTime) {
  mic.stop();
  mic = null;
  //var reverbTime = timeSlider.value();
  //alert('ok');
  //debug("reverbtime: " + reverbTime)
  createVoice(reverbTime);
}

//each voice has it's own reverb (should prevent crunchy noises)
function createVoice(time){
  //alert(")

  if(reverbs.length > maxVerbs){
    killAVerb();
  }
  
  mic = new p5.AudioIn();
  //mic.start();
  
  myVerb = new p5.Reverb();

  //add some data to the object
  myVerb.level = 0;
  myVerb.time = time;

  myVerb.process(mic,time,1);
  reverbs.push(myVerb);

  mute(true);
  updateVoices();
  update("#time","time: " + time);

}

function startRecording() {
  //debug('start recording');
  soundFile = new p5.SoundFile();
  recorder = new p5.SoundRecorder();
  recorder.record(soundFile);
}

function draw() {
  fill(255,255,255,25);
  var size =0;
  //debug(mic.getLevel());
  if(!muted){
    reverbs.forEach(verb => {
      
      //max volume... not working
      if(verb.level < mic.getLevel()) {
        verb.level = mic.getLevel();
      }
      //reverbs[reverbs.length-1].level = mic.getLevel();
      //debug(verb.level);
      size = map(verb.level,0,0.2,0,height);
      ellipse(width/2,height/2,size,size);

      //visual decay
      verb.level *= 0.995;//verb.time / maxTime;
      //debug(verb.level);

    });
  }

  noStroke();
  fill(color(bg_color)._getRed(),color(bg_color)._getGreen(),color(bg_color)._getBlue(),3);
  rect(0,0,width,height);
  //panning = map(mouseX, 0, width, -0.5, 0.5);
}

function debug(msg){
  update("#msg",msg);
  console.log(msg);
}

function stopRecording() {
  recorder.stop();
  save(soundFile, 'abstraktor.wav');
}

function keyPressed() {
  //alert();
    getAudioContext().resume()
  //number keys
  if (keyCode < 58 && keyCode > 47) {
    setReverb((keyCode-48) * maxTime / 10);
  }

  //"Enter"
  if(keyCode == 13){
    debug("Building/Saving");
    stopRecording();
  }

  //key "s" to "set" reverb and create a new voice (with new reverb)
  //should prevent clipping on old reverb object
  //if(keyCode == 83) {
  //  setReverb();
  //}


  //K: KillaVerb
  if(keyCode == 75) {
    killAVerb();
  }

  // T: Show (T)otal reverbs
  if(keyCode == 84) {
    debug("count: " + reverbs.length);
  }

  
  //M: mute
  if(keyCode == 77 ) {
    toggleMute();
  }
  //alert(keyCode);
}

function mute(state) {
  muted = state;
  if(!muted) {
    mic.start();
    bg_color = red_color;
    debug("listening...");
  }else{
    mic.stop();
    bg_color = gray_color;
    debug("muted");
  }
}

function toggleMute() {
  mute(!muted);
}
