
/*
File was obtained from practical.
Slight changes were made by Reevelen Dass for this project
*/

package Structures;


//------------------------------------------------------------------------------

typedef struct{
  logic [31:0]ClockTicks;
  logic [ 3:0]Buttons;
  logic [ 12:0]FIFO_Size;
} RD_REGISTERS;
  
typedef struct{   
  logic [7:0]LEDs;
  logic [31:0]Frequency;
} WR_REGISTERS;

typedef struct{ 
  logic [7:0]Source;
  logic [7:0]Destination;
  logic [7:0]Length;

  logic      SoP; 
  logic      EoP;
  logic [7:0]Data; 
  logic      Valid;
} UART_PACKET;
//------------------------------------------------------------------------------

endpackage
//------------------------------------------------------------------------------

