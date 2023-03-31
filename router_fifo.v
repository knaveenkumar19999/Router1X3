module router_fifo(clock,resetn,write_enb,soft_reset,read_enb,data_in,lfd_state,empty,data_out,full);

input clock,resetn,write_enb,read_enb,soft_reset,lfd_state;
input [7:0]data_in;

output reg [7:0]data_out;
output empty,full;

reg [8:0]memory[15:0];
reg [4:0]write_pointer=5'b0;
reg [4:0]read_pointer=5'b0;
reg [6:0]fifo_counter=7'b0;
integer i;

//fifo counter logic
always@(posedge clock)
 begin
      if((resetn==0) || (soft_reset==1))
	   begin
	        fifo_counter<=7'b0;
	   end
	  else if((read_enb==1) && (empty==0))
	   begin
	        if(memory[read_pointer[3:0]][8]==1'b1)
			 begin
			      fifo_counter<=memory[read_pointer[3:0]][7:2]+1'b1;
			 end
			else
			 begin
			      fifo_counter<=fifo_counter-1;
		     end
	   end
	  else
	   begin
	        fifo_counter<=fifo_counter;
	   end
 end
 
    //write operation logic
always@(posedge clock)
 begin
      if((resetn==0) || (soft_reset==1))
	   begin
	         for(i=0;i<8;i=i+1)
			  begin 
			        memory[i]<=0;
					write_pointer<=5'b0;
			  end
	   end  
	  else if((write_enb==1) && (full==0))
	   begin
	        {memory[write_pointer[3:0]][8],memory[write_pointer[3:0]][7:0]}<={lfd_state,data_in};
			write_pointer<=write_pointer+1;
	   end
      else
       begin
            write_pointer<=write_pointer;	
       end
 end	
 
   //read operation logic
always@(posedge clock)
 begin
      if(resetn==0)
       begin
             data_out<=8'b0;
			 read_pointer<=5'b0;
       end
	  else if(soft_reset==1)
       begin
             data_out<=8'bz;
			 read_pointer=5'b0;
       end
	  else if((empty==1) && (fifo_counter==0))
	   begin
	        data_out<=8'bz;
	   end
      else if((empty==0) && (read_enb==1))
       begin
	         data_out<=memory[read_pointer[3:0]];
			 read_pointer<=read_pointer+1;
       end
      else
       begin
	         data_out<=8'b0;
             read_pointer<=read_pointer;
       end
 end
 
assign full=(write_pointer > 5'b01111 && read_pointer==0)?1'b1:1'b0;
assign empty=(read_pointer==write_pointer) ? 1'b1:1'b0;
 
endmodule 