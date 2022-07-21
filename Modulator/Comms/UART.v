/*
File template was obtained from practical.
Code was designed and tested by Reevelen Dass.
*/


/*------------------------------------------------------------------------------

Implements a 115 200 Bd UART.  ipClk is assumed to be 50 MHz

To send data:

- Set up ipTxData
- Wait for opTxBusy to be low
- Make ipTxSend high
- Wait for opTxBusy to go high
- Make ipTxSend low

To receive data:

- Wait for opRxValid to be high
- opRxData is valid during the same clock cycle
------------------------------------------------------------------------------*/

module UART(
  input           ipClk,
  input           ipReset,

  input      [7:0]ipTxData,
  input           ipTxSend,
  output reg      opTxBusy,
  output reg      opTx,

  input           ipRx,
  output reg [7:0]opRxData,
  output reg      opRxValid
);
//------------------------------------------------------------------------------

typedef enum{ // SystemVerilog only
Wait,
Process
} tState;
tState txState;
tState rxState;

reg[9:0] txClkCount = 0; 
reg[9:0] rxClkCount = 0; 

reg[7:0] txData = 0;
reg[7:0] rxData = 0;
reg[3:0] BitsSent = 0; 
reg[3:0] BitsReceived = 0; 

wire txClkBaud = (txClkCount == 16); //Divide the Clock to 115200
wire rxClkBaud = (rxClkCount == 16); //Divide the Clock to 115200
 
reg Rx;

// TODO: Put the transmitter here
always @(posedge(ipClk)) begin
	if(txClkBaud) begin
		txClkCount <= 9'd1;
	end
	else begin 
		txClkCount <= txClkCount + 1'b1;
	end
	
	if (!ipReset) begin
		if (txClkBaud) begin //Main Code Here
			case(txState)
				Wait: begin 
					if (~ipTxSend) begin
						opTxBusy <= 0;  
						opTx <= 1; //Idle High 
					end else begin
						txData <= ipTxData;
						opTxBusy <= 1;  
						opTx <= 0; 
						txState <= Process;
					end
				end
				Process: begin
					if (BitsSent != 8) begin
						txData <= txData >> 1;
						opTx <= txData;
						BitsSent <= BitsSent + 1;
					end else begin 
						opTx <= 1;
						BitsSent <= 0;
						txState <= Wait;
					end
				end
				default:;
			endcase
		end	
	end else begin //Reset Code Here
		opTxBusy <= 0; 
		opTx <= 1;
		txClkCount <= 10'b0; 
		BitsSent <= 3'b0; 
		txState <= Wait;
		txData <= 8'b0;
	end
end
//------------------------------------------------------------------------------

// TODO: Put the receiver here
always @(posedge(ipClk)) begin
	Rx <= ipRx;
	if (!ipReset) begin
		if (rxState == Wait && Rx) begin
			rxClkCount <= 7; //Sync data to halfway
		end else if(rxClkBaud) begin
			rxClkCount <= 9'd1;
		end else begin 
			rxClkCount <= rxClkCount + 1'b1;
		end
		if (rxClkBaud) begin
			case (rxState)
				Wait: begin
					if (Rx) begin
						opRxValid <= 0;
					end else begin
						opRxValid <=0;
						rxState <= Process;
					end
				end 
				Process: begin
					if (BitsReceived != 8) begin
						rxData <= {Rx, rxData[7:1]};
						BitsReceived <= BitsReceived + 1;
					end else begin
						if (Rx == 1) begin
							opRxData <= rxData;
							rxData <= 0;
							opRxValid <= 1;
							BitsReceived <= 0; 
							rxState <= Wait;
						end
					end				
				end
				default:;
			endcase
		end else begin
			opRxValid <= 0;
		end
	end else begin //Reset Code Here
		opRxValid <= 0; 
		BitsReceived <= 3'b0; 
		rxState <= Wait;
		rxData <= 8'b0;
		Rx <= 0;
	end
end
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------