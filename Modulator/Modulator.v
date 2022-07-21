/*
Code was designed and tested 
by Reevelen Dass for EEE5118Z Practical and Modified for this Project
*/

import Structures::*;

module Modulator(
	input			    ipClk,
	input			    ipReset,
	input			    ipUART_Rx,
	input	  [3:0]	ipBtn,
	output			  opUART_Tx, 
	output	[7:0]	opLED,  
  output        opPWM, 
  output        opPWMI,
  output        opPWMQ,
  output      opPWMModulated
);

UART_PACKET RxStream;
UART_PACKET TxStream;
wire TxReady;

UART_PACKET RxStream1;
UART_PACKET TxStream1;
wire TxReady1;

UART_PACKET RxStream2;
UART_PACKET TxStream2;
wire TxReady2;

RD_REGISTERS RdRegisters; 
WR_REGISTERS WrRegisters; 
 

wire [7:0] 	  Address;
wire [31:0] 	WrData;
wire 			    WrEnable;
wire [31:0]	  RdData;

wire [15:0]	  Stream;
wire			    StreamValid;

wire [3:0]	  QAMBlock;
wire			    QAMBlockValid;

wire [19:0]   Modulated;
wire          ModulatedValid;

wire [17:0]	I;
wire [17:0]	Q;
wire Valid;

//Communication
UART_Packets Packetiser(
  .ipClk(ipClk),
  .ipReset(!ipReset),

  .ipTxStream(TxStream),
  .opTxReady(TxReady),
  .opTx(opUART_Tx),

  .ipRx(ipUART_Rx),
  .opRxStream(RxStream)
);

Controller Control(
  .ipClk	(ipClk),
  .ipReset	(!ipReset),
  
  .opTxStream(TxStream1),
  .ipTxReady(TxReady1),

	.opAddress(Address),
  .opWrData(WrData),
	.opWrEnable(WrEnable),
	
	.ipRxStream(RxStream),
  .ipRdData(RdData)
);

Registers Register(
  .ipClk(ipClk),
  .ipReset(!ipReset),

  .ipRdRegisters(RdRegisters),
  .opWrRegisters(WrRegisters),

  .ipAddress(Address),
  .ipWrData(WrData),
  .ipWrEnable(WrEnable),
  .opRdData(RdData)
);

Arbiter Arbiter1(
  .ipClk(ipClk), 
  .ipReset(!ipReset),
  .ipTxStream1(TxStream1),
  .opTxReady1(TxReady1),
  .ipTxStream2(TxStream2),
  .opTxReady2(TxReady2),
  .ipTxReady(TxReady),
  .opTxStream(TxStream)
);
 
// Data Flow
Streamer Streamer1(
  .ipClk	(ipClk),
  .ipReset	(!ipReset),

  .ipRxStream(RxStream),
  .opFIFO_Size(RdRegisters.FIFO_Size), 

  .ipSlowMode(WrRegisters.SlowMode),

  .opStream(Stream),     
  .opStreamValid(StreamValid),

  .opQAMBlock(QAMBlock),    
  .opQAMBlockValid(QAMBlockValid),

  .opTxStream(TxStream2),
  .ipTxReady(1'b0)
);


//Signal Processing
NCO NCO1(
  .ipClk(ipClk), 
  .ipReset(!ipReset),
  .ipFrequency (WrRegisters.Frequency),

  .opI(I),
  .opQ(Q)
);

QAM QAM1(
  .ipClk(ipClk), 
  .ipReset(!ipReset),

  .ipQAMBlock(QAMBlock),
  .ipQAMBlockValid(QAMBlockValid),

  .ipI(I),
  .ipQ(Q),

  .opModulatedValid(ModulatedValid),
  .opModulated(Modulated)
);

PWM PWMStream(
  .ipClk(ipClk), 
  .ipReset(!ipReset),
  .ipDutyCycle ({~Stream[15], Stream[14:8]}),
  .opPWM(opPWM)
);

PWM PWMI(
  .ipClk(ipClk), 
  .ipReset(!ipReset),
  .ipDutyCycle ({~I[17], I[16:10]}),
  .opPWM(opPWMI)
);

PWM PWMQ(
  .ipClk(ipClk), 
  .ipReset(!ipReset),
  .ipDutyCycle ({~Q[17], Q[16:10]}),
  .opPWM(opPWMQ)
);

PWM PWMModulated(
  .ipClk(ipClk), 
  .ipReset(!ipReset),
  .ipDutyCycle ({~Modulated[19], Modulated[18:12]}),
  .opPWM(opPWMModulated)
);


//Clock Counter
always @(posedge ipClk) begin
	if (ipReset) begin //reset inverted - normal functionality here
		RdRegisters.ClockTicks <= RdRegisters.ClockTicks + 1'b1;
	end else begin //reset inverted - reset code here
		RdRegisters.ClockTicks <= 0;
	end
end

assign opLED = ~WrRegisters.LEDs;
assign RdRegisters.Buttons = ~ipBtn;


endmodule 