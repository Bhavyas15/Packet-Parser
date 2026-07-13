`timescale 1ns / 1ps

// add the following to Tcl console-
//add_wave /tb/dut/state /tb/dut/byte_count /tb/dut/payload_count
//restart
//run all

module tb;
    logic clk;
    logic rst;
    
    logic [7:0] data_in;
    logic data_valid;
    logic sop;
    
    logic [47:0] dest_addr;
    logic [47:0] src_addr;
    logic [15:0] pkt_type;
    logic packet_done;
    
    // Instantiate DUT
    packet_parser dut(
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .data_valid(data_valid),
        .sop(sop),
        .dest_addr(dest_addr),
        .src_addr(src_addr),
        .pkt_type(pkt_type),
        .packet_done(packet_done)
    );
    
    //---------------------------------------------------
    // Clock Generation
    //---------------------------------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk;      // 10 ns clock period
    end
    
    //---------------------------------------------------
    // Task to send one byte
    //---------------------------------------------------
    task send_byte(input [7:0] byte_sent);
    begin
        @(posedge clk);
        data_valid <= 1;
        data_in <= byte_sent;
    end
    endtask
    
    always @(posedge clk) begin
        $display("----------------------------------------");
        $display("Time           : %0t", $time);
        $display("State          : %s", dut.state.name());
        $display("Byte Count     : %0d", dut.byte_count);
        $display("Payload Count  : %0d", dut.payload_count);
        $display("Data In        : %h", data_in);
        $display("Dest Addr      : %h", dut.dest_addr);
        $display("Src Addr       : %h", dut.src_addr);
        $display("Type           : %h", dut.pkt_type);
    end    
    
    //---------------------------------------------------
    // Test Sequence
    //---------------------------------------------------
    initial begin
    
        rst = 1;
        data_valid = 0;
        sop = 0;
        data_in = 0;
    
        repeat(2) @(posedge clk);
    
        rst = 0;
    
        //------------------------------------------------
        // Start of Packet
        //------------------------------------------------
    
        @(posedge clk);
        data_valid <= 1;
        sop <= 1;
    
        send_byte(8'h11);
        sop <= 0;
    
        send_byte(8'h22);
        send_byte(8'h33);
        send_byte(8'h44);
        send_byte(8'h55);
        send_byte(8'h66);
    
        // Source
        send_byte(8'hAA);
        send_byte(8'hBB);
        send_byte(8'hCC);
        send_byte(8'hDD);
        send_byte(8'hEE);
        send_byte(8'hFF);
    
        // Type
        send_byte(8'h08);
        send_byte(8'h00);
    
        // Payload ("Hello")
        send_byte(8'h48);
        send_byte(8'h65);
        send_byte(8'h6C);
        send_byte(8'h6C);
        send_byte(8'h6F);
    
        @(posedge clk);
    
//        data_valid <= 0;
        data_in <= 0;
    
        repeat(5) @(posedge clk);
    
        //------------------------------------------------
        // Display Results
        //------------------------------------------------
    
//        $display("--------------------------------------");
//        $display("Destination = %h", dest_addr);
//        $display("Source      = %h", src_addr);
//        $display("Type        = %h", pkt_type);
//        $display("Packet Done = %b", packet_done);     
//        $display("--------------------------------------");
    
        $finish;
    
    end

endmodule