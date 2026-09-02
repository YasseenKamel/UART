module edge_detector (
    input logic clk,n_rst,A,
    output logic pos_edge_A,neg_edge_A,edge_A
);

    logic old;

    always_ff @(posedge clk or negedge n_rst) begin
        if (!n_rst) begin
            old <= 1'b1; 
        end
        else begin
            old <= A;
        end
    end

    assign pos_edge_A = A & ~old;
    assign neg_edge_A = ~A & old;
    assign edge_A = A ^ old;

endmodule