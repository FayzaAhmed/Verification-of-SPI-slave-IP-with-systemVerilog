// Code your design here
module spi_slave #(parameter ADDR_width = 8) (spi_slave_io io);	
  
  localparam idle = 0, chk_cmd = 1, write_address = 2, write_data = 3, read_address = 4, read_dummy = 5;
  
  reg [2:0] 			current_state, next_state;
  reg [ADDR_width-1:0] 	internal_register;			
  reg [3:0] 			counter_receiver = 0;
  reg [3:0] 			counter_transmitter = 0;
  reg [1:0] 			cmd;
  reg [7:0]             temp_reg;
  
  //next state always block
  always @(posedge io.clk or negedge io.rst_n)
    begin
      if(!io.rst_n)
        begin  
          current_state <= idle;
        end
      else
        begin
          current_state <= next_state;
        end
    end
  
  //current state always block 
  always @(*)
    begin
      case(current_state)
      idle : begin
              if (!io.ss_n)
                begin
                  next_state = chk_cmd;
                end
              else
                begin
                  next_state = idle;
                end
             end
        
      chk_cmd : begin
                  if ( !io.ss_n)
                    begin
                      if(counter_receiver == 2'b00)
                        begin
                          case(cmd)
                            2'b00: next_state = write_address;
                            2'b01: next_state = write_data;
                            2'b10: next_state = read_address;
                            2'b11: next_state = read_dummy;
                            default : next_state = idle;
                          endcase
                        end
                      else
                        begin
                          next_state = chk_cmd;
                        end
                        
                    end
                  else
                    begin
                      next_state = idle;
                    end
                end


     write_address : begin
                       if(!io.ss_n)
                         begin
                           if(counter_receiver == (ADDR_width+1 ) )
                             begin
                               next_state = idle;
                             end
                           else 
                             begin
                               next_state = write_address;
                             end
                         end
                       else
                         begin
                           next_state = idle;
                         end
                     end
                 
     write_data : begin
                       if(!io.ss_n)
                         begin
                           if(counter_receiver == (ADDR_width+1 ) )
                             begin
                               next_state = idle;
                             end
                           else 
                             begin
                               next_state = write_data;
                             end
                         end
                       else
                         begin
                           next_state = idle;
                         end
                     end

        
     read_address : begin
                       if(!io.ss_n)
                         begin
                           if(counter_receiver == (ADDR_width+1 ) )
                             begin
                               next_state = idle;
                             end
                           else 
                             begin
                               next_state = read_address;
                             end
                         end
                       else
                         begin
                           next_state = idle;
                         end
                     end
     read_dummy : begin
                       if(!io.ss_n)
                         begin
                           if(counter_receiver == (ADDR_width +1) )
                             begin
                               next_state = idle;
                             end
                           else 
                             begin
                               next_state = read_dummy;
                             end
                         end
                       else
                         begin
                           next_state = idle;
                         end
                     end
     default : begin
                  next_state = idle;
     end
     endcase
    end
  
  
  always @(posedge io.clk)
    begin
      case(current_state)
      idle : begin
               io.rx_valid <= 1'b0;
               io.rx_data <= 'b0;
               internal_register <= 'b0;
               counter_receiver <= 'b0;
               cmd <= {io.mosi,cmd[1]};
      end
        
      chk_cmd : begin
        if ( !io.ss_n)
                    begin
                      counter_receiver <= counter_receiver+1;
                      cmd <= {io.mosi,cmd[1]};
                    end
                  else
                    begin
                      counter_receiver <= 'b0;
                      cmd <= 2'b0;
                    end
                end


     write_address : begin
       if (!io.ss_n)
                         begin
                           if(counter_receiver == (ADDR_width+1) )
                               begin
                                 io.rx_valid <= 1'b1;
                                 io.rx_data <= {internal_register,cmd};
                               end
                           else
                             begin
                               counter_receiver <= counter_receiver+1;
                               internal_register <= {io.mosi, internal_register[ADDR_width-1:1]};    
                             end
                         end
                       else
                         begin
                           counter_receiver <= 'b0;
                           io.rx_valid <= 'b0;
                           io.rx_data <= 'b0;
                         end
                     end
                 
     write_data :begin
       if (!io.ss_n)
                         begin
                           if(counter_receiver == (ADDR_width+1) )
                               begin
                                 io.rx_valid <= 1'b1;
                                 io.rx_data <= {internal_register,cmd};
                               end
                           else
                             begin
                               counter_receiver <= counter_receiver+1;
                               internal_register <= {io.mosi, internal_register[ADDR_width-1:1]};    
                             end
                         end
                       else
                         begin
                           counter_receiver <= 'b0;
                           io.rx_valid <= 'b0;
                           io.rx_data <= 'b0;
                         end
                     end
                 

        
     read_address : begin
       if (!io.ss_n)
                         begin
                           if(counter_receiver == (ADDR_width +1) )
                               begin
                                 io.rx_valid <= 1'b1;
                                 io.rx_data <= {internal_register,cmd};
                               end
                           else
                             begin
                               counter_receiver <= counter_receiver+1;
                               internal_register <= {io.mosi, internal_register[ADDR_width-1:1]};    
                             end
                         end
                       else
                         begin
                           counter_receiver <= 'b0;
                           io.rx_valid <= 'b0;
                           io.rx_data <= 'b0;
                         end
                     end
                 
     read_dummy : begin
                       if (!io.ss_n)
                         begin
                           if(counter_receiver == (ADDR_width+1) )
                               begin
                                 io.rx_valid <= 1'b1;
                                 io.rx_data <= {internal_register,cmd};
                               end
                           else
                             begin
                               counter_receiver <= counter_receiver+1;
                               internal_register <= {io.mosi, internal_register[ADDR_width-1:1]};    
                             end
                         end
                       else
                         begin
                           counter_receiver <= 'b0;
                           io.rx_valid <= 'b0;
                           io.rx_data <= 'b0;
                         end
                     end
               
     default : begin
                  io.rx_data <= 'b0;
                  io.rx_valid <= 1'b0;
                  counter_receiver <= 'b0;
                  internal_register <= 'b0;
     end
     
     endcase
    end
  
  
  // output always block 
  always@(posedge io.clk or negedge io.rst_n)
    begin
      
      if(!io.rst_n)
        begin
          counter_transmitter <= 'b0;
          io.miso <= 1'b0;
          temp_reg <= 8'b0;
        end
        
     else 
       begin
       if (io.tx_valid)
          begin
              temp_reg <= io.tx_data;
              counter_transmitter <= 'b0;
          end
        else 
          begin
            if(!io.ss_n)
              begin
                if (counter_transmitter != ADDR_width)
                  begin
                    io.miso <= io.tx_data[counter_transmitter];
                    counter_transmitter <= counter_transmitter+1;
                  end
                else 
                  begin
                    counter_transmitter <= 'b0;
                  end
               end
            else
              begin
                counter_transmitter <= 'b0;
              end
        end
    end
    end
  
endmodule


