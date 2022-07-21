
/*
File was obtained from Practical.
Slight changes were made 
by Reevelen Dass for this project
*/



/*------------------------------------------------------------------------------

Defines the registers, and implements a memory-mapped register interface.
------------------------------------------------------------------------------*/

import Structures::*;
//------------------------------------------------------------------------------

module Registers(
  input               ipClk,
  input               ipReset,

  input  RD_REGISTERS ipRdRegisters,
  output WR_REGISTERS opWrRegisters,

  input         [ 7:0]ipAddress,
  input         [31:0]ipWrData,
  input               ipWrEnable,
  output reg    [31:0]opRdData
);
//------------------------------------------------------------------------------

reg Reset;

always @(posedge ipClk) begin
  case(ipAddress)
    8'h00  : opRdData <= ipRdRegisters.ClockTicks;
    8'h01  : opRdData <= ipRdRegisters.Buttons;
    8'h02  : opRdData <= opWrRegisters.LEDs;
	  8'h03  : opRdData <= ipRdRegisters.FIFO_Size;
    8'h04  : opRdData <= opWrRegisters.Frequency;
    8'h05  : opRdData <= opWrRegisters.SlowMode;
    default: opRdData <= 32'hX;
  endcase
  //----------------------------------------------------------------------------

  Reset <= ipReset;

  if(Reset) begin
    opWrRegisters.LEDs <= 0;
    opWrRegisters.Frequency <= 32'hFFFFF000;;
    opWrRegisters.SlowMode <= 0;
  //----------------------------------------------------------------------------

  end else if(ipWrEnable) begin
    case(ipAddress)
      8'h02: opWrRegisters.LEDs <= ipWrData;
      8'h04: opWrRegisters.Frequency <= ipWrData;
      8'h05: opWrRegisters.SlowMode <= ipWrData;
      default:;
    endcase
  end
end
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------