import global_dec::*;
class ila_info_extractor;
// extract information from ILA sequence

// 1 - ILA's beginning symbol R(K28.0) has been detected and fed into buffer
// 0 - no ILA's beginning symbol R(K28.0) has been detected
protected bit ila_start_detected;
// 1 - end of ILA detected
// 0 - end of ILA not detected or currently not processing an ILA
protected bit ila_end_detected;


function new(int size, int RBD);
    this.ila_start_detected = 1'b0;
    this.ila_end_detected = 1'b0;
endfunction


extern function bit is_processing_ila();
extern function bit is_start_ila(byte octet, bit is_ctrl_word);
extern function void extract_ila_info(erb_trans frame);
extern function void process_single_octet(byte octet, bit is_ctrl_word);

endclass


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
        if (is_start_ila(octet, is_ctrl_word)) begin
            `uvm_info("ILA Extractor", "Start of ILA detected", UVM_LOW)
            this.ila_start_detected = 1'b1;
            this.ila_end_detected = 1'b0;
        end
    end else begin
    end
endfunction

function bit ila_info_extractor::is_start_ila(byte octet, bit is_ctrl_word);
// returns 1 if the octet(the first octet sent out from transmitter) is
// the start of ILA
// returns 0 if the octet is not the start of ILA
    if (octet == global_dec::R && is_ctrl_word)
        return 1;
    else
        return 0;
endfunction


function void ila_info_extractor::extract_ila_info(erb_trans frame);
// given an input frame, we test the start of ILA, then extract the information
// according to the link configuraion mapping
    for(int idx = frame.data.size()-1; i >= 0; i--) begin
        process_single_octet(frame.data[idx], frame.is_control_word[idx]);
    end
endfunction

endclass: ila_info_extractor
