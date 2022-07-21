/*
Code was designed and tested 
by Reevelen Dass for EEE5118Z Practical and Modified for this Project
*/

 
import Structures::*;  

module Streamer(
    input              			ipClk,
    input              			ipReset,

    input   UART_PACKET     	ipRxStream,
    output  reg         [12:0]  opFIFO_Size, 

    output  reg         [15:0]  opStream,    
    output  reg         		opStreamValid,

    output  reg         [3:0]   opQAMBlock,     
    output  reg         	    opQAMBlockValid,

    output UART_PACKET          opTxStream,
	input						ipTxReady
);   

reg WE;  
reg RE;
 
wire Empty;
wire Full;

wire [12:0] FIFO_Size1;

reg [15:0] ipData;

reg [31:0] txClkCount; //Very large incase output must be very slow 

FIFO FIFOBLOCK(
    .Clock(ipClk),
    .Reset(ipReset),

    .WrEn(WE),
    .RdEn(RE),

    .Data(ipData),
    .Q(opStream), 

    .Empty(Empty),
    .Full(Full),

    .WCNT(FIFO_Size1)
);  

typedef enum{ 
ReceiveWait,
ReceiveData
} RState;

RState rState;

typedef enum{ 
CheckSize,
TransmitPacket,
TransmitComplete
} TState;

TState tState;

reg wUpper;
reg rUpper;

assign opFIFO_Size = FIFO_Size1;
 
always @(posedge(ipClk)) begin
    if (!ipReset) begin
        if ((txClkCount ==  5660) && !Empty) begin
            opQAMBlock <= opStream[3:0];
            opQAMBlockValid <= 1;
            txClkCount <= txClkCount + 1'b1;
        end else if ((txClkCount == 11330) && !Empty) begin    
            opQAMBlock <= opStream[7:4];
            opQAMBlockValid <= 1;
            txClkCount <= txClkCount + 1'b1;
        end if ((txClkCount == 16990) && !Empty) begin
            opQAMBlock <= opStream[11:8];
            opQAMBlockValid <= 1;
            txClkCount <= txClkCount + 1'b1;
        end else if (txClkCount == 22670) begin
            if (!Empty) begin
                opQAMBlock <= opStream[15:12];
                opQAMBlockValid <= 1; 
                RE <= 1;
                opStreamValid <= 1;
            end
            txClkCount <= 0;
        end else begin
            txClkCount <= txClkCount + 1'b1;
            RE <= 0;
            opStreamValid <= 0;
            opQAMBlockValid <= 0;
        end

    end else begin
        RE <= 0;
        opStreamValid <= 0;
        txClkCount <= 0;
        opQAMBlock <= 0;
		opQAMBlockValid <= 0;
    end
end

always @(posedge(ipClk)) begin
    if (!ipReset) begin
        case (rState)
            ReceiveWait: begin
                WE <= 0;
                if (ipRxStream.Valid && ipRxStream.SoP) begin
                    if (ipRxStream.Destination == 8'h10) begin
                        ipData[7:0] <= ipRxStream.Data;
                        wUpper <= 1;
                        rState <= ReceiveData;
                    end 
                end  
            end
            ReceiveData: begin
                if (ipRxStream.Valid) begin
                    if (wUpper) begin  //lower byte then upper byte
                        ipData[15:8] <= ipRxStream.Data;
                        WE <= 1;
                        wUpper <= 0;
                    end else begin
                        ipData[7:0] <= ipRxStream.Data;
                        WE <= 0;
                        wUpper <= 1;
                    end
                    if (ipRxStream.EoP) begin
                        rState <= ReceiveWait;
                    end
                end else
					WE <= 0;
            end
            default:;
        endcase
    end else begin
        rState <= ReceiveWait;
        wUpper <= 0;
        WE <= 0;
    end
end

always @(posedge(ipClk)) begin
    if(!ipReset) begin
            opTxStream.SoP    <= 1;
            opTxStream.EoP    <= 1;
            opTxStream.Length <= 1;
            opTxStream.Source <= 8'h10;
            opTxStream.Destination <= 8'hAA;
            opTxStream.Data <= 8'h00; //Empty Indicator Packet

        case (tState) 
            CheckSize: begin
                opTxStream.Valid <= 0;
                if (Empty && (txClkCount == 10)) begin 
                   tState<= TransmitPacket;
                end
            end 
            TransmitPacket: begin
                if (ipTxReady) begin
                    opTxStream.Valid <= 1;
                    tState<= CheckSize;
                end
            end
            default:;
        endcase
    end else begin
        opTxStream.SoP    <= 0;
        opTxStream.EoP    <= 0;
        opTxStream.Length <= 0;
        opTxStream.Source <= 8'h10;
        opTxStream.Destination <= 8'hAA;
        opTxStream.Data <= 0;

        opTxStream.Valid <= 0;
        
    end
end


endmodule