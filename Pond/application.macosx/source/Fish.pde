class Fish  {

  float fsize;
  float[] tailP = {0,0};
  float[] tailPC = {0,0};
  float tailLength = 3.0f;
  float x, y, angle, speed;
  float maxSpeed, minSpeed;

  float energy = 1f; //energy to wriggle
  float wave = 0; //tail wave
  int wcount = 0;
  int uturn = 0;
  int boundTime = 0;

  float[] colour = {255,255,255};
  float tone = 0;
  boolean isBound = false;

  Fish( float px, float py, float s, float a, float size ) {
    tailP[1] = tailLength;
    tailPC[1] = tailLength;

    x = px;
    y = py;
    angle = a;
    speed = s;
    fsize = size;
  }

  // METHOD:  draw fish's curves
  void getFish(){
    float[] pos;
    beginShape( POLYGON );

    pos = calc( 0f, -1f, fsize );
    bezierVertex2( pos[0], pos[1] );
    pos = calc( 0.5f, -1f, fsize );
    bezierVertex2( pos[0], pos[1] );
    pos = calc( 1f, -0.5f, fsize );
    bezierVertex2( pos[0], pos[1] );
    pos = calc( 1f, 0f, fsize );
    bezierVertex2( pos[0], pos[1] );

    pos = calc( 1f, 1f, fsize );
    bezierVertex2( pos[0], pos[1] );
    pos = calc( tailPC[0], tailPC[1], fsize );
    bezierVertex2( pos[0], pos[1] );
    pos = calc( tailP[0], tailP[1], fsize );
    bezierVertex2( pos[0], pos[1] );

    pos = calc( tailPC[0], tailPC[1], fsize );
    bezierVertex2( pos[0], pos[1] );
    pos = calc( -1f, 1f, fsize );
    bezierVertex2( pos[0], pos[1] );
    pos = calc( -1f, 0f, fsize );
    bezierVertex2( pos[0], pos[1] );

    pos = calc( -1f, -0.5f, fsize );
    bezierVertex2( pos[0], pos[1] );
    pos = calc( -0.5f, -1f, fsize );
    bezierVertex2( pos[0], pos[1] );
    pos = calc( 0f, -1f, fsize );
    bezierVertex2( pos[0], pos[1] );

    endBezier();
    endShape();
  }

  // METHOD: set tail's position
  void setTail(float strength, float wave) {
    tailP[0] = strength*wave;
    tailP[1] = tailLength+tailLength/2 - abs( tailLength/4*strength*wave );
    tailPC[0] = strength*wave*-1;
  }

  // METHOD: translate a bezier ctrl point according to fish's angle and pos.
  float[] calc( float px, float py, float s ) {
    float a = atan2( py, px) + angle+ PI/2;
    float r = sqrt( (px*px + py*py) );
  float[] pos ={ x+r*s*cos(a), y+r*s*sin(a) };
    return pos;
  }

  // METHOD: wriggle
  protected void wriggle() {

    // calc energy
    if (energy > 1) {                           // if it has energy
      wcount+=energy*2;                       // tail sine-wave movement
    }

    // sine-wave oscillation
    if (wcount>120) {
      wcount = 0;
      energy =0;
    }

    wave = sin( wcount*3*PI/180 ); //sine wave
    float strength = energy/5 * tailLength/2; //tail strength

    // set tail position
    setTail( strength, wave );
    move();
  }

  ///////////////////////////////////

  // METHOD: find distance
  float dist( float px, float py ) {
    px -= x;
    py -= y;
    return sqrt( px*px + py*py );
  }

  float dist( Fish p ) {
    float dx = p.x - x;
    float dy = p.y - y;
    return sqrt( dx*dx + dy*dy );
  }

  // METHOD: find angle
  float angle( float px, float py ) {
    return atan2( (py-y), (px-x) );
  }

  float angle( Fish p ) {
    return atan2( (p.y-y), (p.x-x) );
  }

  // METHOD: move one step
  void move() {
    x = x+( cos(angle)*speed );
    y = y+( sin(angle)*speed );
  }

  // METHOD: speed change
  void speedChange( float inc ) {

    speed += inc;

    if (speed<minSpeed) speed=minSpeed;
    if (speed>maxSpeed) speed=maxSpeed;

  }

  // METHOD: direction change
  void angleChange( float inc ) {
    angle += inc;
  }

  // METHOD: set speed limit
  void setSpeedLimit( float max, float min ) {
    maxSpeed = max;
    minSpeed = min;
  }

  // METHOD: set angle
  void setAngle( float a ) {
    angle = a;
  }

  // METHOD: turn towards an angle
  void turnTo( float ta, float inc ) {

    if (angle < ta) {
      angleChange( inc );
    } else {
      angleChange( inc*-1 );
    }
  }

  // METHOD: set Color
  void setColor( float c1, float c2, float c3 ) {
    colour[0] = c1;
    colour[1] = c2;
    colour[2] = c3;
  }

  // METHOD: copy another fish's angle and pos
  void copyFish( Fish f ) {
    x = f.x;
    y = f.y;
    angle = f.angle;
    speed = f.speed;
  }

  ////////////////////////////////////

  // METHOD: check bounds and U-turn when near bounds
  boolean checkBounds( float turn )
  {
    boolean inbound = false;

    turn += boundTime/100;

    // calculate the "buffer area" and turning angle
    float gap = speed * PI/2/turn;
    if (gap > W/4) {
      gap = W/4;
      turn = (gap/speed)/PI/2;
    }

    // which direction to u-turn?
    if ( x-gap < 0 || x+gap > W || y-gap < 0 || y+gap > H) {

      if (uturn == 0) {

        float temp = angle;
        if (temp < 0) temp += PI*2;

        if ( temp >0 && temp<PI/2 ) {
          uturn = 1;
        } else if ( temp >PI/2 && temp<PI ) {
          uturn = -1;
        } else if ( temp>PI && temp<PI*3/2 ) {
          uturn = 1;
        } else if ( temp>PI*3/2 && temp<PI*2 ) {
          uturn = -1;
        } else {
          uturn = 1;
        }

        if (y-gap < 0 || y+gap > H) uturn *=-1;
      }

      // turn
      angleChange( turn*uturn );
      //energy += 0.1;

      inbound = true;

    } else { // when out, clear uturn
      uturn = 0;
      inbound = false;
    }

    x = (x<0) ? 0 : ( (x>W) ? W : x );
    y = (y<0) ? 0 : ( (y>H) ? H : y );

    isBound = inbound;
    boundTime = (inbound) ? boundTime+1 : 0;

    return inbound;

  }

  // METHOD: alignment -- move towards the same direction as the flock within sight
  void align( Fish fp, float angleSpeed, float moveSpeed ) {

    turnTo( fp.angle, angleSpeed+random(angleSpeed*3) ); // 0.001

    if ( speed > fp.speed ) {
      speedChange( moveSpeed*(-1-random(1)) ); //0.2
    } else {
      speedChange( moveSpeed );
    }

  }

  // METHOD: cohersion -- move towards the centre of the flock within sight
  void cohere( Fish[] flocks, float angleSpeed, float moveSpeed  ) {

    // get normalised position
    float nx = 0;
    float ny = 0;

    for (int i=0; i<flocks.length; i++) {
      nx += flocks[i].x;
      ny += flocks[i].y;
    }

    nx /= flocks.length;
    ny /= flocks.length;

    turnTo( angle(nx, ny), angleSpeed+random(angleSpeed*2) ); //0.001
    speedChange( moveSpeed ); //-0.1

  }

  // METHOD: seperation -- moves away from the flock when it's too crowded
  void seperate( Fish[] flocks, float angleSpeed, float moveSpeed  ) {

    // find normalised away angle
    float nA = 0;

    for (int i=0; i<flocks.length; i++) {
      nA += (flocks[i].angle+PI);
    }

    nA /= flocks.length;
    turnTo( nA, angleSpeed+random(angleSpeed*2) ); //0.001
    speedChange( moveSpeed ); //0.05
  }

  // METHOD: collision aviodance -- moves away quickly when it's too close
  void avoid( Fish[] flocks, float angleSpeed, float moveSpeed ) {

    for (int i=0; i<flocks.length; i++) {
      float dA = angle( flocks[i] ) + PI;

      x = x + cos(dA)*moveSpeed/2;
      y = y + sin(dA)*moveSpeed/2;

      turnTo( dA, angleSpeed+random(angleSpeed) ); //0.005
    }
    speedChange( moveSpeed ); //0.1
  }

  // METHOD: flee from predator
  void predator( float px, float py, float alertDistance, float angleSpeed, float moveSpeed ) {

    float d = dist( px, py );
    if ( d < alertDistance) {
      float dA = angle(px, py) + PI;
      x = x + cos(dA)*moveSpeed; //0.01
      y = y + sin(dA)*moveSpeed;
      turnTo( dA, angleSpeed+ random(angleSpeed) );
      if (tone <50) tone+=5;
    } else {
      if (tone>0) tone-=2;
    }

    speedChange( moveSpeed );
  }

  // METHOD: attracts towards a point (ie, ripple)
  void swarm( float px, float py, float d ) {
    float dA = angle(px, py);
    float dD = dist( px, py );

    turnTo( dA, PI/10 );
    if (isBound) {
      turnTo( dA, PI/10 );
    }
  }

  //////////////////////////////

  // METHOD: scan for the environment and determines behaviour
  void scanFlock( Fish[] flocks, float cohereR, float avoidR )
  {
    Fish[] near = new Fish[NUM];
    int nCount = 0;
    Fish[] tooNear = new Fish[NUM];
    int tnCount = 0;
    Fish[] collide = new Fish[NUM];
    int cCount = 0;
    Fish nearest = null;
    float dist = 99999;

    float tempA = angle;
    float tempS = speed;

    // check boundaries
    boolean inbound = (hasPredator>0) ? checkBounds(PI/16) : checkBounds( PI/24);

    for (int i=0; i<flocks.length; i++) {
      Fish fp = flocks[i];

      // check nearby fishes
      if (fp != this) {
        float d = dist( fp );
        if (d < cohereR ) {
          near[nCount++] = fp;

          if (dist > d ) {
            dist = d;
            nearest = fp;
          }

          if ( d <= avoidR ) {
            tooNear[tnCount++] = fp;
            if ( d <= avoidR/2 ) {
              collide[cCount++] = fp;
            }
          }
        }
      }

      // calc and make flocking behaviours
      Fish[] near2 = new Fish[nCount];
      Fish[] tooNear2 = new Fish[tnCount];
      Fish[] collide2 = new Fish[cCount];

      int j=0;
      for (j=0; j<nCount; j++) {
        near2[j] = near[j];
      }
      for (j=0; j<tnCount; j++) {
        tooNear2[j] = tooNear[j];
      }
      for (j=0; j<cCount; j++) {
        collide2[j] = collide[j];
      }

      if (!inbound && !hasRipple) {
        if (nearest!=null) {
          align( nearest, 0.1*PI/180, 0.2f );
        }
        cohere( near2, 0.1*PI/180, -0.1f );
      }
      seperate( tooNear2, (random(0.1)+0.1)*PI/180, 0.05f );
      avoid( collide2, (random(0.2)+0.2)*PI/180, 0.1f );
    }

    float diffA = (angle - tempA)*5;
    float diffS = (speed - tempS)/3;
    float c = diffA*180/(float)Math.PI;

    // wriggle tail
    energy += abs( c/150 );
    wriggle();

  }

  // METHOD: scan for food
  void scanPrey( Fish[] flocks, float range )
  {
    Fish[] near = new Fish[NUM];
    int nCount = 0;
    Fish[] tooNear = new Fish[NUM];
    int tnCount = 0;
    Fish[] collide = new Fish[NUM];
    int cCount = 0;
    Fish nearest = null;
    float dist = 99999;

    float tempA = angle;
    float tempS = speed;

    // look for nearby food
    for (int i=0; i<flocks.length; i++) {
      float d = dist( flocks[i] );
      if (dist > d ) {
        dist = d;
        nearest = flocks[i];
      }
    }

    // move towards food
    if (dist < range) {
      float gradient = dist/range;
      if (dist > range/2) {
        speedChange( 0.5f );
      } else {
        speedChange( -0.5f );
      }

      turnTo( angle( nearest ), 0.05f );

      float diffA = (angle - tempA)*10;
      float diffS = (speed - tempS)*5;
      float c = diffA*180/PI;

      energy += abs( c/150 );
    }

    // check boundaries
    boolean inbound = checkBounds( PI/16 );

    // wriggle tail
    wriggle();

  }
  
}
