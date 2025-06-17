# verilog-FLP_DP_pipeline

FLP dot-product-4 (DP4) z=x1*y1+x2*y2+x3*y3+x4*y4

1. support 32-bit single-precision and 16-bit half-precision
2. 4-stage pipelining:
  stage1:unpack, fixed-point multiplication, alignment
  stage2:fixed-point addition, conversion to sign-magnitude 
  stage3:normalization
  stage4:rounding, pack
3. clock gating for un-necessary computation units
  close un-necessary DFF

system architecture:

![Capture](https://github.com/user-attachments/assets/ae056fcc-124a-4202-98ec-ba8afc3cd04c)

In my design, 
Stage 1 classifies the input data to determine whether the subsequent computation should use single-precision or half-precision.
After classification, it performs the multiplication of the significands, handles exponent-related issues, and performs alignment.
Stage 2 adds the significands and handles the sign-related operations.
Stage 3 performs normalization.
Stage 4 carries out rounding and finalizes the output value.

In terms of pipeline design, additional registers are used to store either single-precision or half-precision values. 
Clock-gating is employed to disable unnecessary D flip-flops (DFFs) and reduce power consumption.

4 stage pipeline delay:

![Capture1](https://github.com/user-attachments/assets/09684f3d-5563-48a6-aa44-f9b2074e810d)

wave for 16-bit half-precision:

![w16](https://github.com/user-attachments/assets/b97860e0-c6bf-4165-965d-eb78861c9b5a)

wave for 32-bit single-precision:

![w32](https://github.com/user-attachments/assets/ca3a2ebe-4b62-4778-ba4b-d6dbee1c8823)

Explain the error:

In this hardware design, the average error for half-precision is within an acceptable range at 0.01%, with no issues. 
For single-precision, the error is slightly higher, with an average error of 0.29%. 
The larger error mainly comes from the fact that after multiplying two single-precision numbers, the result still needs to be added to the results of three other multiplication pairs. 
In the data, some values might be significantly larger or smaller than others, which can introduce errors during alignment (shifting). 
In cases where all 4 values are involved, the accumulated error may increase further. However, the error is still within an acceptable range.

clock gating:

![gclk](https://github.com/user-attachments/assets/d23054b1-99c9-427d-9733-bc1279da2676)


