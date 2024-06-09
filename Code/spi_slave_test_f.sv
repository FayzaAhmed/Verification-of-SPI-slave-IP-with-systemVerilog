program spi_slave_tb (spi_slave_io.TB intf, input bit clk); 

  	class rand_congf_data;
    	rand bit [9:0] data_sent;
    	rand bit [7:0] data_received;
     
      constraint sending_cmd { data_sent[1:0] == 2'b11;
      }
      
  	endclass
      
  	rand_congf_data crand;
    bit [9:0] data_sent_temp;
    bit [7:0] data_received_temp;
   
   
    assert property (@(intf.cb) intf.cb.rx_valid |-> (intf.cb.rx_data == $past(data_sent_temp,3)));
      
    assert property (@(intf.cb) intf.cb.tx_valid |-> ##11 (data_received_temp == intf.cb.tx_data));
      
    
    covergroup rx_data_cg ;
      
      coverpoint intf.cb.rx_data;
      
    endgroup
      
      
    covergroup tx_data_cg ;
      
      coverpoint intf.cb.tx_data;
      
    endgroup   
      
      
    covergroup tx_valid_cg ;
      
      coverpoint intf.cb.tx_valid;
      
    endgroup
      
      
    covergroup rx_valid_cg ;
      
      coverpoint intf.cb.rx_valid;
      
    endgroup   
        
      rx_data_cg cg1 ;
      tx_data_cg cg2 ;
      tx_valid_cg cg3 ;
      rx_valid_cg cg4 ;  
      
      
  task validate_reset ;
    intf.rst_n <= 1;
    #5
    intf.rst_n <= 0;
    #5

    assert (intf.cb.miso == 1'b0)
      $display("MISO is succesfully reseted");
    else
      $error("MISO is not successfully reseted");
    assert (intf.cb.rx_valid == 1'b0)
      $display("rx_valid is succesfully reseted");
    else
      $error("rx_valid is not successfully reseted");
    assert (intf.cb.rx_data == 'b0)
      $display("rx_data is succesfully reseted");
    else
      $error("rx_data is not successfully reseted");

    #5
    intf.rst_n <= 1;
    
  endtask
  
  
  task validate_spi_transfer(inout bit [9:0] data_sent);

    bit [3:0] counter;
    // Drive chip select low
    intf.cb.ss_n <= 0;

    repeat (10) begin
      @(intf.cb);

      if(intf.cb.rx_valid)
        begin
          cg1.sample();
        end
      cg4.sample();    
      intf.cb.mosi <= data_sent[0];
      data_sent[9:0] <= {1'b0,data_sent[9:1]};
      //$display("temp:%h",data_sent_temp);
    end
  endtask
     
   task validate_spi_sending(input bit [7:0] data_received,
                             inout bit [9:0] data_sent,
                                inout bit [7:0] data_out);

    cg3.sample();
    intf.cb.ss_n <= 1'b0;
    intf.cb.tx_valid <= 1'b0;
    
    // Drive chip select low
     
   
    intf.cb.tx_data <= data_received;
    cg2.sample();
    

     repeat(2) begin
      if(intf.cb.rx_valid)
        begin
          cg1.sample();
        end
      cg4.sample();
      @(intf.cb);
      intf.cb.mosi <= data_sent[0];
      data_out [7:0] <= {intf.cb.miso, data_out[7:1]};
      data_sent[9:0] <= {1'b0,data_sent[9:1]};
      $display("temp:%h",data_sent_temp);
       
      cg3.sample();  
     end


     repeat (8) begin
      @(intf.cb);
      if(intf.cb.rx_valid)
        begin
          cg1.sample();
        end
      cg4.sample();  
      intf.cb.mosi <= data_sent[0];
      data_sent[9:0] <= {1'b0,data_sent[9:1]};
      data_out [7:0] <= {intf.cb.miso, data_out[7:1]};
      cg3.sample();  
      $display("%h",data_out);
      //$display("temp:%h",data_sent_temp);
    end

  endtask
      
           
  initial
    begin
      
      cg1 = new();
      cg2 = new();
      cg3 = new();
      cg4 = new();
      crand = new();
      
      intf.rst_n <= 1'b1;
      intf.cb.ss_n <= 1'b1;
      validate_reset;
      #15
      
      crand.constraint_mode(0);
      
      for (int i = 0 ; i <= 130; i++)
        begin
          assert(crand.randomize())
            $display("Randomizatin Successeded: %h",crand.data_sent);
          else
            $error("Randomization Failed"); 
          data_sent_temp <= crand.data_sent;
          intf.cb.ss_n <= 1'b0;
          validate_spi_transfer(crand.data_sent);
          @(intf.cb);


        end 
      
      
    
      crand.constraint_mode(1);
      repeat(2) begin
        @(intf.cb);
      end
      intf.rst_n <= 1'b1;
      intf.cb.ss_n <= 1'b1;
      validate_reset;
      #15
   
      for (int i = 0 ; i <= 160; i++)
        begin
          assert(crand.randomize())
            $display("Randomizatin Successeded sent: %h, receive : %h",crand.data_sent,crand.data_received);
          else
            $error("Randomization Failed");
          data_sent_temp <= crand.data_sent;
          intf.cb.ss_n <= 1'b1;
          intf.cb.tx_valid <= 1'b1;
          cg3.sample();
          @(intf.cb);


          
          validate_spi_sending(crand.data_received,crand.data_sent,data_received_temp);

          
          
        end 

     
     
      
    end
  
  endprogram
    


