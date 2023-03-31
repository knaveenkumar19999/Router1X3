module router_reg_tb();

reg clock,resetn,pkt_valid,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state;
reg [7:0]data_in;

wire parity_done,low_pkt_valid,err;
wire [7:0]dout;

router_reg DUT (clock,
                resetn,
				pkt_valid,
				data_in,
				fifo_full,
				rst_int_reg,
				detect_add,
				ld_state,
				laf_state,
				full_state,
				lfd_state,
				parity_done,
				low_pkt_valid,
				err,
				dout);

task initialize();
   begin
        clock=1'b0;
		resetn=1'b1;
		pkt_valid=1'b0;
		full_state=1'b0;
		fifo_full=1'b0;
		rst_int_reg=1'b0;
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

initial
    begin
	     initialize();
		 reset_dut();
		/* #20 pkt_valid=1'b1;
		 data_in=20;
		 detect_add=1;
		 #20 detect_add=0;
		 lfd_state=1'b1;
		 #20 lfd_state=1'b0;
		 data_in=8;
		 ld_state=1'b1;
		 #20 data_in=10;
		 #20 data_in=5;
		 full_state=1'b0;
         pkt_valid=1'b0;
         data_in=19;
		 #40 rst_int_reg=1'b1;
		 #40 $finish;*/
		  #20 detect_add = 1;
  pkt_valid = 1;
  data_in = 8'ha7;   //store header byte in hhb
  #20 detect_add = 0;
  lfd_state = 1;  //header byte comes out of hhb
  #20 ld_state = 1;
  lfd_state = 0;
  fifo_full = 0;
  data_in = 8'd65;
  #20 data_in = 8'd76;
  #20 data_in = 8'd44;
  #20 data_in = 8'd82;
  fifo_full = 1;
  #20 ld_state = 0;
  full_state = 1;
  data_in = 4;
  #20 fifo_full = 0;
  full_state = 0;
  laf_state = 1;
  #20 ld_state = 1;
  laf_state = 0;
  data_in = 8'h09;
  pkt_valid = 0;
  #20 ld_state = 0;
  #20 rst_int_reg = 1;
  #20 detect_add = 1;
  #40 rst_int_reg=1'b1;
		 #40 $finish;
	end
endmodule
           






		   
 		  