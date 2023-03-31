module router_sync_tb();

reg [1:0]data_in;
reg clock,resetn,detect_add,write_enb_reg,read_enb_0,read_enb_1,read_enb_2,empty_0,empty_1,empty_2,full_0,full_1,full_2;

wire vld_out_0,vld_out_1,vld_out_2,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full;
wire [2:0]write_enb;

router_sync DUT (clock,resetn,detect_add,data_in,write_enb_reg,read_enb_0,read_enb_1,read_enb_2,empty_0,empty_1,empty_2,full_0,full_1,full_2,vld_out_0,vld_out_1,vld_out_2,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,write_enb);

 //initialize logic
task intialize();
  begin
       clock=1'b0;
	   resetn=1'b1;
	   detect_add=1'b0;
	   write_enb_reg=1'b0;
	   read_enb_0=1'b0;
	   read_enb_1=1'b0;
	   read_enb_2=1'b0;
	   empty_0=1'b1;
	   empty_1=1'b1;
	   empty_2=1'b1;
	   full_0=1'b0;
	   full_1=1'b0;
	   full_2=1'b0;
  end
endtask

always #10 clock=~clock;

 //reset logic
task reset_dut();
  begin
        @(negedge clock)
		resetn=1'b0;
		@(negedge clock)
		resetn=1'b1;
  end
endtask

  //data input logic
task data_input(input [1:0]a);
  begin
        @(negedge clock)
		data_in=a;
  end
endtask

initial
   begin
        intialize();
		reset_dut();
		detect_add=1'b1;
		data_input(00);
		//write enable testing
		write_enb_reg=1'b1;
		full_0=1'b1;
		empty_0=1'b0;
		read_enb_0=1'b0;
        #700;
        read_enb_0=1'b1;
        #50;		
		$finish;
	end
endmodule
		
		
