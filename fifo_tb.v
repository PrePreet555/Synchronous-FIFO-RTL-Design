module fifo_tb();

reg [7:0]data_in;
reg clock,resetn,soft_reset,write_enb,read_enb,lfd_state;
wire full,empty;
wire [7:0]data_out;
integer i,j;
fifo 
DUT(data_in,clock,resetn,write_enb,soft_reset,read_enb,lfd_state,empty,full,data_out);

initial 
begin
clock=1'b0;
forever
#5 clock=~clock;
end

task initialization;
begin
write_enb = 1'b0;
read_enb = 1'b0;
resetn = 1'b0;
soft_reset =1'b1;
end
endtask

task fifo_reset;
begin
@(negedge clock)
resetn = 1'b0;
@(negedge clock)
resetn = 1'b1;
end
endtask

task fifo_soft_reset;
begin
@(negedge clock)
soft_reset = 1'b1;
@(negedge clock)
soft_reset = 1'b0;
end
endtask

task fifo_write;
reg [7:0] payload_data, parity, header;
reg [5:0] payload_len;
reg [1:0] addr;
begin
@(negedge clock)
payload_len = 6'd14;
addr = 2'b01;
header ={payload_len,addr};
//data_in = header;
lfd_state = 1'b1;
write_enb =1'b1;
data_in = {lfd_state,header};
for(j=0; j<payload_len; j=j+1)
begin
@(negedge clock)
lfd_state = 1'b0;
payload_data = {$random}%256;
data_in = payload_data;
end
@(negedge clock)
lfd_state = 1'b0;
parity = {$random}%256;
data_in = parity;
end
endtask

task fifo_read;
begin
@(negedge clock)
write_enb = 1'b0;
read_enb = 1'b1;
end
endtask

initial 
begin

initialization();
//#10;
fifo_reset();
fifo_soft_reset();
fifo_write();
for(i=0;i<17;i=i+1)
fifo_read();
#10;
read_enb=1'b0;
end

initial
begin
$monitor("Input clock=%b, resetn=%b, write_enb=%b, read_enb=%b, data_in=%b, lfd_state=%b, full=%b, empty=%b, data_out=%b",
         clock, resetn, write_enb, read_enb, data_in,
         lfd_state, full, empty, data_out);
end
initial
#1000
$finish();

endmodule
