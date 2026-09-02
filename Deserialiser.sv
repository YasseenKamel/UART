module deserialiser #(parameter int DATA_W = 8)(
    input logic i_clk, i_rst_n, shift_en, i_rx,
    output logic [DATA_W-1:0] parallel_out,
    output logic data_done
);

    logic [$clog2(DATA_W)-1:0] count;
    assign data_done = (count == (DATA_W - 1));

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (~i_rst_n) begin
            parallel_out <= {DATA_W{1'b0}};
            count <= '0;
        end 
        else if (shift_en) begin
            parallel_out <= {i_rx,parallel_out[DATA_W-1:1]};
            if (count == DATA_W-1) begin
                count <= '0;
            end 
            else begin
                count <= count + 1'b1;
            end
        end 
        else begin
            count <= '0;
        end
    end

endmodule