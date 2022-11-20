module reader_tb;

reg clk = 0;
always #1 clk = ~clk;

reg [0:53][7:0] header  = '{
	8'h42, 8'h4D, 8'h36, 8'h10, 8'h0E, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h36, 8'h00,
	8'h00, 8'h00, 8'h28, 8'h00, 8'h00, 8'h00, 8'h80, 8'h02, 8'h00, 8'h00, 8'hE0, 8'h01,
	8'h00, 8'h00, 8'h01, 8'h00, 8'h18, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h10,
	8'h0E, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00,
	8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00
};

localparam  [9:0] x = 640;
localparam  [9:0] y = 480;

localparam  [9:0] min_x = 64;
localparam  [9:0] min_y = 16;
localparam  [9:0] max_x = x + min_x - 1;
localparam  [9:0] max_y = y + min_y - 1;

integer i = 0;
integer m = 0;

integer file_out_1;
integer file_out_2;
integer file_in_1;
integer file_in_2;

reg [64*8-1:0] fileName_out_1 = "vga_out_1.bmp";
reg [64*8-1:0] fileName_out_2 = "vga_out_2.bmp";
reg [64*8-1:0] fileName_in_1  = "vga_in_1.bmp";
reg [64*8-1:0] fileName_in_2  = "vga_in_2.bmp";

reg [0:x*y*3-1][7:0] data1 = 8'h00;
reg [0:x*y*3-1][7:0] data2 = 8'h00;

reg [31:0] totalSize1  = 0;
reg [31:0] dataSize1   = 0;
reg [31:0] headerSize1 = 0;

reg [31:0] totalSize2  = 0;
reg [31:0] dataSize2   = 0;
reg [31:0] headerSize2 = 0;

initial begin

	/////////////////////////////////////////////////
	//	input 1
	/////////////////////////////////////////////////

	file_in_1 = $fopen(fileName_in_1, "rb");
	if (!file_in_1) begin
		$error("File could not be open: ", file_in_1);
		$stop();
	end
	
	$fseek(file_in_1, 2, 0);
	$fread(totalSize1, file_in_1);
	totalSize1 = {<<8{totalSize1}};
	
	$fseek(file_in_1, 10, 0);
	$fread(headerSize1, file_in_1);
	headerSize1 = {<<8{headerSize1}};
	
	dataSize1 = totalSize1 - headerSize1;
	
	$fseek(file_in_1, headerSize1, 0);
	for(i = 0; i < dataSize1; i = i + 1) begin
		$fscanf(file_in_1,"%c", data1[i]);
	end

	/////////////////////////////////////////////////
	//	input 2
	/////////////////////////////////////////////////

	file_in_2 = $fopen(fileName_in_2, "rb");
	if (!file_in_2) begin
		$error("File could not be open: ", file_in_2);
		$stop();
	end
	
	$fseek(file_in_2, 2, 0);
	$fread(totalSize2, file_in_2);
	totalSize2 = {<<8{totalSize2}};
	
	$fseek(file_in_2, 10, 0);
	$fread(headerSize2, file_in_2);
	headerSize2 = {<<8{headerSize2}};
	
	dataSize2 = totalSize2 - headerSize2;
	
	$fseek(file_in_2, headerSize2, 0);
	for(i = 0; i < dataSize2; i = i + 1) begin
		$fscanf(file_in_2,"%c", data2[i]);
	end
	
	/////////////////////////////////////////////////
	//	minimum
	/////////////////////////////////////////////////
	
	m = (dataSize1 < dataSize2) ? dataSize1 : dataSize2;
	
	/////////////////////////////////////////////////
	//	output 1
	/////////////////////////////////////////////////

	file_out_1 = $fopen(fileName_out_1, "wb"); 
	if (!file_out_1) begin
		$error("File could not be open: ", fileName_out_1);
		$stop();
	end
	
	for(i = 0; i < 54; i = i + 1) begin
		$fwrite(file_out_1, "%c", header[i]);
	end
	
	for(i = 0; i < m; i = i + 1) begin
		$fwrite(file_out_1, "%c", (data1[i] != data2[i]) ? data1[i] : 8'h80);
	end
	
	/////////////////////////////////////////////////
	//	output 2
	/////////////////////////////////////////////////

	file_out_2 = $fopen(fileName_out_2, "wb"); 
	if (!file_out_2) begin
		$error("File could not be open: ", fileName_out_2);
		$stop();
	end
	
	for(i = 0; i < 54; i = i + 1) begin
		$fwrite(file_out_2, "%c", header[i]);
	end
	
	for(i = 0; i < m; i = i + 1) begin
		$fwrite(file_out_2, "%c", (data2[i] != data1[i]) ? data2[i] : 8'h80);
	end
	
	/////////////////////////////////////////////////
	//	close
	/////////////////////////////////////////////////
	
	$fclose(file_out_1);
	$fclose(file_out_2);
	$fclose(file_in_1);
	$fclose(file_in_2);

end


endmodule
