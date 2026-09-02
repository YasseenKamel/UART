module parallel_to_serial #(parameter int DATA_W = 8)(
    input logic clk, rst, load, shift_en,
    input logic [DATA_W-1:0] parallel_in,
    output logic serial_out, data_done
);

    logic [DATA_W-1:0] shift_reg;
    logic [$clog2(DATA_W)-1:0] count;
    
    assign serial_out = shift_reg[0];
    assign data_done = (count == (DATA_W - 1));

    always_ff @(posedge clk or negedge rst) begin
        if (~rst) begin
            shift_reg <= '0;
            count <= '0;
        end
        else if (load) begin
            shift_reg <= parallel_in;
            count <= '0;
        end
        else if (shift_en) begin
            shift_reg <= {1'b0, shift_reg[DATA_W-1:1]};
            if (count != (DATA_W - 1)) begin
                count <= count + 1'b1;
            end
        end
        else begin
            count <= '0;
        end
    end
endmodule