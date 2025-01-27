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

// Device identification no. 0..255
byte DID;
// Bank ID, extesion of DID, 0..15
bit [3:0] BID;
// Number of adjustment resolution steps to adjust DAC LMFC.
// In this agent, it is the number of frame clocks
bit [3:0] ADJCNT;




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
extern function bit is_processing_conf_data();
extern function bit is_octetvalue_correct(byte octet, bit is_ctrl_word);
extern function void extract_ila_info(erb_trans frame);
extern function void process_single_octet(byte octet, bit is_ctrl_word);

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

        store_conf_data(octet, is_ctrl_word);

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


function void ila_info_extractor::store_conf_data(byte octet, bit is_ctrl_word);
    if (this.no_multiframe == 1 && this.no_octet == 2) begin
        // test start of link configuraion data and mark the current
        // processing number of octet as 0
        this.no_octet_conf = 0;
    end

    if(is_processing_conf_data()) begin
        case(this.no_octet_conf)
            0: 
        endcase
        no_octet_conf++;
    end
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

endclass: ila_info_extractor
