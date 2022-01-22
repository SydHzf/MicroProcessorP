import processing.video.*;  // Import Librarey to use video 
import processing.serial.*; //Import Librarey to use Serial Port (Bluetooth)


//**Global Variable Declarations**//
Serial port; //port is an object variable for Serial communication
int data; 
boolean calibration= false;
int mirror =0;
int mirrorn =-1;
PImage Done,Asha,Paint,LED_Toggle,LED_on,LED_off;
boolean key1,key2,key3,movePaint,PaintScreen,PaintScreenClear,moveLED,LEDscreen;
float Paintx,Painty,avgX,avgY,LEDx,LEDy;
int count;
PImage img = createImage(380, 290, RGB);
int Px,Py;
Capture video;  //create an object named video
color trackColor;  //variable to store the color that we are going to track
float threshold = 50  ; //can be varied by the user
//_____End of variable declaration______//


//*Function to load all the images from data folder of the sketch*//
void loadImages()
{
  Done = loadImage("Done.png"); 
  Asha = loadImage ("1nucleus.jpeg");
  Paint = loadImage("Paint.png");
  LED_Toggle = loadImage("LED_Toggle.png");
  LED_on = loadImage("LED_on.png");
  LED_off = loadImage ("LED_off.png");
}
//_____End of variable declaration______//


//**Executes only ones**//
void setup() {
  size(800, 600);
  loadImages();
  String[] cameras = Capture.list();
  printArray(cameras);
  video = new Capture(this, cameras[0]);
  video.start();
  key1=key2=key3=false;
  Paintx=width/10;
  Painty=height/8.5;
  LEDx=width/1.1;
  LEDy=height/8.5;
  movePaint=PaintScreen=PaintScreenClear=moveLED=LEDscreen=false;
  port = new Serial(this,Serial.list()[1],9600);
  println(Serial.list()); 
}
//**End of Setup**//


//**Triggered to update each frame of the video**//
void captureEvent(Capture video)  {//when a new image comes in
      video.read(); 
      }
//reas it as a video


//*Function to point which color to Track*//
void Calibrate()
{
   image(video,75,50);
   imageMode(CORNERS);
   image(Done,width/1.2,height/1.1,width,height); //position of the Done button
   if (mouseX>width/1.2 && mouseY>height/1.1) //If mouse is within the Done button
   {
   calibration=true;
   cursor(HAND);
   mirrorn=1;
   mirror=width;
   }

fill(#1B96E0);
textSize(20);

if (key1==true) //if hall sensor 1 is active on Arduino
text("Key-1 Pressed",width/12,height/1.05); //Text and its position
if (key2==true) //if hall sensor 2 is active on Arduino
text("Key-2 Pressed",width/12,height/1.05); //Text and its position
}
//_____End of Calibration______//


//*Function to represent the main Screen*//
void UI()
{
    imageMode(CORNERS);
    image(Asha,0,0,width,height);
    imageMode(CENTER);
    
    if ((avgX<(width/10+((width/4)/2)) && avgY<(height/8.5+((height/4)/2)) && key1==true) || (movePaint==true&&key1==true)) //if clicked inside the image
    {
    movePaint=true;
    image (Paint, avgX,avgY,width/4, height/4); //Drag the image
    }
    else if (movePaint==false)
    image (Paint, Paintx,Painty,width/4, height/4); //place the image at corner
    else
      PaintScreen=true; 
      
       if ((avgX>(width/1.1-((width/4)/2)) && avgY<(height/8.5+((height/4)/2)) && key1==true) || (moveLED==true&&key1==true)) //if clicked inside the image
    {
    moveLED=true;
    image (LED_Toggle, avgX,avgY,width/4, height/4); //Drag the image
    }
    else if (moveLED==false)
    image (LED_Toggle, LEDx,LEDy,width/4, height/4); //place the image at corner
    else
      LEDscreen=true; 
}
//_____End of main screen function______//


//*Function to represent the Paint Screen*//
void Paintfun()
{
    imageMode(CENTER);
    background(#0B196A);
    image (Paint, width/2,height/2,width/1.5, height); 
   
img.loadPixels();
for (int IX = 210, Px=0; IX<=590; IX++, Px++)
{
for (int IY = 85, Py=0; IY<=375; IY++, Py++)
  {
  if ((dist(avgX,avgY,IX,IY)<4)  && key1==true)
  img.pixels[(Px+(Py*img.width))] = color(255);  //color of the paint background updated
  if (key2==true)
  PaintScreen = false;
  }
}
img.updatePixels();

image(img, width/2, height/2.6);
}
//_____End of main Paintscreen function______//


//*Function to display Toggle LED screen*//
void LEDfun()
{
  imageMode(CENTER);
  background(255);
  image(LED_on,(width/2 - width/4), height/3,width/4, height/5);
  image(LED_off,(width/2 + width/4), height/3,width/4, height/5);
   textSize(50);
  textAlign(CENTER);
  if (key1==true && avgX<300 && avgY>150 && avgX>95 && avgY<260)
  { fill(#751EE8);
  text("LED turned on",width/2,height/1.5);
  port.write(121);
  }
  if (key1==true && avgX<700 && avgY>150 && avgX>500 && avgY<260)
  { fill(#FC0808);
  text("LED turned   off",width/2,height/1.5);
  port.write(110);
  }
}
//_____End of main LEDscreen function_____//


//*Function to know which key is pressed*//
void key_select() {
  
  switch(data){
  case 1: 
     key1=true; key2=true;
     break;
     
  case 2: 
     key1=false; key2=true;
     break;
     
  case 3: 
     key1=true; key2=false;
     break;
     
  case 4: 
     key1=false; key2=false;
     break;
}
}
//_____End of function______//



void draw() {
  if (port.available()>0) //if there is an incoming BT value
  {
    data=port.read(); //read the BT incoming value and save in data
    println(key1,key2,data); //print for debugging
    key_select(); //toggle the variable key 1 and key2
  }
  
  video.loadPixels();
  if (calibration==false) //no calibration done
  Calibrate(); //Calibrate Screen
  if (calibration==true && (PaintScreen==false || LEDscreen==false) )
  UI(); //Main Screen
  if (PaintScreen==true && calibration ==true)
  Paintfun(); //Paint Screen
  if (LEDscreen==true && calibration ==true)
  LEDfun(); //LED toffle screen
  
 if (key2==true)
  movePaint=PaintScreen=PaintScreenClear=moveLED=LEDscreen=false; //go back to main screen
 

avgX = avgY = count = 0;

  // Begin loop to walk through every pixel
  for (int x = 0; x < video.width; x++ ) {
    for (int y = 0; y < video.height; y++ ) {
      int loc = x + y * video.width;
      // What is current color
      color currentColor = video.pixels[loc];
      float r1 = red(currentColor);
      float g1 = green(currentColor);
      float b1 = blue(currentColor);
      float r2 = red(trackColor);
      float g2 = green(trackColor);
      float b2 = blue(trackColor);

      float d = distSq(r1, g1, b1, r2, g2, b2); 

      if (d < threshold*threshold) {
        stroke(255);
        strokeWeight(1);
       // point((mirror-x)*mirrorn, y);
        avgX += x;
        avgY += y;
        count++;
      }
    }
  }


  if (count > 0) { 
    avgX = avgX / count;
    avgY = avgY / count;
    // Draw a circle at the tracked pixel
    fill(#21FADB);
    avgX = (mirror-avgX)*mirrorn;
    ellipse(avgX, avgY, 15, 15);

  } 
}
float distSq(float x1, float y1, float z1, float x2, float y2, float z2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) +(z2-z1)*(z2-z1);
  return d;
}



void mousePressed() {
  if(calibration==false)
  {
  int loc = mouseX + mouseY*video.width;
  trackColor = video.pixels[loc]; //load the color to be tracked
   }
}
