`timescale 1ns / 1ps

//+--------+--------+---------+---------+
//| Dest   | Source | Type    | Payload |
//| 6 Bytes|6 Bytes |2 Bytes  | Variable|
//+--------+--------+---------+---------+

//The parser's job is-

//detect packet start
//identify which field is arriving
//store header fields
//determine payload length
//signal packet completion

//A parser doesn't modify data. It extracts information.

//used in nearly every networking chip

module packet_parser(
    input logic clk,
    input logic rst,
    
    input logic [7:0] data_in,
    input logic data_valid,
    input logic sop,
    
    output logic [47:0] dest_addr,
    output logic [47:0] src_addr,
    output logic [15:0] pkt_type,
    output logic packet_done
    );
    
    
    typedef enum logic[2:0]
    {
        IDLE,
        DEST,
        SOURCE,
        TYPE,
        PAYLOAD,
        DONE
    } state_t;
    
    state_t state;
    
    logic [3:0] byte_count;
    logic [7:0] payload_count;
    
    always_ff @(posedge clk)
    begin
        
        if(rst) begin
            state <= IDLE;
            byte_count <= 0;
            payload_count <= 0;
            
            dest_addr <= 0;
            src_addr <= 0;
            pkt_type <= 0;
            packet_done <= 0;
        end
            
        else begin
        
            packet_done <= 0;
            
            if(data_valid)
            
            case(state)
                
                IDLE:
                begin
                if(sop)
                    begin
                        state <= DEST;
                        byte_count <= 0;
                    end
                end
                
                DEST:
                begin
                    
                    dest_addr <= {dest_addr[39:0],data_in};
                    
                    if(byte_count==5)
                    begin
                        state <= SOURCE;
                        byte_count <= 0;
                    end else
                    byte_count <= byte_count+1;
                    
                end
                
                SOURCE:
                begin
                
                    src_addr <= {src_addr[39:0],data_in};
                    
                    if(byte_count==5)
                    begin
                        state <= TYPE;
                        byte_count <= 0;
                    end else
                        byte_count <= byte_count+1;
                
                end
                
                TYPE:
                begin
                
                    pkt_type <= {pkt_type[7:0],data_in};
                    
                    if(byte_count==1)
                    begin
                        state <= PAYLOAD;
                        byte_count <= 0;
                        payload_count <= 5; // example payload
                    end
                    
                    else
                        byte_count <= byte_count+1;
                    
                end
                
                PAYLOAD:
                begin
                    
                    if(payload_count==0)
                        state <= DONE;
                    else
                        payload_count <= payload_count-1;
                
                end
                
                DONE:
                begin
                
                    packet_done <= 1;
                    state <= IDLE;
                
                end
                
            endcase
            
        end
        
    end
    
endmodule
