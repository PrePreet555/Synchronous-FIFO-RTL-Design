module 
fifo(data_in,clock,resetn,write_enb,soft_reset,read_enb,lfd_state,empty,full,data_out);
parameter 
    width = 9,
      depth = 16,
      addr_bus = 5,
      payload_length = 7;
input [width-2:0]data_in;
input clock,resetn,soft_reset,write_enb,read_enb,lfd_state;
output empty,full;
output reg [width-2:0]data_out;
integer i;

reg temp;
reg [width-1:0]mem[0:depth-1];
reg [payload_length-1:0]counter;
reg [addr_bus-1:0]write_ptr,read_ptr;


//temp - delay
always@(posedge clock)
  begin
     if(!resetn)
        temp<=1'b0;
     else
        temp<=lfd_state;
end

//Pointer Logic
always@(posedge clock)
begin
if(!resetn)
write_ptr <= 5'b0;
else if(write_enb && !full)
write_ptr <= write_ptr + 1'b1;
end
always@(posedge clock)
begin
if(!resetn)
read_ptr <= 0;
else if(read_enb && !empty)
read_ptr <= read_ptr + 1'b1;
end

//Counter Logic
always@(posedge clock)
begin
if(read_enb && !empty)
begin
if(temp == 1'b1)
counter <= mem[read_ptr][7:2] + 1'b1;
else if(counter!=0)
counter <= counter - 1'b1;
else
counter <= counter;
end
end

//Write Operation
always@(posedge clock)
begin
if(!resetn)
begin
for(i=0;i<16;i=i+1)
mem[i]=8'b0;
end
else if(soft_reset)
begin
for(i=0;i<16;i=i+1)
mem[i]=8'b0;
end
else
begin 
if(write_enb && !full && temp)
{mem[write_ptr][8],mem[write_ptr][7:0]}={temp,data_in};
else
{mem[write_ptr][8],mem[write_ptr][7:0]}={1'b0,data_in};
end
end

//Read Operation
always@(posedge clock)
begin
if(!resetn)
data_out <= 8'b0;
else if(soft_reset)
data_out <= 8'bz;
else
begin
if(counter == 0)
data_out <= 8'bz;
else
begin
if(read_enb && !empty)
data_out <= {mem[read_ptr][7:0]};
else
data_out <= data_out;
end
end
end
assign full = (write_ptr == {~read_ptr[4],read_ptr[3:0]})? 1'b1 : 1'b0;
assign empty = (write_ptr == read_ptr)? 1'b1 : 1'b0;
endmodule
