module drawer_tb;

reg clk = 0;
always #1 clk = ~clk;

integer i = 0;
integer m = 0;

integer file_in_1;
integer file_in_2;
integer file_out;

reg [64*8-1:0] fileName_in_1  = "vga_in_1.bmp"; 
reg [64*8-1:0] fileName_in_2  = "vga_in_2.bmp";
reg [64*8-1:0] fileName_out   = "vga_out.bmp";

reg [31:0] headerSize1 = 0;
reg [31:0] headerSize2 = 0;
reg [31:0] headerSize3 = 54;

wire [9:0] X;
wire [9:0] Y;
wire A, D;
wire H, V;
wire [7:0] R;
wire [7:0] G;
wire [7:0] B;

reg  enable;

reg  [18:0] address;

reg  wren1;
reg  [23:0] data1;
wire [23:0] q1;

reg  wren2;
reg  [23:0] data2;
wire [23:0] q2;

reg  wren3;
wire [23:0] data3;
wire [23:0] q3;

drawer dwr (
	.clk50(clk),
	
	.enable(enable),
	
	.address(address),
	
	.wren1(wren1),
	.data1(data1),
	.q1(q1),
	
	.wren2(wren2),
	.data2(data2),
	.q2(q2),
	
	.wren3(wren3),
	.data3(data3),
	.q3(q3),
	
	.CounterX(X),
	.CounterY(Y),
	.inDisplayArea(A),
	.dataReady(D),
	.vga_h_sync(H),
	.vga_v_sync(V),
	.vga_R(R),
	.vga_G(G),
	.vga_B(B)
);

reg [0:53][7:0] header  = '{
	8'h42, 8'h4D, 8'h36, 8'h10, 8'h0E, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h36, 8'h00,
	8'h00, 8'h00, 8'h28, 8'h00, 8'h00, 8'h00, 8'h80, 8'h02, 8'h00, 8'h00, 8'hE0, 8'h01,
	8'h00, 8'h00, 8'h01, 8'h00, 8'h18, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h10,
	8'h0E, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00,
	8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00
};

localparam  [9:0] min_x = 64;
localparam  [9:0] min_y = 16;
localparam  [9:0] max_x = 640 + min_x - 1;
localparam  [9:0] max_y = 480 + min_y - 1;

initial begin

	enable  = 0;
	address = 0;
	data1 = 0;
	data2 = 0;
	wren1 = 1;
	wren2 = 1;
	wren3 = 0;
	
	/////////////////////////////////////////////////
	//	input 1
	/////////////////////////////////////////////////
	
	file_in_1 = $fopen(fileName_in_1, "rb");
	if (!file_in_1) begin
		$error("File could not be open: ", file_in_1);
		$stop();
	end
	
	$fseek(file_in_1, 10, 0);
	$fread(headerSize1, file_in_1);
	headerSize1 = {<<8{headerSize1}};
	
	$fseek(file_in_1, headerSize1, 0);
	
	/////////////////////////////////////////////////
	//	input 2
	/////////////////////////////////////////////////
	
	file_in_2 = $fopen(fileName_in_2, "rb");
	if (!file_in_2) begin
		$error("File could not be open: ", file_in_2);
		$stop();
	end
	
	$fseek(file_in_2, 10, 0);
	$fread(headerSize2, file_in_2);
	headerSize2 = {<<8{headerSize2}};
	
	$fseek(file_in_2, headerSize2, 0);

	/////////////////////////////////////////////////
	//	output
	/////////////////////////////////////////////////
	
	file_out = $fopen(fileName_out, "wb"); 
	if (!file_out) begin
		$error("File could not be open: ", fileName_out);
		$stop();
	end
	
	for(i = 0; i < headerSize3; i = i + 1) begin
		$fwrite(file_out, "%c", header[i]);
	end
	
	/////////////////////////////////////////////////
	//	write
	/////////////////////////////////////////////////
	
	m = 480 * 640;
	
	wren1 = 1;
	wren2 = 1;
	wren3 = 0;
	
	for(i = 0; i < m; i = i + 1) begin
		#2
		address <= i;
		$fscanf(file_in_1,"%c%c%c", data1[07:00], data1[15:08], data1[23:16]);
		$fscanf(file_in_2,"%c%c%c", data2[07:00], data2[15:08], data2[23:16]);
	end
	
	/////////////////////////////////////////////////
	//	comparation
	/////////////////////////////////////////////////
	
	#3
	wren1 = 0;
	wren2 = 0;
	wren3 = 1;
	
	#10
	for(i = 0; i < m; i = i + 1) begin
		#8
		address <= i;
	end
	
	/////////////////////////////////////////////////
	//	draw
	/////////////////////////////////////////////////
	
	#10
	wren1 = 0;
	wren2 = 0;
	wren3 = 0;
	enable = 1;

	/////////////////////////////////////////////////
	//	close
	/////////////////////////////////////////////////

	$fclose(file_in_1);
	$fclose(file_in_2);

end

always @(X, posedge D) begin
	if(D) begin
		#1 // wait color data be stable
		$fwrite(file_out, "%c%c%c", B, G, R);
	end else if(Y >= max_y && X >= max_x) begin
		#10
		$fclose(file_out);
		$stop();
	end
end


endmodule
