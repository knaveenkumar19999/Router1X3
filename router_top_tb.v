module router_top_tb();

reg clock,resetn,read_enb_0,read_enb_1,read_enb_2,pkt_valid;
reg [7:0]data_in;

wire valid_out_0,valid_out_1,valid_out_2,error,busy;
wire [7:0]data_out_0,data_out_1,data_out_2;

router_top ROUTER_DUT(clock,
                      resetn,
				      read_enb_0,
				      read_enb_1,
				      read_enb_2,
				      data_in,
				      pkt_valid,
				      data_out_0,
				      data_out_1,
				      data_out_2,
				      valid_out_0,
				      valid_out_1,
				      valid_out_2,
				      error,
				      busy);
					  
task intialize();
    begin
	     clock=1'b0;
		 resetn=1'b1;
		 read_enb_0=1'b0;
		 read_enb_1=1'b0;
		 read_enb_2=1'b0;
		 pkt_valid=1'b0;
	end
endtask

always #10 clock=~clock;

task reset_dut();
    begin
	     @(negedge clock)
		 resetn=1'b0;
		 @(negedge clock)
		 resetn=1'b1;
	end
endtask

task packet_12();
    begin 
	     @(negedge clock)
	     pkt_valid=1'b1;
		 data_in=8'b00011100;
		 #40;
		 @(negedge clock)
		 data_in=8'd4;
		 @(negedge clock)
		 data_in=8'd8;
		 read_enb_0=2'd1;
		 @(negedge clock)
		 data_in=8'd9;
		 @(negedge clock)
		 data_in=8'd6;
		 @(negedge clock)
		 data_in=8'd3;
		 pkt_valid=1'b0;
		 @(negedge clock)
		 data_in=8'd28;
	end
endtask

task packet_8();
    begin 
	     @(negedge clock)
	     pkt_valid=1'b1;
		 data_in=8'b00011101;
		 #40;
		 @(negedge clock)
		 data_in=8'd4;
		 @(negedge clock)
		 data_in=8'd8;
		 read_enb_1=2'd1;
		 @(negedge clock)
		 data_in=8'd9;
		 @(negedge clock)
		 data_in=8'd6;
		 @(negedge clock)
		 data_in=8'd3;
		 pkt_valid=1'b0;
		 @(negedge clock)
		 data_in=8'd2;
	end
endtask 

initial
    begin
	     intialize();
		 reset_dut();
		 packet_12();
		 #200;
		 packet_8();
		 #100;
		 $finish;
    end
	
endmodule
		 
		 