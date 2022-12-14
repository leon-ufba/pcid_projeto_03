module mem_tb;

reg clk = 0;
always #1 clk = ~clk;

integer i = 0;
integer m = 0;

integer file_in_1;
integer file_in_2;
integer file_out;

reg [64*8-1:0] fileName_in_1  = "mem1.hex";
reg [64*8-1:0] fileName_in_2  = "mem2.hex";
reg [64*8-1:0] fileName_out   = "vga_out.bmp";

reg [31:0] totalSize1  = 0;
reg [31:0] dataSize1   = 0;
reg [31:0] headerSize1 = 0;

reg [31:0] totalSize2  = 0;
reg [31:0] dataSize2   = 0;
reg [31:0] headerSize2 = 0;

reg [31:0] totalSize3  = 0;
reg [31:0] dataSize3   = 0;
reg [31:0] headerSize3 = 0;


wire [9:0] X;
wire [9:0] Y;
wire A, D;
wire H, V;
wire [7:0] R;
wire [7:0] G;
wire [7:0] B;

reg  enable;

reg  [3:0] address;

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
	
//	$fseek(file_in_1, 2, 0);
//	$fread(totalSize1, file_in_1);
//	totalSize1 = {<<8{totalSize1}};
//	
//	$fseek(file_in_1, 10, 0);
//	$fread(headerSize1, file_in_1);
//	headerSize1 = {<<8{headerSize1}};
//	
//	dataSize1 = totalSize1 - headerSize1;
//	
//	$fseek(file_in_1, headerSize1, 0);
	
	/////////////////////////////////////////////////
	//	input 2
	/////////////////////////////////////////////////
	
	file_in_2 = $fopen(fileName_in_2, "rb");
	if (!file_in_2) begin
		$error("File could not be open: ", file_in_2);
		$stop();
	end
	
//	$fseek(file_in_2, 2, 0);
//	$fread(totalSize2, file_in_2);
//	totalSize2 = {<<8{totalSize2}};
//	
//	$fseek(file_in_2, 10, 0);
//	$fread(headerSize2, file_in_2);
//	headerSize2 = {<<8{headerSize2}};
//	
//	dataSize2 = totalSize2 - headerSize2;
//	
//	$fseek(file_in_2, headerSize2, 0);
	
	/////////////////////////////////////////////////
	//	minimum
	/////////////////////////////////////////////////
	
//	m = (dataSize1 < dataSize2) ? dataSize1 : dataSize2;
	m = 16;
	
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
		#4
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
	

end


endmodule
