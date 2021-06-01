// This code was written with the _ALPHA_ version 
// of Processing and may not run correctly in the 
// current version.


// Pond
// by William Ngan <contact@metaphorical.net>
// Copyright(c)2003
// http://www.metaphorical.net

/*
The flocking behaviour applies Craig Reynolds' model described in his SIGGRAPH 1987 paper.
see http://www.red3d.com/cwr/papers/1987/boids.html for more details.
*/

//-- source code, not quite optimized... --//

int W, H;
int NUM = 40;

Fish[] flock = new Fish[NUM];
Fish bigfish1;
Fish bigfish2;
Fish bigfish3;

float rippleX, rippleY;
float[] ripple = new float[3];
boolean hasRipple;
int hasPredator = 0;

/* SETUP */
void setup()
{
  size( 600, 400 );
  W = width;
  H = height;
  background(6,22,48);
  colorMode(HSB, 360, 100, 100);
  frameRate(16);

  // small fish
  float lim = 50f;
  for (int i=0; i<NUM; i++) {
    flock[i] = new Fish( random(W), random(H), 1f, random(PI), random(5f,8f) );
    flock[i].setSpeedLimit( random(3f,4f), 0.5f );
    flock[i].setColor( 207, random(50), 100 );
  }
  // ripple
  for (int i=0; i<ripple.length; i++) {
    ripple[i] = 999;
  }
  // bigfish1
  bigfish1 = new Fish( random(W), random(H), 1f, random(PI), 12f );
  bigfish1.setSpeedLimit( 2f, 1f );
  bigfish1.setColor( 30,66,79 );
  // bigfish2
  bigfish2 = new Fish( random(W), random(H), 1f, random(PI), 15f );
  bigfish2.setSpeedLimit( 2f, 1f );
  bigfish2.setColor( 20,66,79 );
  // bigfish3
  bigfish3 = new Fish( random(W), random(H), 1f, random(PI), 20f );
  bigfish3.setSpeedLimit( 2f, 1f );
  bigfish3.setColor( 10,66,79 );
}


/* DRAW */
void draw() {
background(207,66,79);
  //stroke(207,66,79);
  //noFill();

  // draw bigfish
  if (hasPredator>0) {

    bigfish1.scanPrey( flock, 150f );
    bigfish1.predator( bigfish2.x, bigfish2.y, 100f, 6*PI/180f, 2f);
    bigfish1.predator( bigfish3.x, bigfish3.y, 100f, 6*PI/180f, 2f);
    bigfish1.predator( mouseX, mouseY, 50f, 5*PI/180f, 1f);
    bigfish1.move();
    fill( bigfish1.colour[0], bigfish1.colour[1], bigfish1.colour[2]);
    stroke( bigfish1.colour[0], bigfish1.colour[1], bigfish1.colour[2]);
    bigfish1.getFish();

    if (hasPredator>1) {
      bigfish2.scanPrey( flock, 120f );
      bigfish2.predator( bigfish1.x, bigfish1.y, 100f, 5*PI/180f, 1.5f);
      bigfish2.predator( bigfish3.x, bigfish3.y, 100f, 5*PI/180f, 1.5f);
      bigfish2.predator( mouseX, mouseY, 50f, 4*PI/180f, 0.8f);
      bigfish2.move();
      fill( bigfish2.colour[0], bigfish2.colour[1], bigfish2.colour[2]);
      stroke( bigfish2.colour[0], bigfish2.colour[1], bigfish2.colour[2]);
      bigfish2.getFish();

      if (hasPredator>2) {
        bigfish3.scanPrey( flock, 100f );
        bigfish3.predator( bigfish1.x, bigfish1.y, 100f, 5*PI/180f, 1.5f);
        bigfish3.predator( bigfish2.x, bigfish2.y, 100f, 5*PI/180f, 1.5f);
        bigfish3.predator( mouseX, mouseY, 50f, 3*PI/180f, 0.5f);
        bigfish3.move();
        fill( bigfish3.colour[0], bigfish3.colour[1], bigfish3.colour[2]);
        stroke( bigfish3.colour[0], bigfish3.colour[1], bigfish3.colour[2]);
        bigfish3.getFish();
      }
    }
  }

  // draw small fish
  noStroke();
  for (int i=0; i<flock.length; i++) {

    fill(flock[i].colour[0], flock[i].colour[1]+flock[i].tone, flock[i].colour[2]);

    if (hasRipple) {
      flock[i].swarm( rippleX, rippleY, 200 );
    }

    flock[i].scanFlock( flock, 200, 50 );

    if (hasPredator>0) {
      flock[i].predator( bigfish1.x, bigfish1.y, 100f, 8*PI/180f, 1.5f);
      if (hasPredator>1) {
        flock[i].predator( bigfish2.x, bigfish2.y, 100f, 8*PI/180f, 1.5f);
        if (hasPredator>2) flock[i].predator( bigfish3.x, bigfish3.y, 100f, 8*PI/180f, 1.5f);
      }
    }
    if (!hasRipple) flock[i].predator( mouseX, mouseY, 100f, 5*PI/180f, 1f);
    flock[i].move();
    flock[i].getFish();

  }

  // draw ripple
  stroke(207,100,30);
  noFill();
  hasRipple = false;
  for (int k=0; k<ripple.length; k++) {
    if (ripple[k]<W) {
      ripple[k]+=3f*(k+4);
      //ellipse( rippleX-ripple[k]/2, rippleY-ripple[k]/2, ripple[k], ripple[k]);
      ellipse( rippleX, rippleY, ripple[k], ripple[k]);
      hasRipple = true;
    }
  }

}

/* MOUSE */
void mouseDragged() {
  rippleX = mouseX;
  rippleY = mouseY;
}

void mousePressed() {
  rippleX = mouseX;
  rippleY = mouseY;
}

void mouseReleased() {
  if (!hasRipple) {
    for (int k=0; k<ripple.length; k++) {
      ripple[k]=0;
    }
    hasRipple = true;
  }
}

void keyPressed() {
  if(key == '1') {
    hasPredator = 1;
  } else if (key == '2') {
    hasPredator = 2;
  } else if (key == '3') {
    hasPredator = 3;
  } else if (key == '0') {
    hasPredator = 0;
  }
}

/* FISH */


// custom bezier curve methods
int precision = 40; // higher the value, smoother the curve but slower the speed
float[][] bp = new float[4][2]; // holds {p1, ctrlp1, ctrlp2, p2} for cubic curve
int bcount = 0; // bezier counter

// linear interpolation
static float[] linear( float[] p0, float[] p1, float t ) {
float[] pt = {(1-t)*p0[0] + t*p1[0], (1-t)*p0[1] + t*p1[1]};
  return pt;
}

// deCasteljau algorithm
static float[] bezier( float pts[][], float t ) {
  float[][] curr, next;
  next = pts;
  while( next.length >1 ) { // deCasteljau iterations
    curr = next;
    next = new float[ curr.length-1 ][2];
    for (int i=0; i<curr.length-1; i++) {
      next[i] = linear( curr[i], curr[i+1], t );
    }
  }
  return next[0];
}

// METHOD: draw cubic bezier curve -- similar to bezierVertex() method in proce55ing
void bezierVertex2( float px, float py ) {
float[] pt = {px, py};
  bp[bcount++] = pt;
  if (bcount > 3) {
    for(int i=0; i<=precision; i++) {
      float[] p = bezier( bp, i/(float)precision );
      vertex( p[0], p[1] );
    }
    bp[0] = bp[3];
    bcount = 1;
  }
}

void endBezier() {
  bcount = 0;
}

// end custom bezier curve methods
