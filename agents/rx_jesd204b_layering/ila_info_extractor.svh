import global_dec::*;
class ila_info_extractor;
// extract information from ILA sequence

// length of ILA sequence, unit is number of multiframes, by default it's 4
const int ila_length;
// number of octets in link configuraion data, it is always 14 octets
const int size_conf_data_in_octets;
// 1 - ILA's beginning symbol R(K28.0) has been detected and fed into buffer
// 0 - no ILA's beginning symbol R(K28.0) has been detected
protected bit ila_start_detected;
// 1 - end of ILA detected
// 0 - end of ILA not detected or currently not processing an ILA
protected bit ila_end_detected;
// current number of multiframe in ILA, starts from 0
protected int no_multiframe;
// current number of octet in a multiframe, starts from 0
protected int no_octet;
protected int octet_value;
// current octet number in configuraion data field
protected byte no_octet_conf;
// 1 - expect next octet is the start of a multiframe
// 0 - does not expect so
protected bit expect_start_multiframe;

// number of octets per frame, aka parameter F
int num_octets_per_frame;
// number of frames per multiframe, aka parameter K
int num_frames_per_multiframe;



//------------------------------------------
// Link Configuraion Data Fields
//------------------------------------------
// Device identification no. 0..255
bit [7:0] DID;
// Bank ID, extesion of DID, 0..15
bit [3:0] BID;
// Number of adjustment resolution steps to adjust DAC LMFC.
// In this agent, it is the number of frame clocks, 0..15
// Applies to Subclass 2 only
bit [3:0] ADJCNT;
// Lane identification number(within link), 0..31
bit [4:0] LID;
// phase adjustment request to DAC Subclass 2 only
bit PHADJ;
// Direction to adjust DAC LMFC
// 0 - Advance
// 1 - Delay
// Applies to Subclass 2 operation only
bit ADJDIR;
// No. of lanes per converter device (link), 0..31
bit [4:0] L;
// Scrambling enabled
bit SCR;
// No. of octets per frame, 0..255
bit [7:0] F;
// No. of frames per multiframe, 0..31
bit [4:0] K;
// No. of converters per device, 0..255
bit [7:0] M;
// Converter resolution, 0..31
bit [4:0] N;
// No. of control bits per sample, 0..3
bit [1:0] CS;
// Total no. of bits per sample, 0..31
bit [4:0] N_apostrophe;
// Device Subclass Version
// 000 – Subclass 0
// 001 – Subclass 1
// 010 – Subclass 2
bit [2:0] SUBCLASSV;
// No. of samples per converter per frame cycle, 0..31
bit [4:0] S;
// JESD204 version
// 000 – JESD204A
// 001 – JESD204B
bit [2:0] JESDV;
// No. of control words per frame clock period per link, 0..31
bit [4:0] CF;
// High Density format
bit HD;
// Reserved field 1
bit [7:0] RES1;
// Reserved field 1
bit [7:0] RES2;
// Checksum Σ(all above fields)mod 256
bit [7:0] FCHK;



function new(int size, int RBD);
    this.ila_start_detected = 1'b0;
    this.ila_end_detected = 1'b0;
    this.ila_length = 4;
    this.size_conf_data_in_octets = 14;
    this.no_octet_conf = 0;
endfunction


extern function void configure(int F, int K);
extern function bit is_processing_ila();
extern function bit is_start_multiframe(byte octet, bit is_ctrl_word);
extern function bit is_end_ila(byte octet, bit is_ctrl_word);
extern function bit is_end_multiframe(byte octet, bit is_ctrl_word);
extern function bit test_octet_before_conf_data(byte octet, bit is_ctrl_word);
extern function void store_conf_data(byte octet, bit is_ctrl_word);
extern function bit is_checksum_correct();
extern function bit is_processing_conf_data();
extern function bit is_octetvalue_correct(byte octet, bit is_ctrl_word);
extern function void extract_ila_info(erb_trans frame);
extern function void process_single_octet(byte octet, bit is_ctrl_word);
extern function void print_conf_data();

endclass


function void ila_info_extractor::configure(int F, int K);
// this function should be used prior of testing ILA, and should be used again
// once all ILA info has been extracted
    this.num_octets_per_frame = F;
    this.num_frames_per_multiframe = K;
endfunction


function bit ila_info_extractor::is_processing_ila();
// returns 1 if the object is extracting information from an incoming ILA
// returns 0 if noi ILA detected at the moment
    return (ila_start_detected && !ila_end_detected);
endfunction


function void ila_info_extractor::process_single_octet(
    byte octet, bit is_ctrl_word);
// identify the ILA and extract info from a given octet
    if (!is_processing_ila()) begin
        //test for start of ILA
        if (is_start_multiframe(octet, is_ctrl_word)) begin
            `uvm_info("ILA Extractor", "Start of ILA detected", UVM_LOW)
            this.ila_start_detected = 1'b1;
            this.ila_end_detected = 1'b0;
            this.no_multiframe = 0;
            this.no_octet = 1;
            this.octet_value = 1;
            this.no_octet_conf = 0;
        end
    end else begin
        if (is_end_ila(octet, is_ctrl_word)) begin
            `uvm_info("ILA Extractor", "End of ILA detected", UVM_LOW)
            this.ila_end_detected = 1;
            return;
        end

        if (is_end_multiframe(octet, is_ctrl_word)) begin
            // expect next octet(start of a multiframe) is R
            this.expect_start_multiframe = 1'b1;
            this.no_octet = 0;
            this.octet_value = (this.octet_value+1) % 256;
            return;
        end

        if (is_start_multiframe(octet, is_ctrl_word)) begin
            if (!this.expect_start_multiframe) begin
                `uvm_fatal("ILA Extractor", 
                    "Start of a multiframe detected without \
                    detecting end of a multiframe")
            end else begin
                this.expect_start_multiframe = 1'b0;
                this.no_multiframe++;
                this.no_octet++;
                this.octet_value = (this.octet_value+1) % 256;
                return;
            end
        end

        if (test_octet_before_conf_data(octet, is_ctrl_word)) begin
            this.no_octet++;
            this.octet_value = (this.octet_value+1) % 256;
            return;
        end

        if (is_processing_conf_data()) begin
            store_conf_data(octet, is_ctrl_word);
            if (this.no_octet_conf == this.size_conf_data_in_octets) begin
            // having extracted all link Configuraion data, test FCHK
            // field
                print_conf_data();
                if (!is_checksum_correct())
                    `uvm_fatal("ILA Extractor", 
                        $sformatf("Incorrect checksum in ILA! FCHK: %h", 
                        this.FCHK))
                else
                    `uvm_info("ILA Extractor", 
                        "Successfully extracted link configuraion data", 
                        UVM_LOW)
            end
            this.no_octet++;
            this.octet_value = (this.octet_value+1) % 256;
            return;
        end

        if (!is_octetvalue_correct(octet, is_ctrl_word)) begin
            `uvm_fatal("ILA Extractor", 
                $sformatf("Wrong octetValue in ILA! Expected octetValue: %0d, \
                actual octetValue: %0d", octet_value, octet))
        end

        this.no_octet++;
        this.octet_value = (this.octet_value+1) % 256;
    end
endfunction


function bit ila_info_extractor::is_processing_conf_data();
// test if we are extracting information from configuraion data field
// the configuraion data fields starts from 3rd octet of 2nd multiframe
// returns 1 if it's true
// returns 0 if it's not
    return ((this.no_multiframe == 1 && this.no_octet >= 2) || 
        (this.no_multiframe > 1)) &&
        (this.no_octet_conf < this.size_conf_data_in_octets);
endfunction


function bit ila_info_extractor::is_checksum_correct();
// test checksum in link configuraion data
// returns 1 if checksum is correct
// returns 0 if checksum is wrong
// checksum = Σ(all above fields) mod 256
    int actual_checksum = 0;
    actual_checksum += this.DID;
    actual_checksum += this.BID;
    actual_checksum += this.ADJCNT;
    actual_checksum += this.LID;
    actual_checksum += this.PHADJ;
    actual_checksum += this.ADJDIR;
    actual_checksum += this.L;
    actual_checksum += this.SCR;
    actual_checksum += this.F;
    actual_checksum += this.K;
    actual_checksum += this.M;
    actual_checksum += this.N;
    actual_checksum += this.CS;
    actual_checksum += this.N_apostrophe;
    actual_checksum += this.SUBCLASSV;
    actual_checksum += this.S;
    actual_checksum += this.JESDV;
    actual_checksum += this.CF;
    actual_checksum += this.HD;
    actual_checksum += this.RES1;
    actual_checksum += this.RES2;
    actual_checksum %= 256; 

    return (actual_checksum == this.FCHK);
endfunction


function void ila_info_extractor::store_conf_data(byte octet, bit is_ctrl_word);
    if (this.no_multiframe == 1 && this.no_octet == 2) begin
        // test start of link configuraion data and mark the current
        // processing number of octet as 0
        this.no_octet_conf = 0;
    end

    case(this.no_octet_conf)
        0: this.DID = octet;
        1: begin 
            this.BID = octet[3:0];
            this.ADJCNT = octet[7:4];
        end
        2: begin
            this.LID = octet[4:0];
            this.PHADJ = octet[5];
            this.ADJDIR = octet[6];
        end
        3: begin
            this.L = octet[4:0];
            this.SCR = octet[7];
        end
        4: this.F = octet;
        5: this.K = octet[4:0];
        6: this.M = octet;
        7: begin
            this.N = octet[4:0];
            this.CS = octet[7:6];
        end
        8: begin
            this.N_apostrophe = octet[4:0];
            this.SUBCLASSV = octet[7:5]
        end
        9: begin
            this.S = octet[4:0];
            this.JESDV = octet[7:5];
        end
        10: begin
            this.CF = octet[4:0];
            this.HD = octet[7];
        end
        11: this.RES1 = octet;
        12: this.RES2 = octet;
        13: this.FCHK = octet;
    endcase

    no_octet_conf++;
endfunction


function bit ila_info_extractor::test_octet_before_conf_data(
    byte octet, bit is_ctrl_word);
// test for extra confirmation that link configuraion data is just
// about to be received
// returns 1 if 2nd octet of 2nd multiframe is the K28.4
// returns 0 if the testing octet is not 2nd octet of 2nd multiframe
// reports UVM_FATAL if the testing octet is 2nd octet of 2nd multiframe but
// is not K28.4
        if (this.no_multiframe == 1 && this.no_octet == 1) begin
            if (is_ctrl_word && octet == global_dec::K28_4) begin
                this.no_octet++;
                this.octet_value = (this.octet_value+1) % 256;
                return 1;
            end else
                `uvm_fatal("ILA Extractor", "Failed to receive K28.4\
                at 2nd octet of 2nd multiframe during ILA")
        end
    return 0;
endfunction


function bit ila_info_extractor::is_start_multiframe(
    byte octet, bit is_ctrl_word);
// returns 1 if the octet(the first octet sent out from transmitter) is
// the start of ILA
// returns 0 if the octet is not the start of ILA
    return (is_ctrl_word && octet == global_dec::R);
endfunction


function bit ila_info_extractor::is_end_multiframe(
    byte octet, bit is_ctrl_word);
// returns 1 if the octet(the last octet sent out from transmitter) is
// the end of a multiframe
// returns 0 if the octet is not the end of a multiframe
    return (is_ctrl_word && octet == global_dec::F);
endfunction


function bit ila_info_extractor::is_end_ila(byte octet, bit is_ctrl_word);
// returns 1 if the octet(the first octet sent out from transmitter) marks the
// end of ILA
// returns 0 if the octet is not the end of ILA
    return is_end_multiframe(octet, is_ctrl_word) && 
        (this.no_multiframe == ila_length-1);
endfunction


function bit ila_info_extractor::is_octetvalue_correct(
    byte octet, bit is_ctrl_word);
// returns 1 if the octetValue is correct
// returns 0 otherwise
    return (!is_ctrl_word && octet == this.octet_value);
endfunction


function void ila_info_extractor::extract_ila_info(erb_trans frame);
// given an input frame, we test the start of ILA, then extract the information
// according to the link configuraion mapping
    for(int idx = frame.data.size()-1; i >= 0; i--) begin
        process_single_octet(frame.data[idx], frame.is_control_word[idx]);
    end
endfunction


function void ila_info_extractor::print_conf_data();
// prints all link configuraion data
    $display("============== ILA Link Configuraion Data Start ==============");
    $display("DID: 0x%h", this.DID);
    $display("BID: 0x%h", this.BID);
    $display("ADJCNT: %0d", this.ADJCNT);
    $display("LID: 0x%h", this.LID);
    $display("PHADJ: %b", this.PHADJ);
    $display("ADJDIR: %b", this.ADJDIR);
    $display("L: %0d", this.L);
    $display("SCR: %b", this.SCR);
    $display("F: %0d", this.F);
    $display("K: %0d", this.K);
    $display("M: %0d", this.M);
    $display("N: %0d", this.N);
    $display("CS: %0d", this.CS);
    $display("N': %0d", this.N_apostrophe);
    $display("SUBCLASSV: %0d", this.SUBCLASSV);
    $display("S: %0d", this.S);
    $display("JESDV: %0d", this.JESDV);
    $display("CF: %0d", this.CF);
    $display("HD: %b", this.HD);
    $display("RES1: %h", this.RES1);
    $display("RES2: %h", this.RES2);
    $display("FCHK: %h", this.FCHK);
    $display("============== ILA Link Configuraion Data End ================");
endfunction

endclass: ila_info_extractor
