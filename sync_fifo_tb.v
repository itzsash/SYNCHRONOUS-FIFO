module sync_fifo_tb;

    parameter WIDTH = 8;   
    parameter DEPTH = 16;    

    reg clk;                      
    reg reset;                     
    reg wr_en;                    
    reg rd_en;                     
    reg [WIDTH-1:0] write_data; 
    wire [WIDTH-1:0] read_data; 
    wire full;                    
    wire empty;                    

    // Instantiate the synchronous FIFO
    sync_fifo #(
        .WIDTH(WIDTH),    
        .DEPTH(DEPTH)     
    ) fifo_inst (
        .clk(clk),                  
        .reset(reset),              
        .wr_en(wr_en),              
        .rd_en(rd_en),              
        .write_data(write_data),    
        .read_data(read_data),     
        .full(full),                
        .empty(empty)               
    );

    // Clock generation 
    initial begin
        clk = 0;                     
        forever #5 clk = ~clk;       // Toggle clock every 5 time units 
    end

        // Write data and Read data
        initial begin
        reset = 1;                   
        wr_en = 0;                   
        rd_en = 0;                   
        write_data = 0;             
        #10 reset = 0;              

        // Write data into FIFO
        for (integer i = 0; i < DEPTH; i = i + 1) 
        begin 
            @(posedge clk);  // Wait for the rising edge of the clock
            wr_en = 1;       // Enable write
            write_data = i;  // Assign the current loop index as write data
            @(posedge clk);  // Wait for the next clock edge
            wr_en = 0;       // Disable write 

            // Check if the FIFO is full after the last write
            if (i == DEPTH - 1) 
            begin
                @(posedge clk);
                if (full) 
                begin
                    $display("FIFO is full after writing %d", i + 1);
                end
            end
        end

        // Read data from FIFO
        for (integer i = 0; i < DEPTH; i = i + 1)
        begin
            @(posedge clk);  // Wait for the rising edge of the clock
            rd_en = 1;       // Enable read
            @(posedge clk);  // Wait for the next clock edge
            rd_en = 0;       // Disable read 
        end

        // After reading all data, check if the FIFO is empty
        @(posedge clk);
        if (empty) 
        begin              
            $display("FIFO is empty after reading all data."); 
        end

        #10 $finish;                  
    end

    initial begin
        // Display the data on the screen
        $monitor("Time: %0t | write_data: %d | read_data: %d | full: %b | empty: %b",
                 $time, write_data, read_data, full, empty);
    end
endmodule
