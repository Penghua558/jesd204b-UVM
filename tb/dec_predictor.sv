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
// scoreboard can't detect not in table error and disparity error since it 
// doesn't has knowledge of output of DUT, so it's up to testcase to tell 
// scoreboard if the next transaction is expected to generate 
// not_in_table_error and disparity_err or not
bit not_in_table_error;
bit disparity_error;
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
    not_in_table_error = 1'b0;
    disparity_error = 1'b0;
endfunction: build_phase

function void dec_predictor::write(enc_bus_trans t);
    bit[9:0] enc_data;
    int num_ones;
    decoder_8b10b_trans item = decoder_8b10b_trans::type_id::create("item");

    if (t.valid) begin
    // this transaction's data should be processed, so we update last_vld_item
        last_vld_item.copy(t);
    end else begin
    // since current transaction's data should not be processed, so we process
    // last transaction which holds valid data
    end
    item.data = last_vld_item.data;
    item.is_control_word = last_vld_item.control_word;
    item.running_disparity = rd;
    item.not_in_table_error = not_in_table_error;
    item.disparity_error = disparity_error;

    if (item.is_control_word) begin
    // encode data as a control word
        // first we test if data is truly a control word
        if (table_8b10b_pkg::k_8b_minus.exists(item.data) ||
            table_8b10b_pkg::k_8b_plus.exists(item.data) begin
            item.k_not_valid_error = 1'b0;
        end else begin
            item.k_not_valid_error = 1'b1;
        end

        // update running disparity if data is truly a control word
        // otherwise running disparity should keep unchanged
        if (!item.k_not_valid_error) begin
            if (rd)
                enc_data = table_8b10b_pkg::k_8b_plus[item.data];
            else
                enc_data = table_8b10b_pkg::k_8b_minus[item.data];

            num_ones = 0;
            repeat(10) begin
                num_ones += enc_data[0];
                enc_data = enc_data >> 1;
            end
            if (num_ones != 5) begin
                rd = ~rd;
                `uvm_info("SCB", 
                    $sformatf("Running disparity changes from %s to %s", 
                    (rd)? "RD-":"RD+", (rd)? "RD+":"RD-"), 
                    UVM_MEDIUM)
            end
        end
    end else begin
    // encode data as a data word
        item.k_not_valid_error = 1'b0;
        // update running disparity
        if(!rd)
            enc_data = table_8b10b_pkg::d_8b_minus[item.data];
        else
            enc_data = table_8b10b_pkg::d_8b_plus[item.data];

        num_ones = 0;
        repeat(10) begin
            num_ones += enc_data[0];
            enc_data = enc_data >> 1;
        end
        if (num_ones != 5) begin
            rd = ~rd;
            `uvm_info("SCB", 
                $sformatf("Running disparity changes from %s to %s", 
                (rd)? "RD-":"RD+", (rd)? "RD+":"RD-"), 
                UVM_MEDIUM)
    end
    notify_transaction(item);
endfunction

function void dec_predictor::notify_transaction(
    decoder_8b10b_trans item);
    ap.write(item);
endfunction : notify_transaction

function void dec_predictor::report_phase(uvm_phase phase);
endfunction: report_phase
