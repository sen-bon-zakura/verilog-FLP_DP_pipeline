`timescale 1ns/1ps
`define CYCLE 5.0
`define DATA_NUM 1000
`define PIPE 4
`define FILE_X1 "../x1.txt"
`define FILE_X2 "../x2.txt"
`define FILE_X3 "../x3.txt"
`define FILE_X4 "../x4.txt"
`define FILE_Y1 "../y1.txt"
`define FILE_Y2 "../y2.txt"
`define FILE_Y3 "../y3.txt"
`define FILE_Y4 "../y4.txt"
`define FILE_Z  "../z32.txt"
`define FILE_ANS"../ans.txt"

//`define FILE_X1 "../x1.txt"
//`define FILE_X2 "../x2.txt"
//`define FILE_X3 "../x3.txt"
//`define FILE_X4 "../x4.txt"
//`define FILE_Y1 "../y1.txt"
//`define FILE_Y2 "../y2.txt"
//`define FILE_Y3 "../y3.txt"
//`define FILE_Y4 "../y4.txt"
//`define FILE_Z  "../z16.txt"
//`define FILE_ANS"../ans.txt"
`define FLP_DP_pipe
module testbench1();
    integer file_x1,file_x2,file_x3,file_x4,file_y1,file_y2,file_y3,file_y4,file_ans,file_z;
    reg CLK = 0;
    reg RST = 0;
    reg [31:0] x1 [0:`DATA_NUM-1];
    reg [31:0] x2 [0:`DATA_NUM-1];
    reg [31:0] x3 [0:`DATA_NUM-1];
    reg [31:0] x4 [0:`DATA_NUM-1];
    reg [31:0] y1 [0:`DATA_NUM-1];
    reg [31:0] y2 [0:`DATA_NUM-1];
    reg [31:0] y3 [0:`DATA_NUM-1];
    reg [31:0] y4 [0:`DATA_NUM-1];
    reg [31:0] z [0:`DATA_NUM-1];
    reg  [31:0] input_x1,input_x2,input_x3,input_x4;
    reg  [31:0] input_y1,input_y2,input_y3,input_y4,output_z;
    reg  [31:0] answer;
    wire [31:0] outcome;
    FLP_DP_pipe FLP_DP_pipe(.clk(CLK),.rst(RST),.x1(input_x1),.x2(input_x2),.x3(input_x3),.x4(input_x4),.y1(input_y1),.y2(input_y2),.y3(input_y3),.y4(input_y4),.z(outcome));
    real real_ans, real_outcome, real_error, total_error;

    `ifdef SDF_FILE
        initial $sdf_annotate("/home/M133040119_ALU/dc_out_file/FLP_DP_4/delay/FLP_DP_pipe.sdf", FLP_DP_pipe);
    `endif

    initial begin
        $dumpvars();
        $dumpfile("FLP_DP_pipe_wave.vcd");
       $sdf_annotate("/home/M133040119_ALU/dc_out_file/FLP_DP_4/delay/FLP_DP_pipe.sdf",FLP_DP_pipe);
    end
    always begin #(`CYCLE/2) CLK = ~CLK; end

    integer i, flag=0, error=0, garbage;
    initial 
    begin
        file_x1     = $fopen(   `FILE_X1 , "r");
        file_x2     = $fopen(   `FILE_X2 , "r");
        file_x3     = $fopen(   `FILE_X3 , "r");
        file_x4     = $fopen(   `FILE_X4 , "r");
        file_y1     = $fopen(   `FILE_Y1 , "r");
        file_y2     = $fopen(   `FILE_Y2 , "r");
        file_y3     = $fopen(   `FILE_Y3 , "r");
        file_y4     = $fopen(   `FILE_Y4 , "r");
        file_z      = $fopen(   `FILE_Z  , "r");
        file_ans    = $fopen(   `FILE_ANS, "w");
        for(i=0; i<`DATA_NUM; i=i+1)
        begin
            garbage = $fscanf(file_x1, "%X",x1[i]);
            garbage = $fscanf(file_x2, "%X",x2[i]);
            garbage = $fscanf(file_x3, "%X",x3[i]);
            garbage = $fscanf(file_x4, "%X",x4[i]);
            garbage = $fscanf(file_y1, "%X",y1[i]);
            garbage = $fscanf(file_y2, "%X",y2[i]);
            garbage = $fscanf(file_y3, "%X",y3[i]);
            garbage = $fscanf(file_y4, "%X",y4[i]);
            garbage = $fscanf(file_z, "%X",z[i]);
            
        end
    end
    
    initial 
    begin
        $display("-----------------------------------------\n");
        $display("-              FLP_DP_pipe              -\n");
        $display("-----------------------------------------\n");
        CLK = 0;
        RST = 0;
        #(`CYCLE);
        RST = 0;
            total_error = 0;
            for(i=0; i<`DATA_NUM+`PIPE-2; i=i+1)
            begin
                if(i<`DATA_NUM) begin
                    input_x1 = x1[i];
                    input_x2 = x2[i];
                    input_x3 = x3[i];
                    input_x4 = x4[i];
                    input_y1 = y1[i];
                    input_y2 = y2[i];
                    input_y3 = y3[i];
                    input_y4 = y4[i];
                    output_z = z[i];
                end
                #(`CYCLE);
                if(i>=(`PIPE-2))
                begin
                    answer = z[i+2-`PIPE];
                    real_error = (outcome > answer) ? ((outcome - answer) / answer) : ((answer - outcome) / answer);
                    total_error = real_error*(1/(i+1.0)) + total_error*(i/(i+1.0));
                    $fwrite(file_ans, "%x\n", outcome);
                    if(real_error>1&!(outcome==answer))
                    begin
                        error = error+1;
                        if(1||flag==0)
                        begin
                            $display("-----------------------------------------\n");
                            $display("Output incorrect at #%d\n", i+1);
                            $display("The input x1 is    : %X\n", input_x1);
                            $display("The input x2 is    : %X\n", input_x2);
                            $display("The input x3 is    : %X\n", input_x3);
                            $display("The input x4 is    : %X\n", input_x4);
                            $display("The input y1 is    : %X\n", input_y1);
                            $display("The input y2 is    : %X\n", input_y2);
                            $display("The input y3 is    : %X\n", input_y3);
                            $display("The input y4 is    : %X\n", input_y4);
                            $display("The answer is     : %X\n", answer);
                            $display("Your module output: %X\n", outcome);
                            $display("?: %f\n", real_error);
                            $display("-----------------------------------------\n");
                            flag = 1;
                        end //if flag
                    end //if
                end //for
            end
            $display("-----------------------------------------\n");
            $display("Score: %3d\n", 1000-error);
            $display("Avg error: %e\n", total_error);
            $display("-----------------------------------------\n");
        $fclose(file_x1);
        $fclose(file_x2);
        $fclose(file_x3);
        $fclose(file_x4);
        $fclose(file_y1);
        $fclose(file_y2);
        $fclose(file_y3);
        $fclose(file_y4);
        $fclose(file_ans);
        $finish;
    end
endmodule
