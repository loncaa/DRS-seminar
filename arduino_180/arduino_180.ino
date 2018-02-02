#include <Servo.h>

const int servoPinX = 2; // pin jednog motora 2
const int servoPinY = 4; // pin drugog motora 4
Servo myServoX; //motor na pinu 2
Servo myServoY; //motor na pinu 4

int x = 90;
int y = 90;

void setup() {
  Serial.begin(9600);
  myServoX.attach(servoPinX);
  myServoY.attach(servoPinY);
}

void loop() {
  if(Serial.available()  > 0) 
  {  
    x = Serial.parseInt();
    y = Serial.parseInt();
    if(x && y)
    {
      myServoX.write(x);
      myServoY.write(y);
    } 
  }
}
