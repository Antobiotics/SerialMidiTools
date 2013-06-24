/*
 * Converts serial data to MIDI or SysEx
 */
 
// IMPORTS
import rwmidi.*;
import processing.serial.*;

// GLOBALS
Serial myPort;  // The serial port
MidiInput input;
MidiOutput output;
char[] midiBuffer;
int inc=0;

final int BUFFER_SIZE = 11;

// MIDI Consts
final int  MIDI_HEADER_INDEX   = 0;
final int  MIDI_NOTE_INDEX     = 1;
final int  MIDI_VELOCITY_INDEX = 2;
final char MIDI_ON             = 0x91;
final char MIDI_OFF            = 0x81;
 
// SysEx Consts
final int  SYSEX_HEADER_INDEX  = 0;
final int  SYSEX_COMMAND_INDEX = 4;
final int  SYSEX_FOOTER_INDEX  = 10;
final char HEADER              = 0xF0;
final char FOOTER              = 0xF7;
final char PITCH_BEND_COMMAND  = 0x20;
final char AFTER_TOUCH_COMMAND = 0x21;



void setup( ) 
{
  midiBuffer = new char[BUFFER_SIZE];
  input = RWMidi.getInputDevices()[1].createInput( this );
  println( RWMidi.getInputDevices()[1] );
  output = RWMidi.getOutputDevices()[1].createOutput( );
  println( RWMidi.getOutputDevices()[1] );
  inc = 0;
  myPort = new Serial( this, Serial.list()[4], 115200 ); 
}


void draw( ) 
{
   while ( myPort.available() > 0 ) 
   { 
      int inByte = myPort.read();
      midiBuffer[inc] = (char)inByte;
      inc++;
      
      if( inc > 2 ) // is it a MIDI Message ?
      {
        // We only set inc to zero if a MIDI message is sent.
          if( midiBuffer[MIDI_HEADER_INDEX] == MIDI_OFF ) 
          {
            output.sendNoteOff( 0, midiBuffer[MIDI_NOTE_INDEX], midiBuffer[MIDI_VELOCITY_INDEX] );
            inc = 0;
          } else if( midiBuffer[MIDI_HEADER_INDEX] == MIDI_ON ) 
          {
            output.sendNoteOn( 0, midiBuffer[MIDI_NOTE_INDEX], midiBuffer[MIDI_VELOCITY_INDEX] );
            inc = 0;
          }
      }
      if ( inc > 10 ) // is it a SysEx Message ?
      {
        byte[] message = new byte[BUFFER_SIZE];
        for ( int i = 0; i < BUFFER_SIZE; i = i + 1 ) // byte casting loop, TODO: Change that, there is certainly a better way...
        {
          message[i] = (byte) midiBuffer[i];
          print ( midiBuffer[i] );
          print ( " - " );
          print ( message[i] );
          print ( " | " );
        }
        println( );

        if ( midiBuffer[SYSEX_HEADER_INDEX] == HEADER )
        {
          if ( midiBuffer[SYSEX_FOOTER_INDEX] != FOOTER )
          {
            println( "Bad SysEx FOOTER" );
          } else 
          {
           if ( midiBuffer[SYSEX_COMMAND_INDEX] == PITCH_BEND_COMMAND  
             || midiBuffer[SYSEX_COMMAND_INDEX] == AFTER_TOUCH_COMMAND ) // if it's a pitchbend or an aftertouch
           {
             println( " sysex " + message);
             output.sendSysex( message );  
           } else 
           {
             println( "I don't know that command, dude" );
           }
          }
        }
        // What ever happens if inc is greater than 10,
        // we reset it.
        inc = 0;
      }
  }
}
// EVENTS
void noteOnReceived(Note note) 
{
 // println("note on " + note.getPitch());
}

void sysexReceived(rwmidi.SysexMessage msg) 
{
  println("sysex " + msg);
}

void mousePressed() // Test SysEx output.
{
  int ret = output.sendSysex(new byte[] {(byte)HEADER, 1, 2, 3, 4, (byte)FOOTER});
}

