import KinectPV2.KJoint;
import KinectPV2.*;

KinectPV2 kinect;

long debt;
int houseCount = 8;
int othersCount = 5;
int targetCount = 6;
int housesLeft;
PFont comic;
PImage[] houses = new PImage[houseCount];
PImage[] others = new PImage[othersCount];
Target[] targets = new Target[targetCount];
PImage scope;

boolean armed;
boolean shot;
int lastHandState; //0 closed, 1 open

void setup(){
  //size(1920, 1080, P3D);
  fullScreen(P3D,2);
  println("width: "+width);
  println("height: "+height);
  kinect = new KinectPV2(this);

  kinect.enableSkeletonColorMap(true);
  kinect.enableColorImg(true);

  kinect.init();
  comic = loadFont("ComicSansMS-Bold-48.vlw");
  for(int i = 0; i < houseCount; i++){
    houses[i] = loadImage("house"+i+".png");
  }
  for(int i = 0; i < othersCount; i++){
    others[i] = loadImage("reindeer"+i+".png");
  }
  for(int i = 0; i < 4; i++){
    targets[i] = new Target(0, i);
  }
  targets[4] = new Target(1, 4);
  targets[5] = new Target(1, 5);
  scope = loadImage("crosshairs.png");
}

void draw(){
  background(0);
  pushMatrix();
  imageMode(CORNER);
  //image(kinect.getColorImage(), 0, 0, width, height);
  popMatrix();

  ArrayList<KSkeleton> skeletonArray =  kinect.getSkeletonColorMap();
  
  //individual JOINTS
  for (int i = 0; i < skeletonArray.size(); i++) {
    KSkeleton skeleton = (KSkeleton) skeletonArray.get(0);
    if (skeleton.isTracked()) {
      KJoint[] joints = skeleton.getJoints();

      color col  = skeleton.getIndexColor();
      fill(col);
      stroke(col);
      drawBody(joints);

      //draw different color for each hand state
      drawHandState(joints[KinectPV2.JointType_HandRight]);
     // drawHandState(joints[KinectPV2.JointType_HandLeft]);
    }
  }
  if(shot){
    background(255);
  }
  textFont(comic);
  textSize(70);
  textMode(CORNER);
  text("House Hunter", width/3-20, 100);
  textSize(30);
  text("tm", width/2+200, 100);
  textSize(30);
  text("throw rocks", 60, 400);
  text("you break you buy",60, 450);
  textSize(60);
  text("mortgage: $"+debt, 70, height-30);
  for(Target t : targets){
    t.update();
  }

}

class Target{
  int pic;
  boolean house; //is it a house?
  float x;
  float y;
  float z;
  float leftEdge;
  float rightEdge;
  float topEdge;
  float bottomEdge;
  float xSpeed;
  float ySpeed;
  String deathString;
  int payment;
  boolean visible;
  boolean shot;
  int deathTimer;
  int index;
  boolean indebted;
  float spin;
  
  Target(int type, int ind){ //1 is house anything else is other
    index = ind;
    spin = 0;
    if (type == 1){
      house = false;
    }else{
      house = true;
    }
    spawn();
  }
  
  void update(){
    x = x+xSpeed;
    y = y+ySpeed;
    leftEdge = x - 100;
    rightEdge = x + 100;
    topEdge = y - 100;
    bottomEdge = y + 100;
    if(x > width || x < 0){
      xSpeed = xSpeed * -1;
    }
    if(y > height || y < 0){
      ySpeed = ySpeed * -1;
    }
    if(house){
      pushMatrix();
      translate(x, y, z);
      rotateY(spin);
      imageMode(CENTER);
      image(houses[pic], 0, 0, 200, 200);
      textMode(CENTER);
      //text(int(x)+", ", 0, 100);
      //text(int(y), 50, 100);
      popMatrix();
      
    }
    if(!house){
      pushMatrix();
      translate(x,y,z);
      rotateY(spin);
      imageMode(CENTER);
      image(others[pic], 0, 0, 200, 200);
      popMatrix();
    }
    if(shot && deathTimer > 0){
      deathTimer--;
      spin = map(deathTimer, 200, 0, 100, 0);
      pushMatrix();
      translate(x,y, 0);
      textSize(60);
      textMode(CENTER);
      text(deathString, 0, 0);
      popMatrix();
      z-=50;
      if(!indebted){
        debt = debt + payment;
        indebted = true;
      }
    }
    if(shot && deathTimer <=0){
      spawn();
    }
    
  }
  void spawn(){
   if(house){
      pic = int(random(houses.length));
      payment = int(random(10000)+500);
      deathString = "$"+(payment);
      indebted = false;
    }else{
      pic = int(random(others.length));
      deathString = "why???";
    }
    x = random(width);
    y = random(height);
    z = 0;
    xSpeed = random(-2, 2);
    ySpeed = random(-2, 2);
    visible = true;
    shot = false;
    deathTimer = 200; //frames of text after shot
  }
}

void mouseClicked(){
  println("shot fired");
  println("miss at x:"+mouseX+"and y:"+mouseY);
  for(Target t : targets){
    if (mouseX > t.leftEdge && mouseX < t.rightEdge && mouseY < t.bottomEdge && mouseY > t.topEdge){
      t.shot = true;
      //println("hit at x:"+mouseX+"and y:"+mouseY);
      
    }
  }
}

//DRAW BODY
void drawBody(KJoint[] joints) {
  //drawBone(joints, KinectPV2.JointType_Head, KinectPV2.JointType_Neck);
  //drawBone(joints, KinectPV2.JointType_Neck, KinectPV2.JointType_SpineShoulder);
  //drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_SpineMid);
  //drawBone(joints, KinectPV2.JointType_SpineMid, KinectPV2.JointType_SpineBase);
  //drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderRight);
  //drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderLeft);
  //drawBone(joints, KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipRight);
  //drawBone(joints, KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipLeft);

  // Right Arm
  //drawBone(joints, KinectPV2.JointType_ShoulderRight, KinectPV2.JointType_ElbowRight);
  //drawBone(joints, KinectPV2.JointType_ElbowRight, KinectPV2.JointType_WristRight);
  drawBone(joints, KinectPV2.JointType_WristRight, KinectPV2.JointType_HandRight);
  drawBone(joints, KinectPV2.JointType_HandRight, KinectPV2.JointType_HandTipRight);
  drawBone(joints, KinectPV2.JointType_WristRight, KinectPV2.JointType_ThumbRight);

  // Left Arm
  //drawBone(joints, KinectPV2.JointType_ShoulderLeft, KinectPV2.JointType_ElbowLeft);
  //drawBone(joints, KinectPV2.JointType_ElbowLeft, KinectPV2.JointType_WristLeft);
  //drawBone(joints, KinectPV2.JointType_WristLeft, KinectPV2.JointType_HandLeft);
  //drawBone(joints, KinectPV2.JointType_HandLeft, KinectPV2.JointType_HandTipLeft);
  //drawBone(joints, KinectPV2.JointType_WristLeft, KinectPV2.JointType_ThumbLeft);

  // Right Leg
  //drawBone(joints, KinectPV2.JointType_HipRight, KinectPV2.JointType_KneeRight);
  //drawBone(joints, KinectPV2.JointType_KneeRight, KinectPV2.JointType_AnkleRight);
  //drawBone(joints, KinectPV2.JointType_AnkleRight, KinectPV2.JointType_FootRight);

  // Left Leg
  //drawBone(joints, KinectPV2.JointType_HipLeft, KinectPV2.JointType_KneeLeft);
  //drawBone(joints, KinectPV2.JointType_KneeLeft, KinectPV2.JointType_AnkleLeft);
  //drawBone(joints, KinectPV2.JointType_AnkleLeft, KinectPV2.JointType_FootLeft);

  //drawJoint(joints, KinectPV2.JointType_HandTipLeft);
  //drawJoint(joints, KinectPV2.JointType_HandTipRight);
  //drawJoint(joints, KinectPV2.JointType_FootLeft);
  //drawJoint(joints, KinectPV2.JointType_FootRight);

  //drawJoint(joints, KinectPV2.JointType_ThumbLeft);
  //drawJoint(joints, KinectPV2.JointType_ThumbRight);

  //drawJoint(joints, KinectPV2.JointType_Head);
}

//draw joint
void drawJoint(KJoint[] joints, int jointType) {
  //pushMatrix();
  //translate(joints[jointType].getX()/3, joints[jointType].getY()/3, joints[jointType].getZ());
  //ellipse(0, 0, 25, 25);
  //popMatrix();
}

//draw bone
void drawBone(KJoint[] joints, int jointType1, int jointType2) {
  //pushMatrix();
  //translate(joints[jointType1].getX()/3, joints[jointType1].getY()/3, joints[jointType1].getZ());
  //ellipse(0, 0, 25, 25);
  //popMatrix();
  //line(joints[jointType1].getX()/3, joints[jointType1].getY()/3, joints[jointType1].getZ(), joints[jointType2].getX()/3, joints[jointType2].getY()/3, joints[jointType2].getZ());
}

//draw hand state
void drawHandState(KJoint joint) {
  noStroke();
  if(handState(joint.getState())){
    println("shot fired");
    //println("miss at x:"+joint.getX()+"and y:"+joint.getY());
    for(Target t : targets){
      if (joint.getX()*0.53> t.leftEdge && joint.getX()*0.53 < t.rightEdge && joint.getY()*0.71 < t.bottomEdge && joint.getY()*0.71 > t.topEdge){
        t.shot = true;
        //println("hit at x:"+joint.getX()+"and y:"+joint.getY());    
      }
    }
  }
  pushMatrix();
  translate(joint.getX()*0.53, joint.getY()*0.71, 0);
  //ellipse(0, 0, 70, 70);
  imageMode(CENTER);
  image(scope, 0, 0, 50, 50);
  popMatrix();
}

/*
Different hand state
 KinectPV2.HandState_Open
 KinectPV2.HandState_Closed
 KinectPV2.HandState_Lasso
 KinectPV2.HandState_NotTracked
 */
Boolean handState(int handState) {
  switch(handState) {
  case KinectPV2.HandState_Open:
    fill(0, 255, 0);
    if(lastHandState == 0){ //if there was a fist last frame
      if (!shot){ //and we haven't fired a 1 frame shot
        shot = true; //we will next frame
      }
    }else{
      shot = false;
    }
    lastHandState = 1; //and keep track of our recent open hand
    break;
  case KinectPV2.HandState_Closed:
    shot = false; //arming
    fill(0, 0, 255);
    lastHandState = 0;
    break;
  case KinectPV2.HandState_Lasso:
    fill(0, 0, 255);
    break;
  case KinectPV2.HandState_NotTracked:
    fill(255, 255, 255);
    break;
  }
  return shot;
}
