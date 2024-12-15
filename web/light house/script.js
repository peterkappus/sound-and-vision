let osc;       // Variable to hold the oscillator
let duration = 1000; // Duration in milliseconds (1 second)
let startTime; // Variable to keep track of the current cycle start time

function setup() {
  createCanvas(400, 200);  // Create a canvas of 400x200 pixels
  background(0);           // Set the background to black
  
  // Initialize the sine wave oscillator
  osc = new p5.Oscillator('sine');
  osc.freq(440);  // Set the frequency to 440 Hz (A4 note)
  osc.amp(0.5);   // Set the amplitude to 0.5 for a moderate volume
  
  startTime = millis();  // Record the start time of the first cycle
}

function draw() {
  let currentTime = millis(); // Get the current time
  let elapsedTime = currentTime - startTime; // Calculate the elapsed time
  
  if (elapsedTime < duration) {
    // During the first 1 second, display the white disc and play the sound
    background(0);  // Set the background to black
    fill(255);      // Set the fill color to white
    ellipse(width / 4, height / 2, width / 2, height); // Draw a white disc on the left half
    if (!osc.started) { // Check if the oscillator has started
      osc.start();   // Start the oscillator
    }
  } else if (elapsedTime < 2 * duration) {
    // During the second 1 second, display a black screen and stop the sound
    background(0);   // Set the background to black
    if (osc.started) { // Check if the oscillator has started
      osc.stop();    // Stop the oscillator
    }
  } else {
    // Reset the start time after 2 seconds to repeat the cycle
    startTime = millis();
  }
}
