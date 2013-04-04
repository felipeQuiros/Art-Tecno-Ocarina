import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;

import processing.opengl.*;
import java.net.*;
import java.io.*;

Minim minim;
AudioInput inp;
AudioPlayer forestSoft;
AudioPlayer ocarina;
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

PImage bicepDer;
PImage bicepIzq;
PImage antebrazoDer;
PImage BG1;
PImage tronco;
PImage cintura;
PImage musloDer;
PImage musloIzq;
PImage ritual;
PImage ritualFilter;
PImage dios;
PImage luna;
PImage pto;
PImage fin;
PImage finFiltro;

int alphaRitualFilter=255;
int yFilter=0;

public void init() {
  /// to make a frame not displayable, you can 
  // use frame.removeNotify() 
  frame.removeNotify(); 

  frame.setUndecorated(true); 

  // addNotify, here i am not sure if you have  
  // to add notify again.   
  frame.addNotify(); 
  super.init();
}

void setup()
{
  size(800, 600);  // strange, get drawing error in the cameraFrustum if i use P3D, in opengl there is no problem
  context = new SimpleOpenNI(this);

  // Minim
  minim = new Minim(this);
  forestSoft=minim.loadFile("sonidos/forestSoft.mp3");
  ocarina=minim.loadFile("sonidos/Ocarina1.mp3");

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

  primeraPose[0][0]=470;
  primeraPose[0][1]=355;
  primeraPose[1][0]=324;
  primeraPose[1][1]=360;
  primeraPose[2][0]=460;
  primeraPose[2][1]=292;
  primeraPose[3][0]=340;
  primeraPose[3][1]=290;
  primeraPose[4][0]=440;
  primeraPose[4][1]=224;
  primeraPose[5][0]=361;
  primeraPose[5][1]=223;
  primeraPose[6][0]=402;
  primeraPose[6][1]=174;
  primeraPose[7][0]=401;
  primeraPose[7][1]=224;
  primeraPose[8][0]=422;
  primeraPose[8][1]=326;
  primeraPose[9][0]=375;
  primeraPose[9][1]=325;
  primeraPose[10][0]=434;
  primeraPose[10][1]=426;
  primeraPose[11][0]=358;
  primeraPose[11][1]=424;
  primeraPose[12][0]=456;
  primeraPose[12][1]=519;
  primeraPose[13][0]=343;
  primeraPose[13][1]=519;

  poseAnimal[0][0]=343;
  poseAnimal[0][1]=222;
  poseAnimal[1][0]=341;
  poseAnimal[1][1]=266;
  poseAnimal[2][0]=403;
  poseAnimal[2][1]=242;
  poseAnimal[3][0]=383;
  poseAnimal[3][1]=280;
  poseAnimal[4][0]=445;
  poseAnimal[4][1]=223;
  poseAnimal[5][0]=400;
  poseAnimal[5][1]=227;
  poseAnimal[6][0]=418;
  poseAnimal[6][1]=179;
  poseAnimal[7][0]=422;
  poseAnimal[7][1]=225;
  poseAnimal[8][0]=442;
  poseAnimal[8][1]=323;
  poseAnimal[9][0]=416;
  poseAnimal[9][1]=325;
  poseAnimal[10][0]=414;
  poseAnimal[10][1]=417;
  poseAnimal[11][0]=347;
  poseAnimal[11][1]=376;
  poseAnimal[12][0]=431;
  poseAnimal[12][1]=476;
  poseAnimal[13][0]=359;
  poseAnimal[13][1]=479;
  star=loadImage("estrella.png");

  bicepDer=loadImage("PngCortados/BrazoDerechoComplete.png");
  BG1=loadImage("PngCortados/BG.png");
  bicepIzq=loadImage("PngCortados/BrazoIzquierdoComplete.png");
  tronco=loadImage("PngCortados/Tronco.png");
  cintura=loadImage("PngCortados/Cadera.png");
  musloDer=loadImage("PngCortados/PiernaDerechaComplete.png");
  musloIzq=loadImage("PngCortados/PiernaIzquierdaComplete.png");

  ritual=loadImage("Ritual.png");
  ritualFilter=loadImage("FiltroRitual.png");
  luna=loadImage("Acto2NocheJaguarSin.png");
  pto=loadImage("PtoNegro.png");
  fin=loadImage("ActoFinal.png");
  finFiltro=loadImage("ActoFinalFiltro.png");
}

void draw()
{
  frame.setLocation(displayWidth, 0);
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

  // draw the kinect cam
  //context.drawCamFrustum();

  pushMatrix();
  fill(255);
  textSize(30);
  //text("angle: "+yHombroD, 20, 105);

  //text("Status: "+lugar, 400, 30);

  switch(lugar) {

  case 0:
    //reposo
    tint(255, 128);

    image(ritual, 0, 0, 800, 600);

    //musica ambiente
    forestSoft.play();
    ocarina.play();

    //gráfico


    break;

  case 1:
    //ACTO 1
ocarina.pause();

      //pintar temporalmente los dots del chaman

    tint(255, 128);
    image(BG1, 0, 0);

    int[] userList = context.getUsers();
    for (int i=userList.length-1; i<userList.length && i>=0 ;i++)
    {
      if (context.isTrackingSkeleton(userList[i])) {
        setVectors(userList[i]);//intento
        //punticos();
      }
    }  


    noFill();
    ellipseMode(CENTER);
    for (int i=0;i<primeraPose.length;i++) {
      // ellipse(primeraPose[i][0], primeraPose[i][1], 15, 15);
    }

    //BICEP DERECHO
    pushMatrix();
    translate(xMap(hombroDer.x), yMap(hombroDer.y));
    rotate(-PI/2-(new PVector(codoDer.x-hombroDer.x, codoDer.y-hombroDer.y).heading())+radians(15));
    image(bicepDer, -15, -25);
    popMatrix();

    //BICEP IZQUIERDO
    pushMatrix();
    translate(xMap(hombroIzq.x), yMap(hombroIzq.y));
    rotate(-PI/2-(new PVector(codoIzq.x-hombroIzq.x, codoIzq.y-hombroIzq.y).heading())-radians(15));
    image(bicepIzq, -55, -25);
    popMatrix();

    //PIERNA IZQUIERDA
    pushMatrix();
    translate(xMap(caderaIzq.x), yMap(caderaIzq.y));
    rotate(-PI/2-(new PVector(rodillaIzq.x-caderaIzq.x, rodillaIzq.y-caderaIzq.y).heading())-radians(5));
    image(musloIzq, -40, 10);
    popMatrix();

    //PIERNA DERECHA
    pushMatrix();
    translate(xMap(caderaDer.x), yMap(caderaDer.y));
    rotate(-PI/2-(new PVector(rodillaDer.x-caderaDer.x, rodillaDer.y-caderaDer.y).heading())+radians(5));
    image(musloDer, -25, 10);
    popMatrix();

    //CUERPO
    pushMatrix();
    translate(xMap(cuello.x), yMap(cuello.y));
    image(tronco, -tronco.width/2, -60);
    image(cintura, -cintura.width/2, 90);
    popMatrix();


    if (abs((xMap(centroide.x)-413))<3 &&
      abs(new PVector(codoIzq.x-hombroIzq.x, codoIzq.y-hombroIzq.y).heading()-(-1.7899449))<0.2 &&
      abs(new PVector(codoDer.x-hombroDer.x, codoDer.y-hombroDer.y).heading()-(-1.3536386))<0.2 &&
      abs(new PVector(rodillaIzq.x-caderaIzq.x, rodillaIzq.y-caderaIzq.y).heading()-(-1.671257))<0.2 &&
      abs(new PVector(rodillaDer.x-caderaDer.x, rodillaDer.y-caderaDer.y).heading()-(-1.4087418))<0.2)  
    {
      println("siiii");
      lugar=2;
    }


    break;

  case 2:

    image(ritual, 0, 0, 800, 600);

    tint(255, alphaRitualFilter);
    image(ritualFilter, 0, 0);

    if (alphaRitualFilter>30) {
      alphaRitualFilter-=5;
    }

    userList = context.getUsers();
    for (int i=userList.length-1; i<userList.length && i>=0 ;i++)
    {
      if (context.isTrackingSkeleton(userList[i])) {
        setVectors(userList[i]);//intento
        //punticos();
      }
    } 

    if ((pitchPierna)<0.6) {
      print("está arrodillado"+frameCount);

      //codos más arriba de hombro
      //manos antes que codos
      //manos "juntas"
      if ( codoDer.y>hombroDer.y &&
        codoIzq.y>hombroIzq.y &&
        manoIzq.z>codoIzq.z &&
        manoDer.z>codoDer.z &&
        abs(dist(manoDer.x, manoDer.y, manoIzq.x, manoIzq.y))<180) {

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

    tint(255, 255);
    image(luna, 0, 0, 800, 600);

    noFill();
    imageMode(CENTER);
    for (int i=0;i<poseAnimal.length;i++) {
      image(pto, poseAnimal[i][0], poseAnimal[i][1]);
    }
    imageMode(CORNER);
    userList = context.getUsers();
    for (int i=userList.length-1; i<userList.length && i>=0 ;i++)
    {
      if (context.isTrackingSkeleton(userList[i])) {
        setVectors(userList[i]);//intento
        punticosStar();
      }
    }

    detect=true;

    for (int i=0;i<vectores.size();i++) {
      PVector tmp= new PVector(vectores.get(i).x, vectores.get(i).y);

      if (abs(dist(xMap(tmp.x), yMap(tmp.y), poseAnimal[i][0], poseAnimal[i][1]))>20) {
        detect=false;
      }
    }

    if (detect) {
      lugar=4;
    }

    break;

  case 4:

    tint(255, 128);
    image(fin, 0, -300);
    image(finFiltro, 0, yFilter);

    userList = context.getUsers();
    for (int i=userList.length-1; i<userList.length && i>=0 ;i++)
    {
      if (context.isTrackingSkeleton(userList[i])) {
        setVectors(userList[i]);//intento
       // punticos();
      }
    } 


    float anguloDer=degrees(PVector.angleBetween(new PVector(hombroDer.x-codoDer.x, hombroDer.y-codoDer.y, hombroDer.z-codoDer.z), new PVector(manoDer.x-codoDer.x, manoDer.y-codoDer.y, manoDer.z-codoDer.z)));
    float anguloIzq=degrees(PVector.angleBetween(new PVector(hombroIzq.x-codoIzq.x, hombroIzq.y-codoIzq.y, hombroIzq.z-codoIzq.z), new PVector(manoIzq.x-codoIzq.x, manoIzq.y-codoIzq.y, manoIzq.z-codoIzq.z)));

    println("anguloDer: "+anguloDer+"  anguloIzq: "+anguloIzq);

    if ((pitchPierna)<0.6 &&
      abs(dist(manoDer.x, manoDer.y, manoIzq.x, manoIzq.y))<190 &&
      abs(anguloDer-45)<30 &&
      abs(anguloIzq-45)<30) {

      println("COLOMBIAAA DIOS MIOOO GOOOOLL !!!");
      yFilter+=5;
      
      ocarina.play();
      
      if (yFilter>600)
        exit();
    }
    else {
      if (yFilter>=0) 
        yFilter-=5;
        ocarina.pause();
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

public float xMap(float x) {
  return 400+map(x, 900, -900, 200, -200)+(centroide.x*0.3);
}
public float yMap(float y) {
  return 275+map(y, 900, -900, -200, 200);
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

  translate((centroide.x*0.3)+400, 275);
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

public void punticosStar() {

  pushMatrix();

  translate((centroide.x*0.3)+400, 275);
  imageMode(CENTER);
  for (int i=0;i<vectores.size();i++) {
    PVector tmp=vectores.get(i);
    image(star, map(tmp.x, 900, -900, 200, -200), map(tmp.y, 900, -900, -200, 200));
  }
  image(star, 0, 0);
  imageMode(CORNER);
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
}

void onLostUser(int userId)
{
  println("onLostUser - userId: " + userId);
  lugar=0;
  forestSoft.rewind();
}

void onExitUser(int userId)
{
  println("onExitUser - userId: " + userId);
}

void onReEnterUser(int userId)
{
  println("onReEnterUser - userId: " + userId);
  if (lugar==0)
    lugar=1;
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

    if (lugar==0)
      lugar=1;
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
    println("poseAnimal["+i+"][0]="+((int)(xMap(tmp.x)))+";");
    println("poseAnimal["+i+"][1]="+((int)(yMap(tmp.y)))+";");
  }


  //println("centroide: "+xMap(centroide.x));
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

