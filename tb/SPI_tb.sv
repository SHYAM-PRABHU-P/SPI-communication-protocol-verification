`timescale 1ns/1ps
// Code your testbench here
// or browse Examples

/////////////////////////////
class transaction;
  
  randc bit [7:0] din;
  bit newd;
  bit [7:0] dout;
  
  function transaction copy();
    copy = new();
    copy.din = this.din;
    copy.newd = this.newd;
    copy.dout = this.dout;
  endfunction
  
  function void display();
    $display("");
  endfunction
  
endclass
////////////////////////////////////////////
class generator;
  transaction tg;
  mailbox #(transaction) mbx;
  event next,done;
  
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
    tg = new();
  endfunction
  
  task run();
  	for(int i=0; i<=7; i++) begin
    	assert(tg.randomize) else $error("Randomize Failed");
    	mbx.put(tg.copy);  
    	@(next);
  	end
  	-> done;
  endtask
  
endclass
////////////////////////////////////
class driver;
  virtual SPI_vi si; 
  mailbox #(transaction) mbx;
  mailbox #(bit[7:0]) mbx_ds;
  transaction td;
  
  //bit[7:0] din;
  
  function new(mailbox #(transaction) mbx,mailbox #(bit[7:0]) mbx_ds);
    this.mbx = mbx;
    this.mbx_ds = mbx_ds;
  endfunction
  
  task reset;
    @(posedge si.clk);
    si.rst <= 1'b1;
    si.newd <= 1'b0;
    si.din <= 7'b0;
    repeat(3) @(posedge si.clk);
    si.rst <= 1'b0;
  endtask
  
  task run;
    forever begin
      mbx.get(td);
      si.newd <= 1;
      si.din <= td.din;
      mbx_ds.put(td.din);
      @(posedge si.sclk);   ///// assign the "design sclk" with "interface sclk"
      si.newd <= 0;
      @(posedge si.done); 
      $display("[DRV] %0d", td.din);
      @(posedge si.sclk);
    end
    
  endtask
  
  
endclass
/////////////////////////////////////
class monitor;
  virtual SPI_vi si;
  mailbox #(bit[7:0]) mbx;
  transaction tm;
  
  function new(mailbox #(bit[7:0]) mbx);
    this.mbx = mbx;
    //tm = new();
  endfunction
  
  task run;
    tm = new();
    forever begin;
      
      @(posedge si.sclk);			///////////////////////////// 1
      @(posedge si.done);
      tm.dout = si.dout;
      @(posedge si.sclk);
      mbx.put(tm.dout);
    end
    
  endtask
  
  
endclass
//////////////////////////////////////////
class scoreboard;
  mailbox #(bit[7:0]) mbx;
  mailbox #(bit[7:0]) mbx_ds;
 
  event next;
  bit [7:0] ds;
  bit [7:0] ms;
  int i=1;
  
  function new(mailbox #(bit[7:0]) mbx,mailbox #(bit[7:0]) mbx_ds);
    this.mbx = mbx;
    this.mbx_ds = mbx_ds;
  endfunction
  
  task run;
    forever begin
      mbx.get(ms);
      mbx_ds.get(ds);
      
      if(ms == ds) begin 
        $display(" %0d DATA MATCHED",i);
        i++;
      end
      else begin
        $display(" %0d DATA MISMATCHED",i);
        i++;
      end
      
      -> next;
    end
  endtask
  
endclass
//////////////////////////////////////////
class environment;
  generator g;
  driver d;
  monitor m;
  scoreboard s;
  
  event next;
  event done;
  
  mailbox #(transaction) mbx_gd;
  mailbox #(bit[7:0]) mbx_ms;
  mailbox #(bit[7:0]) mbx_ds;
  
  virtual SPI_vi si;
  
  function new(virtual SPI_vi si);
    mbx_gd = new();
    mbx_ms = new();
    mbx_ds = new();
    
    g = new(mbx_gd);
    d = new(mbx_gd,mbx_ds);
    m = new(mbx_ms);
    s = new(mbx_ms,mbx_ds);
    
    this.si = si;
    d.si = this.si;/////
    m.si = this.si;/////
    g.next = next;
    s.next = next;
    g.done = done;
    
  endfunction
  
  task preset();
    d.reset;
  endtask
  
  task set();
    fork
    	g.run;
    	d.run;
    	m.run;
    	s.run;
    join_any
  endtask
  
  task postset;
    wait(done.triggered);
    $finish();
  endtask
  
  
  task run;
    preset;
    set;
    postset;
  endtask
    
endclass
//////////////////////////////////////////////
module tb;
  SPI_vi si();
  SPI dut_3 (si.clk,si.rst,si.newd,si.din,si.dout,si.done);
  assign si.sclk = dut_3.dut_2.sclk;
  
  initial begin
    si.clk <= 0;
  end
  
  always #10 si.clk <= ~ si.clk;
  
  environment e;
  
  initial begin
    e = new(si);
    e.run();
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
  
endmodule
