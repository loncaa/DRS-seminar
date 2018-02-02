import gab.opencv.*;
import processing.serial.*;
import processing.video.*;
import java.awt.Rectangle;

Serial arduinoPort;
OpenCV opencv;
Capture cam;

int baud = 9600;
int[] send = new int[2];

int servoPositionX;
int servoPositionY;
boolean mouseClick = true;

int lowerb = 0, upperb = 20;
ArrayList<Contour> contours;

void setup() {
  size(640, 480); //180 od sredine u lijevo/desno, gore/dolje
  background(255, 255, 0);
  
  opencv = new OpenCV(this, 640, 480);
  cam = new Capture(this, 640, 480);

  contours = new ArrayList<Contour>();
  String portName = Serial.list()[0];
  arduinoPort = new Serial(this, portName, baud);
  
  send[0] = 90;
  send[1] = 90;
  
  //kada se pošalje umjesto : razmak ' ', treba mu dugo da obradi poruku
  //: je proizvoljno odabrano
  //umjesto : moze biti bilo koji znak ili slovo, ne broj!
  arduinoPort.write(send[0] + ":" + send[1] + ":");
  cam.start();
}

/*umjesto mouseX i mouseY staviti koordinate bloba*/
void draw() {
  background(255, 255, 0);
  
  fill(255, 255, 255);
  strokeWeight(1);
  rect(width/2 - 25, height/2 - 25, 50, 50);
  
  /*dohvačanje slike*/
  opencv.loadImage(cam);
  
  /*obrada slike*/
  
  /*potrebno je pronaci bolji nacin za pracenje objekta*/
  opencv.useColor(HSB);
  opencv.setGray(opencv.getH().clone());
  
  /*smanjivanje šuma*/
  //opencv.brightness(brightness);
  //opencv.contrast(contrast);
  //opencv.dilate();
  //opencv.erode();
  //opencv.blur(3);
  
  opencv.inRange(lowerb, upperb);
  image(opencv.getOutput(), 3*width/4, 3*height/4, width/4, height/4);
    
  /*ptonađi najvecu konturu*/
  contours = opencv.findContours(true, true);
  if (contours.size() > 0) {
    Contour biggestContour = contours.get(0);
    Rectangle r = biggestContour.getBoundingBox();
   
    /*uodejtaj koordinate docke objekta*/
    servoPositionX = Math.abs(r.x + r.width/2 - width); //inverzne koordinate x osi
    servoPositionY = Math.abs(r.y + r.height/2);
  }
  
  //ako se nalazi unutar kvadrata ili nije pritisnuta tipka miša
  //ne pomići servo motore  
  if(isInside(servoPositionX, servoPositionY) || mouseClick){
    send[0] = 90;
    send[1] = 90;
    arduinoPort.write(send[0] + ":" + send[1] + ":");
    delay(5);
  }else{
    /*servoPositionX 0-640 -> 0-180
      servoPositionY 0-480 -> 0-180*/
    send[0] = (180 - servoPositionX*180/640);
    send[1] = (servoPositionY*180/480);
    
    arduinoPort.write(send[0] + ":" + send[1] + ":");
    delay(5);
  }
  
  fill(255, 255, 255);
  strokeWeight(1);
  ellipse(640 - send[0]*640/180, send[1]*480/180, 10, 10); 
  
}

/**
funkcija koja provjerava da li se koordinate nalaze unutar kvadrata 50x50

@param coordx Xkoordinate za koje trazmo da li se nalaze unutar kvadrata
@param coordy Ykoordinate za koje trazimo da li se nalaze unutar kvadrata
@return true ako se koordinate nalaze unutar kvadrata, odnosno false ako se ne nalaze
*/

boolean isInside(int coordx, int coordy)
{
  if((coordx > width/2 - 25 && coordx < width/2 + 25) && (coordy > height/2 - 25 && coordy < height/2 + 25))
  {   
    return true;
  }
  else return false;
}

/**
funkcija koja mjenja stanje nakon sto se stisne klik miša
*/
void mouseClicked()
{
  mouseClick = !mouseClick;
}

/**
podešavanje inRange funkcije pomocu slova QWAS
*/
void keyPressed() {
  if(char(keyCode) == 'Q')
    lowerb += 2;
  else if(char(keyCode) == 'W')
    lowerb -= 2;
    
 if(char(keyCode) == 'A')
    upperb += 2;
  else if(char(keyCode) == 'S')
    upperb -= 2;
    
    println(lowerb + " " + upperb);
}

void captureEvent(Capture c) {
  c.read();
}
