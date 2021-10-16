"use strict";


var towerHeight, towerWidth;

function setup() {
  createCanvas(window.innerWidth, window.innerHeight);

  fill(0);

  towerHeight = window.innerHeight * 0.6;

  //ratio: 1368:208

  towerWidth = towerHeight * (208 / 1368);

  var baseX = window.innerWidth * 0.15;
  var baseY = window.innerHeight * 0.9;

  randLineFill(0,0,window.innerWidth, window.innerHeight);

  
  //north tower
  rect(baseX, baseY - towerHeight, towerWidth, towerHeight);


  //mast
  var mastHeight = towerHeight * (362 / 1368);
  var mastWidth = mastHeight/20;
  
  rect(baseX + (towerWidth / 2) - (mastWidth/2), baseY - towerHeight - mastHeight, mastWidth, mastHeight);
  
  randFill(baseX, baseY - towerHeight, towerWidth, towerHeight);
  
  //south tower
  baseX += towerWidth * 2;
  rect(baseX, baseY - towerHeight, towerWidth, towerHeight);
  
  //ground
  rect(0,baseY, window.innerWidth, (towerWidth));

  randFill(baseX, baseY - towerHeight, towerWidth, towerHeight);

}

function randLineFill(x,y,w,h) {
  
  strokeWeight(0.2);

  for(var i = 0; i < 10000; i++) {
    stroke(randColor());
    //strokeWeight(random(towerHeight / 500, towerHeight / 50));

    var px = (x - (w * 0.1)) + random(w * 1.1);
    var py = (y - (h * 0.1)) + random(h * 1.1);

    line(px * random(0.95,1.05), py * random(0.95,1.05), px + 60, py - 40);


  }

  noStroke();

}

function randFill(x,y,w,h) {
  
  stroke("#fff");
  strokeWeight(2);

  for(var i = 0; i < 200; i++) {
    ellipse(x + random(w), y + random(h), random(towerWidth/2000, towerWidth/500));
  }

  /*
  for(var i = 0; i < random(30,50); i++) {
    // stroke(randColor());
    //strokeWeight(random(towerHeight / 500, towerHeight / 50));
    line(x, y + random(h), x + w, y + random(h));
  }*/


  noStroke();

}

function randColor() {
  return color(random(0, 255), random(0, 255), random(0, 255));
}

function keyPressed() {
  var minWidthForSVG = 1200;
  //alert(keyCode);
  if(keyCode == 68) {

    if(window.innerWidth < minWidthForSVG) {
      alert("Window must be > " & minWidthForSVG & " to capture an SVG");
      return(false);
    }
    //data = canvas.elt.toBlob();
    var svgString = new XMLSerializer().serializeToString(document.querySelector('svg'));

    var blob = new Blob([svgString], {type: "image/svg+xml;charset=utf-8"});
    saveAs(blob, "abstraktor" + Date.now() + ".svg");

    //saveSVG(SVG, "svg","thing");
  }
}