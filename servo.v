module servo #(
    parameter CLK_FREQ = 25_000_000, // 25 MHz
    parameter PERIOD = 500_000 // 50 Hz (1/50s = 20ms, 25MHz / 50Hz = 500000 cycles)
) (
    input wire clk,
    input wire rst_n,
    output wire servo_out
);

    //insira seu código aqui
    localparam IDLE            = 2'b00;
    localparam ESCURSAO_MINIMA = 2'b01;
    localparam ESCURSAO_MAXIMA = 2'b10;

    localparam integer CLK            = CLK_FREQ-1;
    localparam integer PERIOD_PWM     = PERIOD;
    localparam TEMPO_EXCURSAO_MIN_SEG = 5;
    localparam TEMPO_EXCURSAO_MAX_SEG = 5;

    reg [31:0] count;
    reg [1:0] state, next_state;
    reg [31:0] duty;

    PWM pwm (
        .clk(clk),
        .rst_n(rst_n),
        .duty_cycle(duty),
        .period(PERIOD_PWM),
        .pwm_out(servo_out)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 0;
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always @(posedge clk) begin
        case (state) 
            IDLE: begin
                next_state = ESCURSAO_MINIMA;
            end

            ESCURSAO_MINIMA: begin
                if (count > CLK*TEMPO_EXCURSAO_MIN_SEG) begin
                    count      <= 0;
                    next_state <= ESCURSAO_MAXIMA;
                end else begin
                    count      <= count+1;
                    next_state <= ESCURSAO_MINIMA;
                end
            end

            ESCURSAO_MAXIMA: begin
                if (count > CLK*TEMPO_EXCURSAO_MAX_SEG) begin
                    count      <= 0;
                    next_state <= ESCURSAO_MINIMA;
                end else begin
                    count      <= count+1;
                    next_state <= ESCURSAO_MAXIMA;
                end
            end
        endcase
    end

    always @(*) begin
        case (state) 
            IDLE: begin
                duty <= 0;
            end

            ESCURSAO_MINIMA: begin
                duty <= ((32'd5 * PERIOD_PWM) / 32'd100);
            end

            ESCURSAO_MAXIMA: begin
                duty <= ((32'd10 * PERIOD_PWM) / 32'd100) + 2;
            end
        endcase
    end

endmodule