import cgs2erb_monitor_dec::*;
class erb;
circular_buffer#(erb_trans) buffer;
// 1 - ILA's beginning symbol R(K28.0) has been detected and fed into buffer
// 0 - no ILA's beginning symbol R(K28.0) has been detected
bit ila_start_detected;

function new(int size);
    // argument size is the max number of frames a ERB can store, it's
    // different with RBD
    ila_start_detected = 1'b0;
    buffer = new(size);
endfunction


function bit put(erb_trans item, ifsstate_e ifsstate);
// returns 1 if a frame is successfully been fed into Elastic RX Buffer,
// returns 0 if the buffer is full or it does not accept frames yet(haven't
// received ILA yet)
    if (ifsstate == FS_INIT) begin
        // Elastic RX Buffer will not be fed when we are still in
        // early synchronization stage
        ila_start_detected = 1'b0;
        buffer.reset();
        return 0;
    end

    if (item.data[item.data.size()-1] == cgs2erb_monitor_dec::R &&
        item.is_control_word[item.is_control_word.size()-1]) begin
        // It is start of ILA, begin to feed frame into the buffer
        ila_start_detected = 1'b1;
        if (buffer.put(item))
            return 1;
        else
            return 0;
    end

    if (ila_start_detected) begin
        // ILA has been detected already, Elastic RX Buffer continues to take
        // in frames now
        if (buffer.put(item))
            return 1;
        else
            return 0;
    end

    return 0;
endfunction


function bit get(erb_trans frame);
// returns 1 if Elastic RX Buffer released a frame
// returns 0 if no frame is released because of buffer is empty or release
// condition has not been met yet
endfunction
endclass: erb
