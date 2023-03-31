module router_reg(clock,
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

input clock,resetn,pkt_valid,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state;
input [7:0]data_in;

output reg parity_done,low_pkt_valid,err;
output reg [7:0]dout;

reg [7:0]hold_header_byte,fifo_full_state_byte,internal_parity_byte,packet_parity_byte;

//hold header byte and fifo full byte logic
always@(posedge clock)
   begin
        if(!resetn)
		     begin
			      hold_header_byte<=8'b0;
				  fifo_full_state_byte<=8'b0;
		     end
		else if(pkt_valid && detect_add)
		     begin
			      hold_header_byte<=data_in;
			 end
		else if(ld_state && fifo_full)
		     begin
			       fifo_full_state_byte<=data_in;
			 end
	end

// dout logic
always@(posedge clock)
    begin
	     if(!resetn)
		    begin 
			      dout<=8'b0;
			end
		 else if(lfd_state)
		    begin
			      dout<=hold_header_byte;
			end
		 else if(ld_state && !fifo_full)
		    begin
			      dout<=data_in;
			end
		 else if(fifo_full && laf_state)
		    begin
			      dout<=fifo_full_state_byte;
			end
    end

// low packet valid logic
always@(posedge clock)
    begin
	     if(!resetn || rst_int_reg)
		    begin 
		         low_pkt_valid<=1'b0;
		    end
		 else if(ld_state && !pkt_valid)
		    begin
			      low_pkt_valid<=1'b1;
			end
	end
	
//parity done logic
always@(posedge clock)
    begin
	     if(!resetn || detect_add)
		    begin
			     parity_done=1'b0;
			end
	     else if((ld_state &&  !fifo_full && !pkt_valid) || (laf_state && !parity_done && low_pkt_valid))
		    begin
			     parity_done=1'b1;
			end
	end


//packet_parity logic

always@(posedge clock)
    begin
	     if(!resetn)
		    begin
			     packet_parity_byte<=8'b0;
		    end
         else if(ld_state && !pkt_valid)
            begin
                  packet_parity_byte<=data_in;
            end
		 else
		    begin
			     packet_parity_byte<=packet_parity_byte;
			end
    end

// internal parity
always@(posedge clock)
    begin
	     if(!resetn)
		     begin
			      internal_parity_byte<=8'b0;
			 end
		 else if(lfd_state)
		     begin
			      internal_parity_byte<=internal_parity_byte^hold_header_byte;
		     end
		 else if(ld_state && !full_state && pkt_valid)
		     begin
			      internal_parity_byte<=internal_parity_byte^data_in;
		     end
		 else
		     begin
			      internal_parity_byte<=internal_parity_byte;
			 end
	end

//error logic
always@(posedge clock)
    begin
	     if(!resetn)
		     begin
			       err<=1'b0;
		     end
		 else if(parity_done==1'b1 && (internal_parity_byte!=packet_parity_byte))
		     begin
			       err<=1'b1;
			 end
	     else
		     err<=1'b0;
	end
	
endmodule
	
			 
		           