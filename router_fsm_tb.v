module router_fsm_tb();

reg [1:0]data_in;
reg clock,resetn,pkt_valid,parity_done,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full, low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2;

wire busy,detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state;

router_fsm DUT (clock,
                resetn,
				pkt_valid,
				parity_done,
				data_in,
				soft_reset_0,
				soft_reset_1,
				soft_reset_2,
				fifo_full,
				low_pkt_valid,
				fifo_empty_0,
				fifo_empty_1,
				fifo_empty_2,
				busy,
				detect_add,
				ld_state,
				laf_state,
				full_state,
				write_enb_reg,
			    rst_int_reg,
				lfd_state);

//initalize 				
task initialize();
   begin
        clock=1'b0;
		resetn=1'b1;
		soft_reset_0=1'b0;
		soft_reset_1=1'b0;
		soft_reset_2=1'b0;
		pkt_valid=1'b0;
		data_in=2'b11;
		fifo_empty_0=1'b1;
		fifo_empty_1=1'b1;
		fifo_empty_2=1'b1;
		parity_done=1'b0;
		low_pkt_valid=1'b1;
	end
endtask

//clock
always #10 clock=~clock;

// resetn logic
task reset_dut();
    begin
	     @(negedge clock)
		 resetn=1'b0;
		 @(negedge clock)
		 resetn=1'b1;
	end
endtask

//soft reset 0 logic
task soft_reset_0_dut();
    begin
	     @(negedge clock)
		 soft_reset_0=1'b1;
		 @(negedge clock)
		 soft_reset_0=1'b0;
    end
endtask

//soft reset 1 logic
task soft_reset_1_dut();
    begin
	     @(negedge clock)
		 soft_reset_1=1'b1;
		 @(negedge clock)
		 soft_reset_1=1'b0;
    end
endtask

//soft reset 2 logic
task soft_reset_2_dut();
    begin
	     @(negedge clock)
		 soft_reset_2=1'b1;
		 @(negedge clock)
		 soft_reset_2=1'b0;
    end
endtask

//DA_WTE_LFD_LD__LP_CPE_DA logic
task DA_WTE_LFD_LD_LP_CPE_DA();
    begin
	    pkt_valid=1'b1;
		data_in=00;
		fifo_empty_0=1'b0;
		#20
		fifo_empty_0=1'b1;
		#40;
        pkt_valid=1'b0;		
		fifo_full=1'b0;
		pkt_valid=1'b0;
		#20;
		fifo_full=1'b0;
	end
endtask

//DA_LFD_LD__LP_CPE_DA
task DA_LFD_LD_LP_CPE_DA();
    begin
	    pkt_valid=1'b1;
		data_in=00;
		fifo_empty_0=1'b1;
		#40;
        pkt_valid=1'b0;		
		fifo_full=1'b0;
		pkt_valid=1'b0;
		#20;
		fifo_full=1'b0;
	end
endtask

//DA_LFD_LD_FFS_LAF_LP_CPE_DA
task DA_LFD_LD_FFS_LAF_LP_CPE_DA();
    begin
		  pkt_valid=1'b1;
		  data_in=00;
		  fifo_empty_0=1'b1;
		  #40;
		  pkt_valid=1'b0;
		  fifo_full=1'b1;
		  #30;
		  fifo_full=1'b0;
		  #20;
		  parity_done=1'b0;
		  low_pkt_valid=1'b1;
		  #20;
		  fifo_full=1'b0;
    end
endtask

//DA_LFD_LD_FFS_LAF_LD_LP_CPE_DA;
task DA_LFD_LD_FFS_LAF_LD_LP_CPE_DA();
    begin
		  pkt_valid=1'b1;
		  data_in=00;
		  fifo_empty_0=1'b1;
		  #40;
		  pkt_valid=1'b0;
		  fifo_full=1'b1;
		  #30;
		  fifo_full=1'b0;
		  #10;
		  parity_done=1'b0;
		  low_pkt_valid=1'b0;
		  #20;
		  pkt_valid=1'b0;
		  #20;
		  fifo_full=1'b0;
	end
endtask

//DA_LFD_LD_LP_CPE_FFS_LAF_DA
task DA_LFD_LD_LP_CPE_FFS_LAF_DA();
    begin
		  pkt_valid=1'b1;
		  data_in=00;
		  fifo_empty_0=1'b1;
		  #40;
		  fifo_full=1'b0;
		  pkt_valid=1'b0;
		  #30;
		  fifo_full=1'b1;
		  #30;
		  fifo_full=1'b0;
		  #10;
		  parity_done=1'b1;
	end
endtask

initial
    begin
         initialize;
         reset_dut();
		 DA_WTE_LFD_LD_LP_CPE_DA();
		 #100;
         DA_LFD_LD_LP_CPE_DA();
         #120;
         DA_LFD_LD_FFS_LAF_LP_CPE_DA();
         #160;
         DA_LFD_LD_FFS_LAF_LD_LP_CPE_DA();
         #200;
         DA_LFD_LD_LP_CPE_FFS_LAF_DA();
         #100;
         $finish;
    end
endmodule
