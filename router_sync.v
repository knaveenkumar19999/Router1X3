module router_sync(clock,resetn,detect_add,data_in,write_enb_reg,read_enb_0,read_enb_1,read_enb_2,empty_0,empty_1,empty_2,full_0,full_1,full_2,vld_out_0,vld_out_1,vld_out_2,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,write_enb);

input [1:0]data_in;
input clock,resetn,detect_add,write_enb_reg,read_enb_0,read_enb_1,read_enb_2,empty_0,empty_1,empty_2,full_0,full_1,full_2;

output vld_out_0,vld_out_1,vld_out_2;
output reg soft_reset_0,soft_reset_1,soft_reset_2,fifo_full;
output reg[2:0]write_enb;

reg [1:0]int_addr_reg;
reg [4:0]timer_0=5'b0;
reg [4:0]timer_1=5'b0;
reg [4:0]timer_2=5'b0;

  //latch the address logic
always @(posedge clock)
  begin
        if(!resetn)
		   begin
		         int_addr_reg<=2'b11;
		   end
		else if(detect_add)
		   begin
		         int_addr_reg<=data_in;
		   end
		else
		    int_addr_reg<=2'b11;
  end
  
  
  //write_enb logic
always @(*)
  begin
        write_enb=3'b000;
		if(write_enb_reg)
		   begin
		        case(int_addr_reg)
					      2'b00 : write_enb=3'b001;
						  2'b01 : write_enb=3'b010;
						  2'b10 : write_enb=3'b100;
						  default write_enb=3'b000;
			    endcase
		   end
   end
   
   //valid out signal logic
assign vld_out_0=~empty_0;
assign vld_out_1=~empty_1;
assign vld_out_2=~empty_2;

  //fifo full logic
always@(*)
  begin
        case(int_addr_reg)
                 2'b00 :fifo_full=full_0;
                 2'b01 :fifo_full=full_1;
                 2'b10 :fifo_full=full_2;
                 default fifo_full=0;
        endcase
  end

   // soft reset logic
always@(posedge clock)
    begin
	      if(!resetn)
		    begin
			      soft_reset_0<=1'b0;
				  soft_reset_1<=1'b0;
				  soft_reset_2<=1'b0;
				  timer_0<=5'b0;
				  timer_1<=5'b0;
				  timer_2<=5'b0;
			end
		  else
		    begin
			      if(vld_out_0)
				    begin
						 timer_0<= (read_enb_0)? 5'b0:timer_0+1;	
						 if(timer_0==5'd29)
						    begin
							      soft_reset_0<=1'b1;
								  timer_0<=5'b0;
						    end
						 else
						      soft_reset_0<=1'b0;
					end
				  else if(vld_out_1)
				    begin
						 timer_1<= (read_enb_1)? 5'b0:timer_1+1;	
						 if(timer_1==5'd29)
						    begin
							      soft_reset_1<=1'b1;
								  timer_1<=5'b0;
						    end
						 else
						      soft_reset_0<=1'b0;
					end
				  else if(vld_out_2)
				    begin
						 timer_2<= (read_enb_2)? 5'b0:timer_2+1;	
						 if(timer_2==5'd29)
						    begin
							      soft_reset_2<=1'b1;
								  timer_2<=5'b0;
						    end
						 else
						      soft_reset_2<=1'b0;
					end
			      else
				    begin
					      soft_reset_0<=1'b0;
				          soft_reset_1<=1'b0;
				          soft_reset_2<=1'b0;
				          timer_0<=5'b0;
						  timer_1<=5'b0;
						  timer_2<=5'b0;
				    end
			end
	end

endmodule