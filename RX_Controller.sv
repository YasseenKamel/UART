typedef struct packed {
    logic o_busy;
    logic shift_en;
    logic par_state;
    logic stop_state;
} uart_rx_ctrl_t;


module rx_controller(
    input logic i_clk, i_rst_n, i_par_en, start_bit_edge, data_done,
    output uart_rx_ctrl_t ctrl
);

    typedef enum logic [1:0] {
        free,data,parity,stop
    } state_t;

    state_t state, next_state;

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            state <= free;
        end
        else begin
            state <= next_state;
        end
    end

    always_comb begin
        next_state = state;
        ctrl.o_busy = 1'b1;
        ctrl.shift_en = 1'b0;
        ctrl.stop_state = 1'b0;
        ctrl.par_state = 1'b0;

        unique case (state)
            free: begin
                ctrl.o_busy = 1'b0;
                if (start_bit_edge) begin
                    next_state = data;
                end
            end
            
            data: begin
                ctrl.shift_en = 1'b1;
                
                if (data_done) begin
                    if (i_par_en)
                        next_state = parity;
                    else
                        next_state = stop;
                end
            end
            
            parity: begin
                next_state = stop;
                ctrl.par_state = 1'b1;
            end
            
            stop: begin
                ctrl.stop_state = 1'b1;
                next_state = free;
            end
            
            default: begin
                next_state = free;
            end
        endcase
    end
endmodule