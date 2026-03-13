`timescale 1ns / 1ps

module top #(
    parameter H_IN  = 500,
    parameter W_IN  = 500,
    parameter H_OUT = 1000,
    parameter W_OUT = 1000,
    parameter NO_OF_CHANNELS = 1 //grey scale=1,rgb scale=1
)(
    input  clk,
    input  reset,
    output reg done
);



reg [7:0] input_image  [0:(H_IN*W_IN*NO_OF_CHANNELS-1)];
reg [7:0] output_image [0:(H_OUT*W_OUT*NO_OF_CHANNELS-1)];

reg write_done;
//factor

localparam [31:0] SCALE_X = (W_IN << 8) / W_OUT;
localparam [31:0] SCALE_Y = (H_IN << 8) / H_OUT;

//design of fsm

localparam S_IDLE     = 0,
           S_INIT_Y   = 1,
           S_INIT_X   = 2,
           S_CALC     = 3,
           S_COMPUTE  = 4,
           S_NEXT_X   = 5,
           S_NEXT_Y   = 6,
           S_DONE     = 7;

reg [2:0] state;

reg [31:0] x_out, y_out;
reg [31:0] x_acc, y_acc;

reg [31:0] x0, y0, x1, y1;
reg [7:0] a, b;

integer c;
integer idx00, idx10, idx01, idx11;
integer out_index;

reg signed [31:0] res;



wire [31:0] x0_w = x_acc >> 8;
wire [31:0] y0_w = y_acc >> 8;


initial begin
    done = 0;
    write_done = 0;
    $readmemh("grey_input.hex", input_image);
end


always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= S_IDLE;
        done  <= 0;
        x_out <= 0;
        y_out <= 0;
        x_acc <= 0;
        y_acc <= 0;
    end
    else begin
        case(state)

        S_IDLE: begin
            state <= S_INIT_Y;
        end

        S_INIT_Y: begin
            y_out <= 0;
            y_acc <= 0;
            state <= S_INIT_X;
        end

        S_INIT_X: begin
            x_out <= 0;
            x_acc <= 0;
            state <= S_CALC;
        end

        S_CALC: begin
           
            if (x0_w >= W_IN-1) begin
                x0 <= W_IN - 2;
                x1 <= W_IN - 1; 
            end else begin
                x0 <= x0_w;
                x1 <= x0_w + 1; 
            end

           
            if (y0_w >= H_IN-1) begin
                y0 <= H_IN - 2;
                y1 <= H_IN - 1;
            end else begin
                y0 <= y0_w;
                y1 <= y0_w + 1; 
            end

            a <= x_acc[7:0]; 
            b <= y_acc[7:0];

            state <= S_COMPUTE;
        end

        S_COMPUTE: begin

            for (c = 0; c < NO_OF_CHANNELS; c = c + 1) begin

                idx00 = (y0*W_IN + x0)*NO_OF_CHANNELS + c;
                idx10 = (y0*W_IN + x1)*NO_OF_CHANNELS + c;
                idx01 = (y1*W_IN + x0)*NO_OF_CHANNELS + c;
                idx11 = (y1*W_IN + x1)*NO_OF_CHANNELS + c;

               res = ( (256-a)*(256-b)*input_image[idx00] +
               a*(256-b)*input_image[idx10] +
              (256-a)*b*input_image[idx01] +
               a*b*input_image[idx11] ) >> 16;

                if (res < 0)   res = 0;
                if (res > 255) res = 255;

                out_index = (y_out*W_OUT + x_out)*NO_OF_CHANNELS + c;
                output_image[out_index] <= res[7:0];
            end

            state <= S_NEXT_X;
        end

        S_NEXT_X: begin
            x_acc <= x_acc + SCALE_X;

            if (x_out < W_OUT-1) begin
                x_out <= x_out + 1;
                state <= S_CALC;
            end
            else begin
                state <= S_NEXT_Y;
            end
        end

        S_NEXT_Y: begin
            y_acc <= y_acc + SCALE_Y;

            if (y_out < H_OUT-1) begin
                y_out <= y_out + 1;
                state <= S_INIT_X;
            end
            else begin
                state <= S_DONE;
            end
        end

        S_DONE: begin
            done <= 1;
        end

        endcase
    end
end


integer i;
initial begin
    for (i = 0; i < H_OUT*W_OUT*NO_OF_CHANNELS; i = i + 1)
        output_image[i] = 0;
end

always @(posedge clk) begin
    if (done && !write_done) begin
        write_done <= 1;
        $writememh("get_out.hex", output_image);
        $display("HEX has been written:- ");
    end
end

endmodule
