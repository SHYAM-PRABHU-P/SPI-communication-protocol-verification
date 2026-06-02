`timescale 1ns / 1ps
// Code your design here
module SPI_master(input clk,rst,
                 input newd,
                  input [7:0] din,
                 output reg sclk,mosi,cs);
  
  typedef enum bit[1:0] {idle = 2'b00 , send = 2'b11} state_type;
  
  state_type state = idle;
  
  int count;
  int countc;
  
  always @ (posedge clk) begin
    if(rst == 1) begin
      countc <= 0;
      count <= 0;
      sclk <= 0;
    end
    
    else begin
      
      if(countc < 10)
        countc <= countc + 1;
      
      else begin
        sclk <= ~sclk;
        countc <= 0;
      end
      
    end
    
  end
  
  reg [7:0] temp;
  
  always @ (posedge sclk) begin
    if(rst == 1) begin
      cs <= 1;
      mosi <= 0;
    end
    
    else begin
      case (state) 
        
        idle : begin
          
          if(newd == 1) begin
            cs <= 0;
            state <= send;
            temp <= din;
          end
          
          else begin
            state <= idle;
            temp <= 8'd0;
          end 
          
        end
        
         send : begin
           
           if(count < 8) begin
             mosi <= temp[count];
             count <= count + 1;
           end
           
           else begin
             count <= 0;
             mosi <= 0;
             cs <= 1;
             state <= idle;
           end
           
         end
          
        default : state <= idle;
        
      endcase
      
    end
    
  end
  
  
endmodule
////////////////////////////////////////////
module SPI_slave(input sclk,cs,miso,
                 output [7:0]dout,
                output reg done);
  
  typedef enum bit { str = 1'b0 , stp = 1'b1} state_type;
  state_type state = str;
  
  reg [7:0]temp =8'd0;
  int count = 0;
  
  always @(posedge sclk) begin
    
    case (state)
      
      str : begin
        
        done <= 1'b0;
        if(cs == 1'b0)
          state <= stp;
        else 
          state <= str;
      
      end
      
      stp : begin
        
        if(count < 8) begin
          temp[7:0] <= {miso,temp[7:1]};
          count <= count + 1;
        end
        
        else begin
          count <= 0;
          done <= 1'b1;
          state <= str;
        end
        
      end
      
    endcase
  end
  
  assign dout = temp;
  
endmodule
//////////////////////////////////////////
module SPI (input clk,rst,
                 input newd,
                  input [7:0] din,
                  output reg [7:0] dout,
                  output reg done);
  
  
  wire sclk,miso,cs;
  
  SPI_master dut_1(.clk(clk),.rst(rst),.newd(newd),.din(din),.sclk(sclk),.mosi(miso),.cs(cs));
  SPI_slave dut_2(.sclk(sclk),.cs(cs),.miso(miso),.dout(dout),.done(done));
  
  
endmodule
////////////////////////////////////////////////
interface SPI_vi;
  
  logic clk,rst,newd;
  logic [7:0] din;
  logic [7:0] dout;
  logic done;
  logic sclk;
  
endinterface
