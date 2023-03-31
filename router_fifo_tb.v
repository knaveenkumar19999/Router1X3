module router_fifo_tb();

reg clock,resetn,write_enb,read_enb,soft_reset,lfd_state;
reg [7:0]data_in;

wire [7:0]data_out;
wire empty,full;

integer k;
integer i;

router_fifo DUT(clock,resetn,write_enb,soft_reset,read_enb,data_in,lfd_state,empty,data_out,full);

//initialize
task initialize();
 begin
      clock=1'b0;
	  resetn=1'b1;
	  soft_reset=1'b0;
	  read_enb=1'b0;
	  write_enb=1'b0;
 end
endtask

always #10 clock=~clock;
 
//reset
task reset_dut();
 begin
       @(negedge clock)
	    resetn=1'b0;
	   @(negedge clock)
	    resetn=1'b1;
 end
endtask

//soft reset
task soft_reset_dut();
 begin 
       @(negedge clock)
	    soft_reset=1'b1;
	   @(negedge clock)
	    soft_reset=1'b0;
 end
endtask

//write fifo
task write_fifo();
    reg [7:0]payload_data,parity,header;
	reg [5:0]payload_length;
	reg [1:0]addr;
begin
     @(negedge clock)
	 payload_length=6'd14;
	 addr=2'b01;
	 header={payload_length,addr};
	 data_in=header;
	 lfd_state=1'b1;
	 write_enb=1'b1;
	 for(k=0;k<payload_length;k=k+1)
	  begin
	       @(negedge clock)
	       lfd_state=1'b0;
		   payload_data={$random}%256;
		   data_in=payload_data;
	  end
	 @(negedge clock)
	  lfd_state=1'b0;
	  parity={$random}%256;
	  data_in=parity;
end
endtask

//read fifo
task read_fifo();
 begin
      @(negedge clock)
   	  write_enb=1'b0;
	  read_enb=1'b1;
 end
endtask

initial
 begin
      initialize();
      //reset_dut();
      //soft_reset_dut();
      write_fifo();
      for(i=0;i<19;i=i+1)
        begin
	     read_fifo();
	end
	   
	read_enb=1'b0;
        $finish;  
end

initial
 begin
      $monitor("data_in=%b , data_out=%b",data_in,data_out);
end

endmodule

	  