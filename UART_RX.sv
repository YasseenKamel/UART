typedef struct packed {
    logic o_busy;
    logic shift_en;
    logic par_state;
    logic stop_state;
} uart_rx_ctrl_t;


module uart_rx #(parameter int DATA_W = 8)(
    input logic i_rx, i_clk, i_rst_n, i_par_en, i_par_odd,
    output logic [DATA_W-1:0] o_data,
    output logic o_valid, o_busy, o_parity_err, o_frame_err
);

    logic edge_out1, edge_out2, edge_out3, data_done, expected_parity;
    logic [DATA_W-1:0] data;
    uart_rx_ctrl_t ctrl_bus;

    rx_controller Controller(
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_par_en(i_par_en),
        .start_bit_edge(edge_out2),
        .data_done(data_done),
        .ctrl(ctrl_bus)
    );

    parity_calc #(.DATA_W(DATA_W)) Parity(
        .p_data(data),
        .i_par_odd(i_par_odd),
        .parity_out(expected_parity)
    );

    edge_detector Start_Bit_Detect(
        .clk(i_clk),
        .n_rst(i_rst_n),
        .A(i_rx),
        .pos_edge_A(edge_out1),
        .neg_edge_A(edge_out2),
        .edge_A(edge_out3)
    );

    deserialiser #(.DATA_W(DATA_W)) Deserialiser(
        .i_clk(i_clk), 
        .i_rst_n(i_rst_n), 
        .shift_en(ctrl_bus.shift_en), 
        .i_rx(i_rx), 
        .parallel_out(data), 
        .data_done(data_done)
    );

    output_logic #(.DATA_W(DATA_W)) Output_Logic(
        .i_clk(i_clk), 
        .i_rst_n(i_rst_n), 
        .i_rx(i_rx), 
        .expected_parity(expected_parity),
        .i_par_en(i_par_en),
        .par_state(ctrl_bus.par_state), 
        .stop_state(ctrl_bus.stop_state), 
        .parallel_data(data), 
        .o_data(o_data), 
        .o_valid(o_valid), 
        .o_parity_err(o_parity_err), 
        .o_frame_err(o_frame_err)
    );

    assign o_busy = ctrl_bus.o_busy;

endmodule