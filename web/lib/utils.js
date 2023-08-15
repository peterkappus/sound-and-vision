
//Sound funcs
//let's record
var recorder, soundFile;

function startRecording() {
  debug('start recording');
  recorder = new p5.SoundRecorder();
  soundFile = new p5.SoundFile();
  recorder.record(soundFile);
}

function stopRecording() {
  recorder.stop();
  save(soundFile, 'abstraktor.wav');
}


//save
function keyPressed() {
  //alert(keyCode);
  if(keyCode == 68) {
    save("abstraktor" + Date.now() + ".svg");
  }
}