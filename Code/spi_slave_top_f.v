module top;
  parameter ADDR_width = 8;
  bit clk ;
  /*bit rst_n;
  bit mosi;
  bit ss_n;
  bit miso;
  bit rx_valid;
  bit tx_valid;
  bit [ADDR_width+1:0] rx_data;
  bit [ADDR_width-1:0] tx_data;*/
  always #5 clk = ~clk;
  
  spi_slave_io i1 (clk);
  spi_slave_tb t1 (i1.TB,clk);		
  spi_slave d1 (i1.DUT);
  
  
  initial
    begin
      $dumpfile("test.vcd");
      $dumpvars;
      #1000000 $finish;
    end
  
  
endmodule

