import Structures::*;
//------------------------------------------------------------------------------

module UART_Packets(
  input              ipClk,
  input              ipReset,

  input  UART_PACKET ipTxStream,
  output reg         opTxReady,
  output             opTx,

  input              ipRx,
  output UART_PACKET opRxStream
);
//------------------------------------------------------------------------------

reg[7:0] UART_TxData;
reg UART_TxSend;
reg UART_TxBusy;

reg[7:0] UART_RxData;  
reg UART_RxValid; 

// TODO: Instantiate the UART module here
UART UART_Inst(
  .ipClk    ( ipClk   ),
  .ipReset  (ipReset),

  .ipTxData (  UART_TxData),
  .ipTxSend (  UART_TxSend),
  .opTxBusy (  UART_TxBusy),
  .opTx     (opTx    ),

  .ipRx     (ipRx     ),
  .opRxData (  UART_RxData ),
  .opRxValid(  UART_RxValid)
);

typedef enum{ 
ReceiveSync,
ReceiveDestination,
ReceiveSource,
ReceiveLength,
ReceivePayload
} rState;
rState rxState;

typedef enum{ 
TransmitWait,
TransmitSync,
TransmitDestination,
TransmitSource,
TransmitLength,
TransmitPayload
} tState;
tState txState;

UART_PACKET txBuffer;

reg[7:0] BytesReceived;
//------------------------------------------------------------------------------

// TODO: Implement the Tx stream
// Transition Logic Broken
always @(posedge(ipClk)) begin
         if (!ipReset) begin
        case(txState) 
            TransmitWait: begin
                if (!UART_TxBusy && !ipTxStream.Valid) begin
                    opTxReady <= 1;
                end else begin
                    opTxReady <= 0;
					if (ipTxStream.Valid) begin
						txBuffer <= ipTxStream;
						txState <= TransmitSync; 
						end
                end 
            end
            TransmitSync: begin
                if (!UART_TxBusy && !UART_TxSend) begin
                    UART_TxData <= 8'h55;
                    UART_TxSend <= 1;
                end else if (UART_TxBusy && UART_TxSend) begin
                    UART_TxSend <= 0;                   
                    txState <= TransmitDestination;
                end
            end
            TransmitDestination: begin
                if (!UART_TxBusy && !UART_TxSend) begin
                    UART_TxData <= txBuffer.Destination;
                    UART_TxSend <= 1;
                end else if (UART_TxBusy && UART_TxSend) begin
                    UART_TxSend <= 0;
                    txState <= TransmitSource;
                end
            end
            TransmitSource: begin
                if (!UART_TxBusy && !UART_TxSend) begin
                    UART_TxData <= txBuffer.Source;
                    UART_TxSend <= 1;
                end else if (UART_TxBusy && UART_TxSend) begin
                    UART_TxSend <= 0;
                    txState <= TransmitLength;
                end
            end
            TransmitLength: begin
                if (!UART_TxBusy && !UART_TxSend) begin
                    UART_TxData <= txBuffer.Length;
                    UART_TxSend <= 1;
                end else if (UART_TxBusy && UART_TxSend) begin
                    UART_TxSend <= 0;
                    txState <= TransmitPayload;
                end
            end
            TransmitPayload: begin	
				if (!UART_TxBusy && !UART_TxSend) begin
					if (txBuffer.Valid) begin
						UART_TxData <= txBuffer.Data;
						UART_TxSend <= 1;
						opTxReady   <= 1; 
					end
				end	else begin
					if (UART_TxBusy && UART_TxSend) begin
						UART_TxSend <= 0;
						if (txBuffer.EoP && opTxReady) begin
							opTxReady <= 0;
							txState <= TransmitWait;
						end
					end
					if (ipTxStream.Valid && opTxReady) begin
						txBuffer <= ipTxStream;	
						opTxReady <= 0;
					end
				end
            end
            default:;   
        endcase
    end else begin
		opTxReady <= 0;
		UART_TxData <= 0;
		UART_TxSend <= 0;
        txState <= TransmitWait;
    end
end
//------------------------------------------------------------------------------

// TODO: Implement the Rx stream
always @(posedge(ipClk)) begin
 if (!ipReset) begin
        case(rxState) 
        ReceiveSync: begin
            opRxStream.Valid <= 0;
			BytesReceived <= 1;
			opRxStream.EoP <= 0;
			
            if (UART_RxValid && (UART_RxData == 8'h55)) begin
                rxState <= ReceiveDestination;
            end
        end
        ReceiveDestination: begin
            if (UART_RxValid) begin
                opRxStream.Destination <= UART_RxData;
                rxState <= ReceiveSource;
            end
        end
        ReceiveSource: begin
            if (UART_RxValid) begin
                opRxStream.Source <= UART_RxData;
                rxState <= ReceiveLength;
            end
        end
        ReceiveLength: begin
            if (UART_RxValid) begin
                opRxStream.Length <= UART_RxData;
                rxState <= ReceivePayload;
            end
        end
        ReceivePayload: begin
				opRxStream.SoP <= 1;
				if(UART_RxValid) begin
					opRxStream.Data  <= UART_RxData;
					opRxStream.Valid <= 1;
					if(BytesReceived == 2)
						opRxStream.SoP <= 0;
					else if(BytesReceived == opRxStream.Length) begin
                        opRxStream.EoP <= 1;
						rxState <= ReceiveSync;
					end
					BytesReceived <= BytesReceived + 1;
				end else 
					opRxStream.Valid <= 0;
        end
        default:;   
        endcase
    end else begin
		opRxStream.Source      <= 0;
		opRxStream.Destination <= 0;
		opRxStream.Length      <= 0;
	
		opRxStream.SoP <= 0;
		opRxStream.EoP <= 0;
		opRxStream.Data <= 0;
		opRxStream.Valid <=0;
        rxState <= ReceiveSync;
        BytesReceived <= 0;
    end 
end
//------------------------------------------------------------------------------

endmodule
//------------------------------------------------------------------------------