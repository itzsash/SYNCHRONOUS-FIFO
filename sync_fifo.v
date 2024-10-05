module sync_fifo #(
    parameter WIDTH = 8, // Parameter for the width of the data (8)
    parameter DEPTH = 16 // Parameter for the depth of the FIFO (16)
)
(
    input  wire clk,   // Clock signal
    input  wire reset, // Asynchronous reset signal
    input  wire wr_en, // Write enable signal
    input  wire rd_en, // Read enable signal
    input  wire [WIDTH-1:0] write_data, // Data input for writing into the FIFO
    output reg [WIDTH-1:0] read_data,   // Data output for reading from the FIFO
    output reg full,  // FIFO full 
    output reg empty  // FIFO empty
);

    // memory for the FIFO
    reg [WIDTH-1:0] fifo_mem [0:DEPTH-1]; // Array to hold FIFO data
    reg [$clog2(DEPTH)-1:0] wptr;  // Write pointer (index for writing data)
    reg [$clog2(DEPTH)-1:0] rptr;  // Read pointer (index for reading data)
    reg [DEPTH:0] count;           // Count of the number of elements in the FIFO

    // reset and FIFO operation
    always @(posedge clk or posedge reset) 
    begin
        if (reset) 
        begin  // Check for reset signal
            wptr <= 0;      // Reset write pointer to 0
            rptr <= 0;      // Reset read pointer to 0
            count <= 0;     // Reset count of elements to 0
            full <= 0;      // Set full flag to 0 (not full)
            empty <= 1;     // Set empty flag to 1 (is empty)
            read_data <= 0; //Initialize read_data to 0
        end 
        else 
        begin
            // Write operation when write enable is high and FIFO is not full
            if (wr_en && !full) 
            begin
                fifo_mem[wptr] <= write_data;  // Write data to the current write pointer location
                wptr <= wptr + 1;              // Increment write pointer
                count <= count + 1;            // Increment the count of elements
            end
            
            // Read operation when read enable is high and FIFO is not empty
            if (rd_en && !empty) 
            begin
                read_data <= fifo_mem[rptr];   // Read data from the current read pointer location
                rptr <= rptr + 1;              // Increment read pointer
                count <= count - 1;            // Decrement the count of elements
            end
  
            // Update full and empty based on the count
            full <= (count == DEPTH); // Set full flag if count equals FIFO depth
            empty <= (count == 0);    // Set empty flag if count equals 0
        end
    end
endmodule
