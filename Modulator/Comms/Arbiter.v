/*
Code was designed and tested 
by Reevelen Dass for EEE5118Z Practical and Modified for this Project
*/

import Structures::*; 

module Arbiter(
	input              	        ipClk,
    input                       ipReset, 

    input   UART_PACKET         ipTxStream1,
    output  reg                 opTxReady1,

    input   UART_PACKET         ipTxStream2, 
    output  reg                 opTxReady2, 
 
    output  UART_PACKET         opTxStream, 
    input   reg                 ipTxReady//, 
//   output              [7:0]   opBusy1 //Output Used for Debugging
); 

reg Transmit1;
reg Busy1; 
reg Busy2;  

reg hasBuffer1;
reg hasBuffer2;

reg sendBuffer;

UART_PACKET TxStreamBuffer;

reg sendPacket;

// assign opBusy1 = {Busy1,hasBuffer1,opTxReady1,  2'b0, opTxReady2, hasBuffer2, Busy2}; // Used for Debugging

always @(posedge(ipClk)) begin
    if (!ipReset) begin
        if (!sendBuffer) begin // Normal Behaviour
            if (Busy1) begin // First Packet is Sending
                if (ipTxStream2.Valid && ipTxStream2.SoP) begin  // A buffer was received on the other input (likely from first packet)
                    TxStreamBuffer <= ipTxStream2;
                    hasBuffer2 <= 1;
                end

                if (sendPacket) begin
                    opTxStream.Valid <=0;
                    if(!ipTxReady) begin
                        sendPacket <= 0; 
                        if (opTxStream.EoP) begin // The last packet was sent
                            Transmit1 <= 0;
                            Busy1 <= 0;
                            if (hasBuffer2) sendBuffer <= 1;
                        end
                    end
                end else if (opTxReady1 && ipTxStream1.Valid && !ipTxStream1.SoP) begin
                    opTxStream <= ipTxStream1;
                    opTxReady1 <= 0;
                    sendPacket <= 1;
                end else  
                    opTxReady1 <= ipTxReady;
            end else if(Busy2) begin //Second Packet is sending
                if (ipTxStream1.Valid && ipTxStream1.SoP) begin  // A buffer was received on the other input (likely from first packet)
                    TxStreamBuffer <= ipTxStream1;
                    hasBuffer1 <= 1;
                end

                if (sendPacket) begin
                    opTxStream.Valid <=0;
                    if(!ipTxReady) begin
                        sendPacket <= 0;
                        if (opTxStream.EoP) begin // The last packet was sent
                            Transmit1 <= 1;
                            Busy2 <= 0;
                            if (hasBuffer1) sendBuffer <= 1;
                        end
                    end
                end else if (opTxReady2 && ipTxStream2.Valid && !ipTxStream2.SoP) begin
                    opTxStream <= ipTxStream2;
                    opTxReady2 <= 0;
                    sendPacket <= 2;
                end else  
                    opTxReady2 <= ipTxReady;
            end else begin // Not Busy in Either Block 
                if (ipTxStream1.Valid && ipTxStream1.SoP) begin //Start Sending Block 1
                    Busy1 <= 1;
                    opTxStream <= ipTxStream1;
                    sendPacket <= 1;
                    opTxReady1 <= 0;
                    opTxReady2 <= 0;
                end else if (ipTxStream2.Valid && ipTxStream2.SoP) begin //Start Sending Block 2
                    Busy2 <= 1;
                    opTxStream <= ipTxStream2;
                    sendPacket <= 1;
                    opTxReady1 <= 0;
                    opTxReady2 <= 0;
                end else begin // Toggle the IpReady
                    opTxStream.Valid<=0;
                    if (ipTxReady) begin
                        Transmit1 <= ~Transmit1;
                        if(Transmit1) begin 
                            opTxReady1 <= 1;
                            opTxReady2 <= 0;
                        end else begin
                            opTxReady1 <= 0;
                            opTxReady2 <= 1;
                        end
                    end else begin
                        opTxReady1 <= 0;
                        opTxReady2 <= 0;
                    end
                end
            end
        end else begin //SendBuffer 
            opTxReady1 <= 0;
            opTxReady2 <= 0;
            if (hasBuffer1) begin
                if (ipTxReady) begin
                    opTxStream <= TxStreamBuffer;
                    hasBuffer1 <= 0;
                    sendBuffer <= 0;
                    sendPacket <= 1;
                    Busy1 <= 1;
                end
            end else if (hasBuffer2) begin
                if (ipTxReady) begin
                    opTxStream <= TxStreamBuffer;
                    hasBuffer2 <= 0;
                    sendBuffer <= 0;
                    sendPacket <= 1;
                    Busy2<=1;
                end
            end
        end
    end else begin
        opTxReady1 <= 0;
        opTxReady2 <= 0;
        Busy1 <= 0;
        Busy2 <= 0;
        sendBuffer <= 0;
        opTxStream.Valid <= 0;
        hasBuffer1<=0;
        hasBuffer2<=0;
        sendPacket <= 0;
    end
end


endmodule