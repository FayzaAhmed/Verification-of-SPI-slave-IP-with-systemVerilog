interface spi_slave_io #(parameter ADDR_width = 8)(input bit clk) ; // Synchronus clock sent from the master
  
  bit rst_n; //Negative Edge reset 
  bit mosi;  // master output serial input
  bit miso;  // master input serial output
  bit ss_n;
  bit rx_valid;
  bit tx_valid;
  bit [ADDR_width+1:0] rx_data;
  bit [ADDR_width-1:0] tx_data;
  
  clocking cb @(posedge clk);
    
    inout mosi;
    output ss_n;
    inout tx_valid;
    inout tx_data;
    input miso;
    input rx_valid;
    input rx_data;
    
  endclocking
  
  modport TB (clocking cb , output rst_n);
  modport DUT (input clk, rst_n, mosi, ss_n, tx_valid, tx_data,output rx_valid, rx_data, miso);
  
endinterface
    
