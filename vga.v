module vga(clk, vga_h_sync, vga_v_sync, inDisplayArea, CounterX, CounterY);

input  clk;
output vga_h_sync, vga_v_sync;
output reg inDisplayArea = 0;
output reg [9:0] CounterX = 0;
output reg [9:0] CounterY = 0;

//////////////////////////////////////////////////
reg vga_HS = 1, vga_VS = 1;
reg [9:0] clockCounter = 0;
wire CounterXmaxed = (CounterX==767);
wire CounterYmaxed = (CounterY==511);

localparam  [9:0] min_x = 64;
localparam  [9:0] min_y = 16;
localparam  [9:0] max_x = 640 + min_x - 1;
localparam  [9:0] max_y = 480 + min_y - 1;

always @(posedge clk) begin
	clockCounter <= clockCounter + 1;
end

always @(clockCounter) begin // 16 clocks pulse
	CounterX      <= (CounterXmaxed) ? 0 : CounterX + 1;
	CounterY      <= (CounterYmaxed) ? 0 : (CounterXmaxed) ? CounterY + 1 : CounterY;
	inDisplayArea <= (CounterYmaxed) ? 0 : (CounterXmaxed) ? 0 : (CounterX >= min_x - 1 && CounterX <= max_x - 1) && (CounterY >= min_y && CounterY <= max_y);
end

always @(CounterX, CounterY) begin
	vga_HS <= (CounterX == 0); // change this value to move the display horizontally
	vga_VS <= (CounterX == 0 && CounterY == 0); // change this value to move the display vertically
end
	
assign vga_h_sync = ~vga_HS;
assign vga_v_sync = ~vga_VS;

endmodule
