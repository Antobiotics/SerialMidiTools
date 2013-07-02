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
byte[] sysExBuffer;
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



void 
setup( ) 
{
  midiBuffer  = new char[BUFFER_SIZE];
  sysExBuffer = new byte[BUFFER_SIZE]; 
  input = RWMidi.getInputDevices()[1].createInput( this );
  println( RWMidi.getInputDevices()[1] );
  output = RWMidi.getOutputDevices()[1].createOutput( );
  println( RWMidi.getOutputDevices()[1] );
  inc = 0;
  myPort = new Serial( this, Serial.list()[4], 115200 ); 
}


void 
draw( ) 
{
   while ( myPort.available() > 0 ) 
   { 
      println( "-------" );
      int inByte = myPort.read();

      midiBuffer[inc]  = (char) inByte;     
      sysExBuffer[inc] = (byte) inByte;//inByte; 
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
      if ( inc == 11 ) // is it a SysEx Message ?
      {        
        for ( int i = 0; i < inc; i = i + 1 )
        {
           print( hex( sysExBuffer[i] )+ " |" ); 
        }
        println();
        if ( sysExBuffer[SYSEX_HEADER_INDEX] == (byte) HEADER )
        {
          if ( sysExBuffer[SYSEX_FOOTER_INDEX] != (byte) FOOTER )
          {
            print( "Bad SysEx FOOTER" );
            println( hex( (byte) sysExBuffer[SYSEX_FOOTER_INDEX] ) );

          } else 
          {
           if ( sysExBuffer[SYSEX_COMMAND_INDEX] == (byte) PITCH_BEND_COMMAND  
             || sysExBuffer[SYSEX_COMMAND_INDEX] == (byte) AFTER_TOUCH_COMMAND ) // if it's a pitchbend or an aftertouch
           {
             print( "sending sysex...Result: " );
             int result = output.sendSysex( sysExBuffer );  
             println( result );
           } else 
           {
             println( "I don't know that command:  " );
             println( hex( (byte) sysExBuffer[SYSEX_COMMAND_INDEX] ) );

           }
          }
        } else 
        {
         print( "Bad HEADER !" ); 
         println( hex( (byte) sysExBuffer[SYSEX_HEADER_INDEX] ) );
        }
        // What ever happens if inc is greater than 10,
        // we reset it.
        inc = 0;
      }
  }
}

// EVENTS
void 
noteOnReceived(Note note) 
{
 // println("note on " + note.getPitch());
}

void 
sysexReceived(rwmidi.SysexMessage msg) 
{
  println("sysex " + msg);
}

void
mousePressed() // Test SysEx output.
{
  int ret = output.sendSysex(new byte[] {(byte)HEADER, 1, 2, 3, 4, (byte)FOOTER});
}

