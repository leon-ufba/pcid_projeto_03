module drawer(
	clk50,
	address,
	
	enable,
	
	wren1,
	data1,
	q1,
	
	wren2,
	data2,
	q2,
	
	wren3,
	data3,
	q3,
	
	CounterX,
	CounterY,
	inDisplayArea,
	dataReady,
	vga_h_sync,
	vga_v_sync,
	vga_R,
	vga_G,
	vga_B
);

input clk50;

input wire enable;

input  wire [18:0] address;

input  wire wren1;
input  wire [23:0] data1;
output wire [23:0] q1;

input  wire wren2;
input  wire [23:0] data2;
output wire [23:0] q2;

input  wire wren3;
output wire [23:0] data3;
output wire [23:0] q3;

output vga_h_sync, vga_v_sync;
output reg [7:0] vga_R;
output reg [7:0] vga_G;
output reg [7:0] vga_B;

output wire [9:0] CounterX;
output wire [9:0] CounterY;
output wire inDisplayArea;
output wire dataReady;


reg clk25 = 0;
reg clock25Counter = 0;
wire data_ready;
reg [3:0] data3OutCounter = 0;

reg [18:0] dwr_addr = 0;

wire [18:0] cmp_address;
wire cmp_wren3;

comparator cmp (
	.clk(clk50),
	.address(cmp_address),
	
	.wren1(wren1),
	.data1(data1),
	.q1(q1),
	
	.wren2(wren2),
	.data2(data2),
	.q2(q2),
	
	.wren3(cmp_wren3),
	.data3(data3),
	.q3(q3)
);

vga syncgen(
	.clk(clk25),
	.data_ready(data_ready),
	.vga_h_sync(vga_h_sync),
	.vga_v_sync(vga_v_sync),
	.inDisplayArea(inDisplayArea),
	.CounterX(CounterX),
	.CounterY(CounterY)
);

always @(posedge clk50) begin
	clock25Counter <= ~clock25Counter;
	if(clock25Counter) begin
		clk25 = ~clk25;
	end
	
	if(enable) begin
		data3OutCounter <= (data_ready)? 15 : data3OutCounter + 1;
	end else begin
		data3OutCounter <= 0;
	end
end


always @(CounterX, data_ready) begin
	if(dataReady) begin
		dwr_addr <= dwr_addr + 1;
		vga_R <= q3[23:16];
		vga_G <= q3[15:08];
		vga_B <= q3[07:00];
	end else begin
		dwr_addr <= (data_ready) ? dwr_addr : 0;
	end
end

assign cmp_address = (enable) ? dwr_addr : address;
assign cmp_wren3 = (enable) ? 0 : wren3;
assign data_ready = (data3OutCounter >= 15);
assign dataReady = inDisplayArea && data_ready;


endmodule
