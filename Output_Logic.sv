module output_logic #(parameter int DATA_W = 8)(
    input logic i_clk, i_rst_n, i_rx, expected_parity, i_par_en, par_state, stop_state,
    input logic [DATA_W-1:0] parallel_data,
    output logic [DATA_W-1:0] o_data,
    output logic o_valid, o_parity_err, o_frame_err
);

    logic actual_parity;

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (~i_rst_n) begin
            o_data <= '0;
            o_valid <= 1'b0;
            o_parity_err <= 1'b0;
            o_frame_err <= 1'b0;
        end 
        else if (par_state) begin
            actual_parity <= i_rx;
        end
        else if (stop_state && !i_rx) begin
            o_data <= parallel_data;
            o_valid <= 1'b1;
            o_parity_err <= ((actual_parity!=expected_parity)&&i_par_en);
            o_frame_err <= 1'b1;
        end 
        else if (stop_state && i_rx) begin
            o_data <= parallel_data;
            o_valid <= 1'b1;
            o_parity_err <= ((actual_parity!=expected_parity)&&i_par_en);
            o_frame_err <= 1'b0;
        end
        else begin
            o_data <= parallel_data;
            o_valid <= 1'b0;
            o_parity_err <= 1'b0;
            o_frame_err <= 1'b0;
        end
    end

endmodule