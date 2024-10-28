class dec_predictor extends uvm_subscriber#(enc_bus_trans);

`uvm_component_utils(dec_predictor)

uvm_analysis_port #(decoder_8b10b_trans) ap;


//
// Statistics:
//
int no_transfers;
int no_tx_errors;
int no_rx_errors;
int no_cs_errors;

// running disparity for this predictor
// by default it's RD-
// 1 - RD+
// 0 - RD-
bit rd;
// transaction which holds last valid transaction
enc_bus_trans last_vld_item;

function new(string name = "", uvm_component parent = null);
    super.new(name, parent);
endfunction

extern function void build_phase(uvm_phase phase);
extern function void write(enc_bus_trans t);
extern function void report_phase(uvm_phase phase);
extern function void notify_transaction(decoder_8b10b_trans item);
endclass: dec_predictor

function void dec_predictor::build_phase(uvm_phase phase);
    last_vld_item = enc_bus_trans::type_id::create("last_vld_item");
    ap = new("ap", this);
    rd = 1'b0;
endfunction: build_phase

function void dec_predictor::write(enc_bus_trans t);
    decoder_8b10b_trans item = decoder_8b10b_trans::type_id::create("item");
    // a bunch of process here
    if (t.valid) begin
    // this transaction's data should be processed, so we update last_vld_item
        last_vld_item.copy(t);
    end else begin
    // since current transaction's data should not be processed, so we process
    // last transaction which holds valid data
    end
    decoder_8b10b_trans.data = last_vld_item.data;
    decoder_8b10b_trans.is_control_word = last_vld_item.control_word;
    notify_transaction(item);
endfunction

function void dec_predictor::notify_transaction(
    decoder_8b10b_trans item);
    ap.write(item);
endfunction : notify_transaction

function void dec_predictor::report_phase(uvm_phase phase);

    if(no_transfers == 0) begin
      `uvm_info("SPI_SB_REPORT:", "No SPI transfers took place", UVM_LOW)
    end
    if((no_cs_errors == 0) && (no_tx_errors == 0) && (no_rx_errors == 0) && 
        (no_transfers > 0)) begin
      `uvm_info("SPI_SB_REPORT:", 
          $sformatf("Test Passed - %0d transfers occured with no errors", 
          no_transfers), UVM_LOW)
      `uvm_info("** UVM TEST PASSED **", 
          $sformatf("Test Passed - %0d transfers occured with no errors", 
          no_transfers), UVM_LOW)
    end
    if(no_tx_errors > 0) begin
      `uvm_error("SPI_SB_REPORT:", 
          $sformatf("Test Failed - %0d TX errors occured during %0d transfers",
          no_tx_errors, no_transfers))
    end
    if(no_rx_errors > 0) begin
      `uvm_error("SPI_SB_REPORT:", 
          $sformatf("Test Failed - %0d RX errors occured during %0d transfers",
          no_rx_errors, no_transfers))
    end
    if(no_cs_errors > 0) begin
      `uvm_error("SPI_SB_REPORT:", 
          $sformatf("Test Failed - %0d CS errors occured during %0d transfers",
          no_cs_errors, no_transfers))
    end

endfunction: report_phase
