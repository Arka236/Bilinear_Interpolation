`timescale 1ns / 1ps

module tb;

reg clk = 0;
reg reset = 1;
wire done;

// Clock generation 
always #5 clk = ~clk;

top uut (
    .clk(clk),
    .reset(reset),
    .done(done)
);

initial begin

    #20 reset = 0;

    // Wait for completion
    wait(done);


    #100;
    $finish;
end

endmodule
