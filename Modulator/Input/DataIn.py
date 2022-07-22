""""
This file is modified from the Memorandum of practical 6 in the FPGA course available at
https://github.com/jpt13653903/UCT-FPGA-Course-2022

Original Author is John-Phillip Taylor

Modifications were made to suit the QAM Modulator.
"""
import numpy as np
import audioread
import serial
import struct
#-------------------------------------------------------------------------------

AudioFile = 'Cantina.wav'
#-------------------------------------------------------------------------------

Frequency = 0xFFFFF000
SlowModeEnabled = True

ClockTicks = 0x00
Buttons    = 0x01
LEDs       = 0x02
FIFO_Space = 0x03
FrequencyIndicator = 0x04
SlowMode = 0x05


Space = 0
Counter = 0;
#-------------------------------------------------------------------------------

def Write(UART, Address, Data):
    UART.write(struct.pack('<BBBBBI', 0x55, 0x01, 0xAA, 0x05, Address, Data))
#-------------------------------------------------------------------------------

def Read(UART, Address):
    while (True):
        UART.write(struct.pack('<BBBBB', 0x55, 0x00, 0xAA, 0x01, Address))

        while (UART.read(1) != b'\x55'): pass

        Header = UART.read(3)
        Data = UART.read(Header[2])

        global Space

        match Header[1]:  # Source
            case 0x00:  # Read response
                Data = struct.unpack_from('<I',Data[1:])[0]
                Space = 8192-2*Data

                return True
            case 0x10:  # Audio stream flow control
                print("Tx Packet Received")


#-------------------------------------------------------------------------------

def Stream(UART, Buffer):
    Size = len(Buffer)
    Sent = 0
    Read(UART, FIFO_Space)
    global Space
    print("Space available: ", end = "")
    print(Space)

    Write(UART, LEDs, 256-(Space >> 5))
    while(Space < Size): Read(UART, FIFO_Space)

    while(Size > 0):
        if(Size >= 250):
            UART.write(struct.pack('<BBBB256B', 0x55, 0x10, 0xAA, 0x00, 0xFF, 0x00,0xFF,0x00 ,0xFF,0x00 ,*Buffer[Sent:(Sent+250)]))
            Size -= 250
            Sent += 250
        else:
            UART.write(struct.pack(f'<BBBB{Size+6}B', 0x55, 0x10, 0xAA, Size, 0xFF, 0x00,0xFF,0x00 ,0xFF,0x00, *Buffer[Sent:(Sent+Size)]))
            Size  = 0
            Sent += Size
#-------------------------------------------------------------------------------

with serial.Serial(port='COM11', baudrate=3000000) as UART:
    Write(UART, FrequencyIndicator, Frequency)

if (SlowModeEnabled):
    with serial.Serial(port='COM11', baudrate=3000000) as UART:
        Write(UART, 0x05, 1)

with audioread.audio_open(AudioFile) as Audio:
    print(Audio.channels, Audio.samplerate, Audio.duration)
    with serial.Serial(port='COM11', baudrate=3000000) as UART:
        for Buffer in Audio: Stream(UART, Buffer)

        Write(UART, LEDs, 0)


#-------------------------------------------------------------------------------

