module router_fsm(clock,
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

input [1:0]data_in;
input clock,resetn,pkt_valid,parity_done,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full, low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2;

output busy,detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state;

parameter DECODE_ADDRESS =3'b000;
parameter WAIT_TILL_EMPTY=3'b001;
parameter LOAD_FIRST_DATA=3'b010;
parameter LOAD_DATA      =3'b011;
parameter LOAD_PARITY    =3'b100;
parameter CHECK_PARITY_ERROR=3'b101;
parameter FIFO_FULL_STATE=3'b110;
parameter LOAD_AFTER_FULL=3'b111;

reg [2:0]next_state,present_state;
reg [1:0]int_addr_reg;

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

  // present state logic
always @(posedge clock)
    begin
	     if(!resetn || soft_reset_0 || soft_reset_1 || soft_reset_2)
		    begin
			     present_state<=DECODE_ADDRESS;
		    end
		 else
		    begin
			     present_state<=next_state;
			end
	end
	
   //next state logic
always @(*)
    begin
		 case(present_state)
		    
			DECODE_ADDRESS :  if((pkt_valid && (int_addr_reg==2'b00) && fifo_empty_0) ||
			                     (pkt_valid && (int_addr_reg==2'b01) && fifo_empty_1) ||
								 (pkt_valid && (int_addr_reg==2'b10) && fifo_empty_2))
								 begin
								       next_state=LOAD_FIRST_DATA;
							     end
							  else if((pkt_valid && (int_addr_reg==2'b00) && !fifo_empty_0) ||
			                          (pkt_valid && (int_addr_reg==2'b01) && !fifo_empty_1) ||
								      (pkt_valid && (int_addr_reg==2'b10) && !fifo_empty_2))
									   begin
									         next_state=WAIT_TILL_EMPTY;
									   end
							  else
							     begin
								       next_state=present_state;
							     end
			
			WAIT_TILL_EMPTY :  if((fifo_empty_0 && (int_addr_reg==2'b00)) ||
			                      (fifo_empty_1 && (int_addr_reg==2'b01)) ||
								  (fifo_empty_2 && (int_addr_reg==2'b10)) )
								    begin
									     next_state=LOAD_FIRST_DATA;
									end
							   else
							        begin
									     next_state=present_state;
									end
			
			LOAD_FIRST_DATA :  next_state=LOAD_DATA;
			
			LOAD_DATA       :  if(!fifo_full && !pkt_valid)
			                      begin
								        next_state=LOAD_PARITY;
								  end
							   else if(fifo_full)
							      begin
								        next_state=FIFO_FULL_STATE;
								  end
							   else
							      begin
								        next_state=present_state;
								  end
			
			LOAD_PARITY     : next_state=CHECK_PARITY_ERROR;
			
			CHECK_PARITY_ERROR: if(!fifo_full)
								   begin
								        next_state=DECODE_ADDRESS;
								   end
								else
								   begin
								        next_state=FIFO_FULL_STATE;
								   end
			
			FIFO_FULL_STATE :  if(!fifo_full)
								   begin
								        next_state=LOAD_AFTER_FULL;
								   end
								else
								   begin
								        next_state=FIFO_FULL_STATE;
								   end
			
			LOAD_AFTER_FULL : if(!parity_done && low_pkt_valid)
			                      begin
								        next_state=LOAD_PARITY;
								  end
							  else if(!parity_done && !low_pkt_valid)
							      begin
								        next_state=LOAD_DATA;
								  end
							  else if(parity_done)
							      begin
								        next_state=DECODE_ADDRESS;
								  end
			default         :next_state=DECODE_ADDRESS;
	     endcase
	end
	// output logic
assign 	busy         =((present_state==LOAD_FIRST_DATA) ||(present_state==LOAD_PARITY) ||(present_state==FIFO_FULL_STATE) || (present_state==LOAD_AFTER_FULL) || (present_state==WAIT_TILL_EMPTY))?1'b1:1'b0;
assign  detect_add   =(present_state==DECODE_ADDRESS)?1'b1:1'b0;
assign  ld_state     =(present_state==LOAD_DATA)?1'b1:1'b0;
assign  laf_state    =(present_state==LOAD_AFTER_FULL)?1'b1:1'b0;
assign  full_state   =(present_state==FIFO_FULL_STATE)?1'b1:1'b0;
assign  write_enb_reg=((present_state==LOAD_DATA)||(present_state==LOAD_PARITY)|| (present_state==FIFO_FULL_STATE) ||(present_state==LOAD_AFTER_FULL))?1'b1:1'b0;
assign  rst_int_reg  =(present_state==CHECK_PARITY_ERROR)?1'b1:1'b0;
assign  lfd_state    =(present_state==LOAD_FIRST_DATA)?1'b1:1'b0;

/*
always@(*)
 begin
      case(present_state)
	    DECODE_ADDRESS  :   detect_add=1'b1;
		
		LOAD_FIRST_DATA :   begin
		                         lfd_state=1'b1;
		                         busy=1'b1;
							end
		
		LOAD_DATA       :   begin
		                         ld_state=1'b1;
		                         busy=1'b0;
						         write_enb_reg=1'b1;
						    end
		
		LOAD_PARITY     :  	begin
                                 busy=1'b1;
		                         write_enb_reg=1'b1;
							end
		
		FIFO_FULL_STATE :   begin
		                         full_state=1'b1;
		                         busy=1'b1;
		                         write_enb_reg=1'b0;
                            end		
							
		LOAD_AFTER_FULL :   begin
                                 laf_state=1'b1;
		                         busy=1'b1;
		                         write_enb_reg=1'b1;
							end
        
		WAIT_TILL_EMPTY :   begin
		                         busy=1'b1;
		                         write_enb_reg=1'b0;
							end
		
		CHECK_PARITY_ERROR: begin
		                         rst_int_reg=1'b1;
		                         busy=1'b1;
							end
		
		default         :   begin
		                         busy=1'b0;
		                         detect_add=1'b0;
						         ld_state=1'b0;
						         laf_state=1'b0;
						         full_state=1'b0;
						         write_enb_reg=1'b0;
						         rst_int_reg=1'b0;
						         lfd_state=1'b0;
							end
	   endcase
 end*/
endmodule
		