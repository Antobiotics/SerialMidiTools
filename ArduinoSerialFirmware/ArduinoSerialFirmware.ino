#include <Wire.h>
#include <serial.h>
int led = 13;

void setup()
{
  pinMode(led, OUTPUT);
  Wire.begin(2);
  Wire.onReceive(receiveEvent);
  Serial.begin(115200);
}

void loop()
{
    digitalWrite(led, LOW);
}


void receiveEvent(int howMany)
{
  unsigned char dataReceived;

  digitalWrite(led, HIGH);

  while(Wire.available() > 0)
  {
    dataReceived = Wire.read();
    Serial.write(dataReceived);
    //Serial.println(dataReceived,HEX);
    //println("%c",dataReceived);
  }
}


