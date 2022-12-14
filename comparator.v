module comparator(
	clk,
	address,
	
	wren1,
	data1,
	q1,
	
	wren2,
	data2,
	q2,
	
	wren3,
	data3,
	q3
);

input clk;

input  wire [18:0] address;

input  wire wren1;
input  wire [23:0] data1;
output wire [23:0] q1;

input  wire wren2;
input  wire [23:0] data2;
output wire [23:0] q2;

input  wire wren3;
output reg  [23:0] data3;
output wire [23:0] q3;

mem mem1(
	.clock(clk),
	.address(address),
	.wren(wren1),
	.data(data1),
	.q(q1)
);

mem mem2(
	.clock(clk),
	.address(address),
	.wren(wren2),
	.data(data2),
	.q(q2)
);

mem mem3(
	.clock(clk),
	.address(address),
	.wren(wren3),
	.data(data3),
	.q(q3)
);

always @(negedge clk) begin
	data3[23:16] <= (q2[23:16] != q1[23:16]) ? q1[23:16] : 8'h80;
	data3[15:08] <= (q2[15:08] != q1[15:08]) ? q1[15:08] : 8'h80;
	data3[07:00] <= (q2[07:00] != q1[07:00]) ? q1[07:00] : 8'h80;
end

endmodule
