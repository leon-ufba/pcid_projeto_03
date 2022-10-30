module drawer_tb;

reg clk = 0;
wire [9:0] X;
wire [9:0] Y;
wire D;
wire H, V;
wire [7:0] R;
wire [7:0] G;
wire [7:0] B;

drawer dwr (
	.clk(clk),
	.CounterX(X),
	.CounterY(Y),
	.inDisplayArea(D),
	.vga_h_sync(H),
	.vga_v_sync(V),
	.vga_R(R),
	.vga_G(G),
	.vga_B(B)
);

always #1 clk = ~clk;

reg [0:53][7:0] header  = '{
	8'h42, 8'h4D, 8'h36, 8'h10, 8'h0E, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h36, 8'h00,
	8'h00, 8'h00, 8'h28, 8'h00, 8'h00, 8'h00, 8'h80, 8'h02, 8'h00, 8'h00, 8'hE0, 8'h01,
	8'h00, 8'h00, 8'h01, 8'h00, 8'h18, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h10,
	8'h0E, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00,
	8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00
};

integer file_out; 

reg [64*8-1:0] fileName_out = "vga_out.bmp";

localparam  [9:0] min_x = 64;
localparam  [9:0] min_y = 16;
localparam  [9:0] max_x = 640 + min_x - 1;
localparam  [9:0] max_y = 480 + min_y - 1;

integer i = 0;

initial begin

//	$monitor("time = %0t \t clk = %0h \t H = %0h \t V = %0h \t D = %0h \t X  = %0h \t Y = %0h",
//	$time, clk, H, V, D, X, Y);

	file_out = $fopen(fileName_out, "wb"); 
	if (!file_out) begin
		$error("File could not be open: ", fileName_out);
		$stop();
	end
	
	for(i = 0; i < 54; i = i + 1) begin
		$fwrite(file_out, "%c", header[i]);
	end

end

always @(X) begin
	if(D) begin
		#1 // wait color data be stable
		$fwrite(file_out, "%c%c%c", B, G, R);
	end else if(Y >= max_y && X >= max_x) begin
		$fclose(file_out);
		$stop();
	end
end


endmodule
