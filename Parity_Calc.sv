module parity_calc #(parameter int DATA_W = 8)(
    input logic [DATA_W-1:0] p_data,
    input logic i_par_odd,
    output logic parity_out
);
    assign parity_out = (^p_data) ^ i_par_odd;
endmodule