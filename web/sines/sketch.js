"use strict";


function setup() {
  var canvasSideLength = (window.innerHeight > window.innerWidth) ? window.innerWidth : window.innerHeight;

  createCanvas(canvasSideLength, canvasSideLength,SVG);

  background(255);

  xflower();

  //save("mySVG.svg"); // give file name
  //print("saved svg");
}


function flower(x = 0.5) {
	clear();
	background("#fff");
	push();
	noFill();
	colorMode(HSB);
	strokeWeight(0.2);

	stroke(random(50),80,random(80));
	beginShape();

	var radius = width * 0.005;
	var count = 5000;// random(100,5000);

	var k = random(0,50);
	
	var radiusDelta = 1.005;
	var theta = 0;
	var angleIncrement = 0.01;

	//var v = k * factor;
	//$("#debug").html("factorA: " + factor + " FactorB: " + factorB)// + " k: " + k + " v: " + v + "count: " + count);
	translate(width / 2, height / 2);

	for(var i = 0; i < count; i++) {
		//curveVertex(sin(angle * k) * rad, sin(angle * v) * rad);
		var x = radius * Math.cos(k * theta) * Math.cos(theta);
		var y = radius * Math.sin(k * theta) * Math.cos(theta);

		curveVertex(x,y);
		//curveVertex(rad * Math.cos(angle), rad * Math.sin(angle));

		theta += angleIncrement;
		radius *= radiusDelta;
	}
	endShape();
	pop();
}


function xflower(x = 0.5) {
	clear();
	background("#fff");
	push();
	noFill();
	colorMode(HSB);
	strokeWeight(0.2);

	stroke(random(50),80,random(80));
	beginShape();

	var rad = width*0.15;
	var count = 2500;// random(100,5000);

	var factor = randFactor();
	var factorB = randFactor();

	var k = Math.PI*0.2/(factor + random(0.0001,0.001));//random(5);
	var v = Math.PI*16/((factor  * factorB +  random(0.0001,0.001)));

	var dr = 1.00038;
	var angle = 0;
	var angleIncrement = 5;
	//var v = k * factor;
	//$("#debug").html("factorA: " + factor + " FactorB: " + factorB)// + " k: " + k + " v: " + v + "count: " + count);
	translate(width / 2, height / 2);

	for(var i = 0; i < count; i++) {
		curveVertex(sin(angle * k) * rad, sin(angle * v) * rad);
		angle += angleIncrement;
		rad *= dr;
	}
	endShape();
	pop();
}

function randFactor() {
	return random([1,2,3,4,5,6,7,8,10,16,50,25]);
	//return random([1/3,3/5,2,3,5,4,7,12,15,21]);
}



function randColor() {
  return color(random(0, 255), random(0, 255), random(0, 255));
}

function keyPressed() {
  var minWidthForSVG = 1200;
  //alert(keyCode);
  if(keyCode == 68) {

    /*if(window.innerWidth < minWidthForSVG) {
      alert("Window must be > " & minWidthForSVG & " to capture an SVG");
      return(false);
    }*/


    //data = canvas.elt.toBlob();
    var svgString = new XMLSerializer().serializeToString(document.querySelector('svg'));

    var blob = new Blob([svgString], {type: "image/svg+xml;charset=utf-8"});
    saveAs(blob, "abstraktor" + Date.now() + ".svg");

    //saveSVG(SVG, "svg","thing");
  }
}