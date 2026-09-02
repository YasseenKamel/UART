typedef struct packed {
    logic [1:0] mux_sel;
    logic shift_en;
    logic load;
    logic busy;
} uart_tx_ctrl_t;

module uart_tx #(parameter int DATA_W = 8)(
    input logic i_clk, i_rst_n, i_par_odd, i_par_en, i_valid,
    input logic [DATA_W-1:0] i_data,
    output logic o_tx, o_busy
);

    logic data_done_in, parity_out_in, serial_out_in;
    uart_tx_ctrl_t ctrl_bus;

    tx_controller Controller(
        .clk(i_clk),
        .rst(i_rst_n),
        .v_input(i_valid),
        .p_en(i_par_en),
        .data_done(data_done_in),
        .ctrl(ctrl_bus)
    );

    parity_calc #(.DATA_W(DATA_W)) Parity(
        .p_data(i_data),
        .i_par_odd(i_par_odd),
        .parity_out(parity_out_in)
    );

    parallel_to_serial #(.DATA_W(DATA_W)) Serialiser(
        .clk(i_clk),
        .rst(i_rst_n),
        .load(ctrl_bus.load),
        .shift_en(ctrl_bus.shift_en),
        .parallel_in(i_data),
        .serial_out(serial_out_in),
        .data_done(data_done_in)
    );

    mux4x2 Mux(
        .data({1'b1, parity_out_in, serial_out_in, 1'b0}),
        .mux_sel(ctrl_bus.mux_sel),
        .mux_out(o_tx)
    );

    assign o_busy = ctrl_bus.busy;

endmodule