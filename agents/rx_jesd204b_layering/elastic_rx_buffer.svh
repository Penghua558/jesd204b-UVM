import global_dec::*;
class elastic_rx_buffer;
int RBD;

protected circular_buffer#(erb_trans) buffer;
// 1 - ILA's beginning symbol R(K28.0) has been detected and fed into buffer
// 0 - no ILA's beginning symbol R(K28.0) has been detected
protected bit ila_start_detected;
// numbr of frames passed since the start of LMFC
protected int num_frames_since_lmfc;
// 1 - ERB release condition has been met, ERB is releasing frames now
// 0 - ERB release condition has not been met yet, ERB is not releasing
// anything
protected bit release_cond_met;

function new(int size, int RBD);
    // argument size is the max number of frames a ERB can store, it's
    // different with RBD
    ila_start_detected = 1'b0;
    release_cond_met = 1'b0;
    num_frames_since_lmfc = 0;
    buffer = new(size);
    this.RBD = RBD;
endfunction


function bit put(erb_trans item, ifsstate_e ifsstate);
// returns 1 if a frame is successfully been fed into Elastic RX Buffer,
// returns 0 if the buffer is full or it does not accept frames yet(haven't
// received ILA yet)
    num_frames_since_lmfc = item.f_position;
    if (ifsstate == FS_INIT) begin
        // Elastic RX Buffer will not be fed when we are still in
        // early synchronization stage
        ila_start_detected = 1'b0;
        release_cond_met = 1'b0;
        buffer.reset();
        return 0;
    end

    if (item.data[item.data.size()-1] == global_dec::R &&
        item.is_control_word[item.is_control_word.size()-1]) begin
        // It is start of ILA, begin to feed frame into the buffer
        ila_start_detected = 1'b1;
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


function bit get(output erb_trans item);
// returns 1 if Elastic RX Buffer released a frame
// returns 0 if no frame is released because of buffer is empty or release
// condition has not been met yet
    erb_trans item_original;
    if (!ila_start_detected || buffer.is_empty())
        return 0;

    if (ila_start_detected && num_frames_since_lmfc == (RBD-1))
        release_cond_met = 1'b1;

    if (release_cond_met) begin
        if (!buffer.get(item_original))
            `uvm_fatal("ELASTIC RX BUFFER", 
            "something went wrong when tring to release elastic RX buffer")
        item = erb_trans::type_id::create("item");
        item.copy(item_original);
        return 1;
    end else
        return 0;
endfunction
endclass: elastic_rx_buffer
