import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;

import processing.opengl.*;
import java.net.*;
import java.io.*;
Minim minim;
AudioInput inp;
AudioSample blender, coffee, cooker, microwave, shower, stove, tv;

/* --------------------------------------------------------------------------
 * SimpleOpenNI User3d Test
 * --------------------------------------------------------------------------
 * Processing Wrapper for the OpenNI/Kinect library
 * http://code.google.com/p/simple-openni
 * --------------------------------------------------------------------------
 * prog:  Max Rheiner / Interaction Design / zhdk / http://iad.zhdk.ch/
 * date:  02/16/2011 (m/d/y)
 * ----------------------------------------------------------------------------
 * this demos is at the moment only for 1 user, will be implemented later
 * ----------------------------------------------------------------------------
 */

import SimpleOpenNI.*;
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

SimpleOpenNI context;
float        zoomF =0.5f;
float        rotX = radians(180);  // by default rotate the hole scene 180deg around the x-axis, 
// the data from openni comes upside down
float        rotY = radians(0);
boolean      autoCalib=true;

PVector      bodyCenter = new PVector();
PVector      bodyDir = new PVector();

PVector centroide= new PVector();

PVector manoDer = new PVector();
PVector manoIzq = new PVector();
PVector codoDer = new PVector();
PVector codoIzq = new PVector();
PVector hombroDer = new PVector();
PVector hombroIzq = new PVector();
PVector cabeza = new PVector();
PVector cuello = new PVector();
PVector caderaDer = new PVector();
PVector caderaIzq = new PVector();
PVector rodillaDer = new PVector();
PVector rodillaIzq = new PVector();
PVector pieDer = new PVector();
PVector pieIzq = new PVector();

float yHombroD=0;

ArrayList <PVector> vectores= new ArrayList<PVector>();

String gesto="";
int gestoCnt=0;

int lugar=0;
String place="LOCK...";
boolean active=false;
int activeCnt=0;

int timeRef=0;

float [][] primeraPose=new float [14][2];
float [][] poseAnimal=new float [14][2];
float pitchPierna;
int actionCount=0;

PImage star;
boolean detect;

void setup()
{
  size(800, 600);  // strange, get drawing error in the cameraFrustum if i use P3D, in opengl there is no problem
  context = new SimpleOpenNI(this);

  // Minim
  minim = new Minim(this); 

  try {
    oscP5 = new OscP5(this, 9000);
    myRemoteLocation = new NetAddress(InetAddress.getLocalHost(), 12000);
  }
  catch(Exception e) {
  }
  // disable mirror
  context.setMirror(true);
  textMode(MODEL);

  // enable depthMap generation 
  if (context.enableDepth() == false)
  {
    println("Can't open the depthMap, maybe the camera is not connected!"); 
    exit();
    return;
  }

  // enable skeleton generation for all joints
  context.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);

  stroke(255, 255, 255);
  smooth();

  vectores.add(manoDer);
  vectores.add(manoIzq);
  vectores.add(codoDer);
  vectores.add(codoIzq);
  vectores.add(hombroDer);
  vectores.add(hombroIzq);
  vectores.add(cabeza);
  vectores.add(cuello);
  vectores.add(caderaDer);
  vectores.add(caderaIzq);
  vectores.add(rodillaDer);
  vectores.add(rodillaIzq);
  vectores.add(pieDer);
  vectores.add(pieIzq);

  primeraPose[0][0]= 490;
  primeraPose[0][1]= 322;
  primeraPose[1][0]= 309;
  primeraPose[1][1]= 316;
  primeraPose[2][0]= 475;
  primeraPose[2][1]= 260;
  primeraPose[3][0]= 331;
  primeraPose[3][1]= 251;
  primeraPose[4][0]= 439;
  primeraPose[4][1]= 202;
  primeraPose[5][0]= 359;
  primeraPose[5][1]= 202;
  primeraPose[6][0]= 398;
  primeraPose[6][1]= 156;
  primeraPose[7][0]= 399;
  primeraPose[7][1]= 202;
  primeraPose[8][0]= 422;
  primeraPose[8][1]= 297;
  primeraPose[9][0]= 378;
  primeraPose[9][1]= 297;
  primeraPose[10][0]= 431;
  primeraPose[10][1]= 393;
  primeraPose[11][0]= 362;
  primeraPose[11][1]= 392;
  primeraPose[12][0]= 448;
  primeraPose[12][1]= 480;
  primeraPose[13][0]= 349;
  primeraPose[13][1]= 478;
  poseAnimal[0][0]=532;
  poseAnimal[0][1]=206;
  poseAnimal[1][0]=374;
  poseAnimal[1][1]=112;
  poseAnimal[2][0]=494;
  poseAnimal[2][1]=233;
  poseAnimal[3][0]=338;
  poseAnimal[3][1]=149;
  poseAnimal[4][0]=442;
  poseAnimal[4][1]=208;
  poseAnimal[5][0]=372;
  poseAnimal[5][1]=196;
  poseAnimal[6][0]=415;
  poseAnimal[6][1]=155;
  poseAnimal[7][0]=407;
  poseAnimal[7][1]=202;
  poseAnimal[8][0]=413;
  poseAnimal[8][1]=300;
  poseAnimal[9][0]=371;
  poseAnimal[9][1]=294;
  poseAnimal[10][0]=405;
  poseAnimal[10][1]=401;
  poseAnimal[11][0]=452;
  poseAnimal[11][1]=321;
  poseAnimal[12][0]=395;
  poseAnimal[12][1]=473;
  poseAnimal[13][0]=483;
  poseAnimal[13][1]=414;

  star=loadImage("estrella.png");
}

void draw()
{
  // update the cam
  context.update();

  background(0, 0, 0);

  // set the scene pos

  int[]   depthMap = context.depthMap();
  int     steps   = 3;  // to speed up the drawing, draw every third point
  int     index;
  PVector realWorldPoint;

  // translate(0, 0, -1000);  // set the rotation center of the scene 1000 infront of the camera

  stroke(100); 

  // draw the skeleton if it's available
  int[] userList = context.getUsers();
  for (int i=0; i<userList.length && i<1;i++)
  {
    if (context.isTrackingSkeleton(userList[i])) {
      setVectors(userList[i]);//intento
      punticos();
    }
  }    

  // draw the kinect cam
  //context.drawCamFrustum();

  pushMatrix();
  fill(255);
  textSize(30);
  //text("angle: "+yHombroD, 20, 105);

  text("Status: "+lugar, 400, 30);

  switch(lugar) {

  case 0:
    //reposo

    //musica ambiente

    //gráfico


    break;

  case 1:
    //ACTO 1


      //pintar temporalmente los dots del chaman

    noFill();
    ellipseMode(CENTER);
    for (int i=0;i<primeraPose.length;i++) {
      ellipse(primeraPose[i][0], primeraPose[i][1], 15, 15);
    }

    detect=true;

    for (int i=0;i<vectores.size();i++) {
      PVector tmp= new PVector(vectores.get(i).x, vectores.get(i).y);
      float xx=400+map(tmp.x, 900, -900, 200, -200);
      float yy=250+map(tmp.y, 900, -900, -200, 200);

      if (abs(dist(xx, yy, primeraPose[i][0], primeraPose[i][1]))>15) {
        detect=false;
      }
    }

    if (detect) {
      lugar=2;
    }

    break;

  case 2:


    if ((pitchPierna)<0.2) {
      print("está arrodillado"+frameCount);

      //codos más arriba de hombro
      //manos antes que codos
      //manos "juntas"
      if ( codoDer.y>hombroDer.y &&
        codoIzq.y>hombroIzq.y &&
        manoIzq.z>codoIzq.z &&
        manoDer.z>codoDer.z &&
        abs(dist(manoDer.x, manoDer.y, manoIzq.x, manoIzq.y))<120) {

        println(", y en posición  "+abs(dist(manoDer.x, manoDer.y, manoIzq.x, manoIzq.y)));
        actionCount++;
        if (actionCount>30)
          lugar=3;
      }
      else {
        println(" ");
        if (actionCount>0)
          actionCount=0;
      }
    }


    break;

  case 3:

    noFill();
    ellipseMode(CENTER);
    for (int i=0;i<poseAnimal.length;i++) {
      image(star, poseAnimal[i][0], poseAnimal[i][1]);
    }

    detect=true;

    for (int i=0;i<vectores.size();i++) {
      PVector tmp= new PVector(vectores.get(i).x, vectores.get(i).y);
      float xx=400+map(tmp.x, 900, -900, 200, -200);
      float yy=250+map(tmp.y, 900, -900, -200, 200);

      if (abs(dist(xx, yy, primeraPose[i][0], primeraPose[i][1]))>15) {
        detect=false;
      }
    }

    if (detect) {
      lugar=4;
    }

    break;

  case 4:

    float anguloDer=degrees(PVector.angleBetween(new PVector(hombroDer.x-codoDer.x, hombroDer.y-codoDer.y, hombroDer.z-codoDer.z), new PVector(manoDer.x-codoDer.x, manoDer.y-codoDer.y, manoDer.z-codoDer.z)));
    float anguloIzq=degrees(PVector.angleBetween(new PVector(hombroIzq.x-codoIzq.x, hombroIzq.y-codoIzq.y, hombroIzq.z-codoIzq.z), new PVector(manoIzq.x-codoIzq.x, manoIzq.y-codoIzq.y, manoIzq.z-codoIzq.z)));

    if ((pitchPierna)<0.2 &&
      abs(dist(manoDer.x, manoDer.y, manoIzq.x, manoIzq.y))<120 &&
      codoDer.y<hombroDer.y &&
      codoIzq.y<hombroIzq.y &&
      abs(anguloDer-45)<10 &&
      abs(anguloIzq-45)<10) {
        
        println("COLOMBIAAA DIOS MIOOO GOOOOLL !!!");
    }

    break;

  case 5:

    break;
  }

  popMatrix();

  if (gestoCnt<20 && gesto!="") {
    gestoCnt++;
  }
  else {
    gestoCnt=0;
    gesto="";
  }
}

// draw the skeleton with the selected joints
void drawSkeleton(int userId)
{
  strokeWeight(3);



  // to get the 3d joint data
  /*
  drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);
   
   drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
   drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
   
   drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);
   
   drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
   drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
   drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);
   
   drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
   drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
   
   drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
   drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
   drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);
   
   drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
   drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
   drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);
   */
  // draw body direction

  /*getBodyDirection(userId, bodyCenter, bodyDir);
   
   bodyDir.mult(200);  // 200mm length
   bodyDir.add(bodyCenter);
   
   stroke(255, 200, 200);
   line(bodyCenter.x, bodyCenter.y, bodyCenter.z, 
   bodyDir.x, bodyDir.y, bodyDir.z);
   */
  strokeWeight(1);
}
//+ + + + + + +++ + + + + + + + + ++ + + +  + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + ++ + + + + + + 
public void setVectors(int userId) {

  PVector v1=new PVector();

  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_TORSO, centroide);


  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, v1);//MANOS
  manoDer.set(v1.x-centroide.x, v1.y-centroide.y, v1.z-centroide.z);

  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, v1);
  manoIzq.set(v1.x-centroide.x, v1.y-centroide.y, v1.z-centroide.z);

  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, v1);//CODOS
  codoDer.set(v1.x-centroide.x, v1.y-centroide.y, v1.z-centroide.z);

  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, v1);
  codoIzq.set(v1.x-centroide.x, v1.y-centroide.y, v1.z-centroide.z);

  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, v1);//HOMBROS
  hombroDer.set(v1.x-centroide.x, v1.y-centroide.y, v1.z-centroide.z);

  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, v1);
  hombroIzq.set(v1.x-centroide.x, v1.y-centroide.y, v1.z-centroide.z);

  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HIP, v1);//CADERAS
  caderaDer.set(v1.x-centroide.x, v1.y-centroide.y, v1.z-centroide.z);

  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HIP, v1);
  caderaIzq.set(v1.x-centroide.x, v1.y-centroide.y, v1.z-centroide.z);

  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, v1);//RODILLAS
  rodillaDer.set(v1.x-centroide.x, v1.y-centroide.y, v1.z-centroide.z);

  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_KNEE, v1);
  rodillaIzq.set(v1.x-centroide.x, v1.y-centroide.y, v1.z-centroide.z);

  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_FOOT, v1);//PIES
  pieDer.set(v1.x-centroide.x, v1.y-centroide.y, v1.z-centroide.z);

  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_FOOT, v1);
  pieIzq.set(v1.x-centroide.x, v1.y-centroide.y, v1.z-centroide.z);

  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_HEAD, v1);//CABEZA
  cabeza.set(v1.x-centroide.x, v1.y-centroide.y, v1.z-centroide.z);

  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_NECK, v1);//CUELLO
  cuello.set(v1.x-centroide.x, v1.y-centroide.y, v1.z-centroide.z);

  getAngles();
}

public void getAngles() {

  PVector tmp=new PVector(codoDer.x-hombroDer.x, codoDer.y-hombroDer.y, codoDer.z-hombroDer.z);
  float p=dist(0, 0, tmp.x, tmp.z);
  yHombroD=degrees(atan2(tmp.y, p));
}

public void punticos() {

  pushMatrix();

  translate((centroide.x*0.3)+400, 250);
  strokeWeight(10);
  stroke(255);

  for (int i=0;i<vectores.size();i++) {
    PVector tmp=vectores.get(i);
    point(map(tmp.x, 900, -900, 200, -200), map(tmp.y, 900, -900, -200, 200));
  }
  point(0, 0);
  strokeWeight(1);

  popMatrix();
}

//+ + + + + + +++ + + + + + + + + ++ + + +  + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + ++ + + + + + 

// -----------------------------------------------------------------
// SimpleOpenNI user events

void onNewUser(int userId)
{
  println("onNewUser - userId: " + userId);
  println("  start pose detection");

  if (autoCalib) {
    context.requestCalibrationSkeleton(userId, true);
  }
  else    
    context.startPoseDetection("Psi", userId);

  if (lugar==0)
    lugar=1;
}

void onLostUser(int userId)
{
  println("onLostUser - userId: " + userId);
  lugar=0;
}

void onExitUser(int userId)
{
  println("onExitUser - userId: " + userId);
}

void onReEnterUser(int userId)
{
  println("onReEnterUser - userId: " + userId);
}


void onStartCalibration(int userId)
{
  println("onStartCalibration - userId: " + userId);
}

void onEndCalibration(int userId, boolean successfull)
{
  println("onEndCalibration - userId: " + userId + ", successfull: " + successfull);

  if (successfull) 
  { 
    println("  User calibrated !!!");
    context.startTrackingSkeleton(userId);
  } 
  else 
  { 
    println("  Failed to calibrate user !!!");
    println("  Start pose detection");
    context.startPoseDetection("Psi", userId);
  }
}

void onStartPose(String pose, int userId)
{
  println("onStartdPose - userId: " + userId + ", pose: " + pose);
  println(" stop pose detection");

  context.stopPoseDetection(userId); 
  context.requestCalibrationSkeleton(userId, true);
}

void onEndPose(String pose, int userId)
{
  println("onEndPose - userId: " + userId + ", pose: " + pose);
}

//Guardar posición

public void printPose() {

  for (int i=0;i<vectores.size();i++) {
    PVector tmp=vectores.get(i);
    point(map(tmp.x, 900, -900, 200, -200), map(tmp.y, 900, -900, -200, 200));
    println("poseAnimal["+i+"][0]="+(400+map(tmp.x, 900, -900, 200, -200))+";");
    println("poseAnimal["+i+"][1]="+(250+map(tmp.y, 900, -900, -200, 200))+";");
  }
}

// -----------------------------------------------------------------
// Keyboard events

void keyPressed()
{

  if (key==CODED) {
    if (keyCode==SHIFT) 
      printPose();

    if (keyCode==ALT) {
      context.finalize();
      context = new SimpleOpenNI(this);
      // disable mirror
      context.setMirror(true);
      // enable depthMap generation 
      if (context.enableDepth() == false)
      {
        println("Can't open the depthMap, maybe the camera is not connected!"); 
        exit();
        return;
      }
      // enable skeleton generation for all joints
      context.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);
    }
  }
  else {
    lugar=Integer.parseInt(String.valueOf(key));
  }
}



void mouseReleased() {
  println("mouseX: "+mouseX+"  mouseY: "+mouseY);
}

void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  if (theOscMessage.addrPattern().equals("/wii/1/accel/pry/0")) {
    // println("llegando el pitch");
    pitchPierna=theOscMessage.get(0).floatValue();
  }
  if (theOscMessage.addrPattern().equals("/wii/1/button/A")) {
    // println("llegando el pitch");
    printPose();
  }
}

