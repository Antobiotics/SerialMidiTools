import rwmidi.*;
import processing.serial.*;
Serial myPort;  // The serial port
MidiInput input;
MidiOutput output;
char[] midiBuffer;
int inc=0;
void setup() {
  midiBuffer = new char[3];
  input = RWMidi.getInputDevices()[1].createInput(this);
  println(RWMidi.getInputDevices()[1]);
  output = RWMidi.getOutputDevices()[1].createOutput();
  println(RWMidi.getOutputDevices()[1]);
  inc=0;
    // List all the available serial ports
  //println(Serial.list());
  // Open the port you are using at the rate you want:
  myPort = new Serial(this, Serial.list()[4], 115200); 
}
void noteOnReceived(Note note) {
  println("note on " + note.getPitch());
}

void sysexReceived(rwmidi.SysexMessage msg) {
  println("sysex " + msg);
}

void mousePressed() {
  int ret =    output.sendNoteOn(0, 3, 3);
  ret = output.sendSysex(new byte[] {(byte)0xF0, 1, 2, 3, 4, (byte)0xF7});
}

void draw() {
   while (myPort.available() > 0) {
    
    int inByte = myPort.read();
    println(inc);
    println(inByte);
    midiBuffer[inc]=(char)inByte;
    inc++;
    
    if(inc>2)
    {
        inc=0;
        println("MidiIn");
        if(midiBuffer[0]==0x81)
         output.sendNoteOff(0, midiBuffer[1], midiBuffer[2]);
         else if(midiBuffer[0]==0x91)
         output.sendNoteOn(0, midiBuffer[1], midiBuffer[2]);
    }
  }
}

