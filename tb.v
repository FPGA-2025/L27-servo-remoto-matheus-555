module tb();

localparam PERIOD = 40; // 40 ciclos de clock para 1 ciclo de PWM
localparam CLK_FREQ = 50; // 50 Hz

reg clk = 0;
reg rst_n = 0;
wire servo_out;

servo #(
    .CLK_FREQ(CLK_FREQ),
    .PERIOD(PERIOD)
) u_servo (
    .clk(clk),
    .rst_n(rst_n),
    .servo_out(servo_out)
);

always #1 clk = ~clk;

reg [7:0] high_counter;
integer i;

initial begin
    $dumpfile("saida.vcd");
    $dumpvars(0, tb);
    
    // Reset
    rst_n = 0;
    #2;
    rst_n = 1;

    #20; // espera estar no meio da forma de onda

    //
    //Teste 1: Excursão mínima
    //
    high_counter = 0;
    for (i=0; i<PERIOD; i++) begin
        if (servo_out == 1)
            high_counter = high_counter + 1;
        #2; // espera um ciclo de clock
    end

    if (high_counter == 2)
        $display("OK: Teste 1: Excursão mínima, %d ciclos de %d em nivel alto.", high_counter, PERIOD);
    else
        $display("ERRO: Teste 1: Excursão mínima, %d ciclos de %d em nível alto. Deveria ser 2 (2\/40=5%%).", high_counter, PERIOD);

    //
    //Teste 2: Excursão máxima
    //

    // Reset
    rst_n = 0;
    #2;
    rst_n = 1;

    #(5*CLK_FREQ*2); //espera por 5 segundos

    #20; // espera estar no meio da forma de onda

    high_counter = 0;
    for (i=0; i<PERIOD; i++) begin
        if (servo_out == 1)
            high_counter = high_counter + 1;
        #2; // espera um ciclo de clock
    end

    if (high_counter == 4)
        $display("OK: Teste 2: Excursão máxima, %d ciclos de %d em nivel alto.", high_counter, PERIOD);
    else
        $display("ERRO: Teste 2: Excursão máxima, %d ciclos de %d em nível alto. Deveria ser 4 (4\/40=10%%).", high_counter, PERIOD);
    $finish;
end


endmodule