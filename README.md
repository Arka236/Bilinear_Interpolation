# Bilinear Image Scaling Accelerator (RTL Implementation)

# 1. Project Overview
This project implements a hardware-based bilinear interpolation engine using Verilog RTL to resize digital images. The design scales grayscale or RGB images from a given input resolution to a user-defined output resolution using fixed-point arithmetic, avoiding floating-point operations to ensure hardware efficiency.

The architecture reads pixel data from an input image memory, computes scaled coordinates for each output pixel, and performs bilinear interpolation using the four nearest neighboring pixels. The interpolated pixel values are stored in output memory and written to a hex file after simulation.

The design was verified through behavioral simulation in Vivado, and the output image quality was evaluated using PSNR (Peak Signal-to-Noise Ratio) and SSIM (Structural Similarity Index) by comparing the hardware-generated image with a reference software implementation.

# 2. Motivation

Image scaling is a fundamental operation in:

Image processing pipelines

Video streaming

Computer vision

Embedded vision systems

GPU and display controllers

Most software libraries (OpenCV, MATLAB) perform interpolation using floating-point arithmetic. However, in hardware accelerators, floating-point operations increase resource usage and latency.

This project demonstrates how bilinear interpolation can be implemented efficiently in hardware using fixed-point arithmetic, making it suitable for FPGA or ASIC-based image processing pipelines.

# 3. Bilinear Interpolation Theory

Bilinear interpolation estimates the value of a pixel at a non-integer position by computing a weighted average of the four nearest pixels.

If the input image intensity function is:

I(x, y)

and the target coordinate is:

(x_in, y_in)

the four surrounding pixels are:

I00 = I(x0, y0)
I10 = I(x0 + 1, y0)
I01 = I(x0, y0 + 1)
I11 = I(x0 + 1, y0 + 1)

where

x0 = floor(x_in)
y0 = floor(y_in)

Define the fractional distances:

a = x_in − x0
b = y_in − y0

The bilinear interpolation formula is:

I_out =
(1−a)(1−b)*I00 +
a(1−b)*I10 +
(1−a)b*I01 +
ab*I11

Each neighboring pixel contributes proportionally based on the distance of the output coordinate from that pixel.

# 4. Image Coordinate Mapping
For image scaling, each output pixel must be mapped back to a corresponding position in the input image.

If:

W_in  = input image width
H_in  = input image height
W_out = output image width
H_out = output image height

Then the mapping is:

x_in = x_out × (W_in / W_out)
y_in = y_out × (H_in / H_out)

Since hardware cannot directly store floating-point numbers efficiently, this project converts these calculations to fixed-point arithmetic.

# 5. Fixed-Point Arithmetic Implementation
To avoid floating-point operations, the design uses Q8.8 fixed-point format.
This means:
1. 8 bits represent the integer part
2. 8 bits represent the fractional part
Instead of storing
                              x_in = 1.5
we store:
                              x_in_fp = 1.5 × 256 = 384
Thus:
                              x_in_fp = x_out × W_in × 256 / W_out
                              y_in_fp = y_out × H_in × 256 / H_out

From this value:

    Integer part:
                              x0 = x_in_fp >> 8
                              y0 = y_in_fp >> 8
    Fractional part:

                              a = x_in_fp & 255
                              b = y_in_fp & 255

This technique preserves fractional precision while using only integer operations.

# 6. Hardware Architecture

The design consists of the following logical components:

# 1. Input Image Memory
Stores the original image pixels.
                              reg [7:0] img_in [0:W_IN*H_IN-1];

Each pixel is 8-bit grayscale intensity.
Pixels are stored in row-major order.
Address calculation:
                              address = y × width + x

# 2. Output Image Memory
Stores interpolated output pixels.

                              reg [7:0] img_out [0:W_OUT*H_OUT-1];
                              
# 3. Coordinate Mapping Unit
Computes the input image coordinate corresponding to each output pixel.

                              x_in_fp = x_out * W_IN * 256 / W_OUT
                              y_in_fp = y_out * H_IN * 256 / H_OUT
# 4. Neighbor Pixel Fetch Unit
Retrieves the four surrounding pixels:

                              I00 = img_in[y0*W_IN + x0]
                              I10 = img_in[y0*W_IN + (x0+1)]
                              I01 = img_in[(y0+1)*W_IN + x0]
                              I11 = img_in[(y0+1)*W_IN + (x0+1)]
# 5. Weight Computation Unit
Weights are derived from fractional distances:

                                wa = 255 − a
                                wb = 255 − b
# 6. Bilinear Computation Unit
The interpolated value is computed as:
                            _sum = wa*wb*I00 +a*wb*I10 +wa*b*I01 +a*b*I11_
Since the weights are scaled by 256, the result must be scaled back:
                                                            pixel = sum >> 16


# 7. Output Write Unit

The final interpolated pixel is stored in output memory:

                              img_out[y_out*W_OUT + x_out] = pixel

# 7. Simulation Flow

The design is verified through Vivado behavioral simulation.
Simulation sequence:

    1.Load input image pixels from a hex file
    2.$readmemh("input.hex", img_in);
    3.Perform bilinear interpolation for each output pixel
    4.Store the computed pixels in output memory
    5.Write results to a file
    6.$writememh("output.hex", img_out);

# 8. Input and Output Format

Input images are stored as hex files.
Example:

                      0A
                      14
                      1E
                      28
                      ...

Each line represents one pixel value.
Pixels are stored row by row.

# 9. Image Quality Evaluation

To evaluate interpolation accuracy, the hardware output is compared against a software reference generated using OpenCV bilinear interpolation.

Two metrics are used:
                  *PSNR (Peak Signal-to-Noise Ratio)*

PSNR measures the difference between two images.
                                      *PSNR = 10 * log10(255² / MSE)*

                        *Higher PSNR indicates better reconstruction quality.*

Typical values:

              PSNR > 40 dB → High quality
              SSIM (Structural Similarity Index)

SSIM evaluates perceived image similarity based on structure, contrast, and luminance.

Range:
              0 → completely different
              1 → identical images

Typical good value:
                  SSIM > 0.95

# 10. Tools and Technologies
      Verilog HDL – RTL implementation
      Vivado Simulator – behavioral simulation
      Python (NumPy, OpenCV) – reference image generation
      Scikit-image – PSNR and SSIM computation

# 11. Key Features of the Design
      Fully parameterized input and output resolution
      Fixed-point arithmetic implementation
      Supports grayscale and RGB images
      Avoids floating-point operations
      Hardware-efficient bilinear interpolation  
      Simulation-driven verification pipeline

# 12. Possible Improvements
      Future enhancements may include:
      Streaming architecture for real-time processing  
      AXI interface integration
      FPGA hardware implementation
      Pipelined datapath for higher throughput
      Support for higher bit-depth images

# 13. Conclusion
This project demonstrates an efficient RTL implementation of bilinear image scaling using fixed-point arithmetic. By replacing floating-point operations with scaled integer computations, the design becomes suitable for FPGA and ASIC implementations.

The simulation results show that the hardware implementation closely matches software-based bilinear interpolation, achieving high PSNR and SSIM values.

