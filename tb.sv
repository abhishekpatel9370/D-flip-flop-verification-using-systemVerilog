// Code your testbench here
// or browse Examples

class transaction ;
rand bit din ; 
bit dout ;

function transaction copy();
copy=new() ;
copy.din = this.din ;
copy.dout = this.dout ;
endfunction 

function void display(input string tag) ;
$display("[%0s]:Din :%0b Dout%0b  ", tag,din ,dout);
endfunction 

endclass 

class generator ; 
transaction tr ;
mailbox #(transaction) mbx ; // send data to the driver 
mailbox #(transaction) mbxref ; // send data to golden data to scoreboard 

event sconext ;
event done ;

int count ; 

function new (mailbox #(transaction)  mbx , mbxref);
this.mbx = mbx ;
this.mbxref=mbxref ;
tr=new() ;
endfunction 

task run() ;
repeat(count) begin 
assert(tr.randomize) else $error("[GEN] : RANDOMIZATION FAILED");
mbx.put(tr.copy) ;
mbxref.put(tr.copy);
tr.display("GEN") ;
@(sconext);
end
-> done ;
endtask 
endclass 

///////////////////////////

class driver ; 
transaction tr ;
mailbox #(transaction) mbx  ;
virtual dff_if vif ;

function new(mailbox #(transaction) mbx);
this.mbx=mbx ;
endfunction 

task reset();
vif.rst<=1 ; 
repeat(5) @(posedge vif.clk) ;
vif.rst<=1'b0 ;
@(posedge vif.clk) ;
$display("[DRV] : RESET DONNE") ;
endtask

task run() ;
forever begin 
mbx.get(tr) ;
vif.din<=tr.din ;
@(posedge vif.clk) ;
tr.display("DRV") ; 
vif.din<=1'b0 ;
@(posedge vif.clk) ; 
end
endtask 
endclass

/////////////////////////

class monitor  ;
transaction tr ;
mailbox #(transaction) mbx ; 
virtual dff_if vif ;
function new(mailbox #(transaction) mbx);
this.mbx=mbx ;
endfunction 

task run() ;
tr=new() ;
forever begin 
repeat(2) @(posedge vif.clk) ;
tr.dout=vif.dout ;
mbx.put(tr);
tr.display("MON");
end 
endtask 
endclass 

class scoreboard ; 
transaction tr ;
transaction trref ;

mailbox #(transaction) mbx ;
mailbox #(transaction) mbxref ;
event sconext ;

 function new(mailbox #(transaction) mbx, mailbox #(transaction) mbxref);
this.mbx = mbx; // Initialize the mailbox for receiving data from the driver
this.mbxref = mbxref; // Initialize the mailbox for receiving reference data from the generator
endfunction 

task run() ;
forever begin 
mbx.get(tr);
mbxref.get(trref) ; 
tr.display("SOC") ;
trref.display("REF") ;
if(tr.dout==trref.din)
$display("[SOC] : DATA MATCHED") ;
else 
$error("[SOC] : DATA MISMATCHED");
$display("-------------------------------------------------");
  ->sconext ;
end
endtask 
endclass

class environment ; 
generator gen ;
driver div ;
monitor mon ;
scoreboard sco ;
event next ;

mailbox #(transaction) gdmbx ; // between generator and driver ;
mailbox #(transaction) msmbx ; // between monitor and scoreboard ;
mailbox #(transaction) mbref ; // between generator and scoreboard ;

virtual dff_if vif ;

function new(virtual dff_if vif);
gdmbx =new() ;
mbref=new() ;
gen=new(gdmbx,mbref) ;
div=new(gdmbx) ;
msmbx=new() ;

mon=new(msmbx) ;
sco=new(msmbx,mbref);

this.vif=vif ;
div.vif=this.vif ;
mon.vif=this.vif ;
gen.sconext=next ;
sco.sconext = next;
endfunction 

task pre_test() ;
div.reset() ;
endtask 
task test() ;
fork
gen.run() ;
div.run() ;
mon.run() ;
sco.run() ;
join_any 
endtask 

task post_test() ;
wait(gen.done.triggered) ;
$finish();
endtask 

task run() ;
pre_test();
test();
post_test();
endtask 
endclass

///////////////

module tb ;
 dff_if vif();
top dut(vif);

environment env ;
initial begin 
vif.clk=0 ;
end
always #10 vif.clk = ~vif.clk;


initial begin
env=new(vif) ;
env.gen.count=30 ;
env.run() ;
end

initial begin
    $dumpfile("dump.vcd"); // Specify the VCD dump file
    $dumpvars; // Dump all variables
  end
endmodule

