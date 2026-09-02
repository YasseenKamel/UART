module mux4x2(
    input logic [3:0] data,
    input logic [1:0] mux_sel,
    output logic mux_out
);

    always_comb begin
        if (mux_sel == 2'b00) begin
            mux_out = data[0];
        end
        else if (mux_sel == 2'b01) begin
            mux_out = data[1];
        end
        else if (mux_sel == 2'b10) begin
            mux_out = data[2];
        end
        else begin
            mux_out = data[3];
        end
    end

endmodule