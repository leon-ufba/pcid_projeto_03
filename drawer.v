module drawer(clk, CounterX, CounterY, inDisplayArea, vga_h_sync, vga_v_sync, vga_R, vga_G, vga_B);
input clk;
output vga_h_sync, vga_v_sync;
output reg [7:0] vga_R;
output reg [7:0] vga_G;
output reg [7:0] vga_B;

output wire [9:0] CounterX;
output wire [9:0] CounterY;
output wire inDisplayArea;

localparam  [9:0] min_x = 64;
localparam  [9:0] min_y = 16;
localparam  [9:0] max_x = 640 + min_x - 1;
localparam  [9:0] max_y = 480 + min_y - 1;

vga syncgen(
	.clk(clk), .vga_h_sync(vga_h_sync), .vga_v_sync(vga_v_sync),
	.inDisplayArea(inDisplayArea), .CounterX(CounterX), .CounterY(CounterY)
);

always @(CounterX) begin
  vga_R <= (CounterX == min_x) || (CounterX == max_x) || (CounterY == min_y) || (CounterY == max_y) ? 8'hFF : 8'h00;
  vga_G <= (CounterX == min_x) || (CounterX == max_x) || (CounterY == min_y) || (CounterY == max_y) ? 8'hFF : 8'h00;
  vga_B <= (CounterX >= (min_x + max_x) / 2) ? 8'hFF : 8'h00;
end

endmodule
