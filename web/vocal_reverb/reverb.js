
var muted = true;
var reverbTime = 40;
var maxTime = 200;
var reverbs = [];
var recorder;
var red_color = "#c00";
var gray_color = "#999";
var maxVerbs = 4; // start killing 'em off after we have this many
var timeSlider; // a slider for our reverbtime
var mic = null; //initially...

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
  r.amp(0,10);
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
    background(red_color);
    debug("listening...");
  }else{
    mic.stop();
    background(gray_color);
    debug("muted");
  }
}

function toggleMute() {
  mute(!muted);
}
