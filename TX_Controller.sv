typedef struct packed {
    logic [1:0] mux_sel;
    logic shift_en;
    logic load;
    logic busy;
} uart_tx_ctrl_t;

module tx_controller(
    input  logic clk, v_input, p_en, rst, data_done,
    output uart_tx_ctrl_t ctrl
);

    typedef enum logic [2:0] {
        free, start, data, parity, stop
    } state_t;

    state_t state, next_state;

    always_ff @(posedge clk or negedge rst) begin
        if(!rst) begin
            state <= free;
        end
        else begin
            state <= next_state;
        end
    end

    always_comb begin
        next_state = state;
        ctrl.busy = 1'b1;
        ctrl.shift_en = 1'b0;
        ctrl.load = 1'b0;
        ctrl.mux_sel = 2'b11;

        unique case (state)
            free: begin
                ctrl.busy = 1'b0;
                if (v_input) begin
                    next_state = start;
                    ctrl.load = 1'b1;
                end
            end
            
            start: begin
                ctrl.mux_sel = 2'b00;
                next_state = data;
            end
            
            data: begin
                ctrl.mux_sel = 2'b01;
                ctrl.shift_en = 1'b1;
                
                if (data_done) begin
                    if (p_en)
                        next_state = parity;
                    else
                        next_state = stop;
                end
            end
            
            parity: begin
                ctrl.mux_sel = 2'b10;
                next_state = stop;
            end
            
            stop: begin
                ctrl.mux_sel = 2'b11;
                next_state = free;
            end
            
            default: begin
                next_state = free;
            end
        endcase
    end
endmodule