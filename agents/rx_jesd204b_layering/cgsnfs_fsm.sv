import cgsnfs_dec::*;
class CGS_StateMachine;
    cgsstate_e currentState;
    cgsstate_e nextState;
    bit [2:0] kcounter;
    bit [1:0] icounter;
    bit [2:0] vcounter;
    // in software FSM, transition is called event, data/stimulus from
    // external associated with the event is event data
    // In this FSM, event data to cause transition is decoded symbol from
    // deser2dec_monitor
    decoder_8b10b_trans eventData;

    function new();
        currentState = CS_INIT;
        kcounter = 3'd0;
        icounter = 2'd0;
        vcounter = 3'd0;
    endfunction

    extern function void update_currentstate();
    extern function void get_nextstate(decoder_8b10b_trans eventData);
    // do things based on current state and updated cgsnfs_trans
    extern function void state_func(cgsnfs_trans cgs);
endclass

function void CGS_StateMachine::update_currentstate();
    currentState = nextState;
endfunction

function void CGS_StateMachine::get_nextstate(decoder_8b10b_trans eventData);
    case(currentState)
        CS_INIT: begin
            if (kcounter == 3'd4)
                nextState = CS_CHECK;
            else
                nextState = CS_INIT;
        end
        CS_CHECK: begin
            if (icounter == 2'd3)
                nextState = CS_INIT;
            else if (vcounter == 3'd4)
                nextState = CS_DATA;
            else
                nextState = CS_CHECK;
        end
        CS_DATA: begin
            if(eventData.disparity_error || eventData.not_in_table_error)
                nextState = CS_CHECK;
            else
                nextState = CS_DATA;
        end
        default: nextState = CS_INIT;
    endcase
endfunction

function void CGS_StateMachine::state_func(cgsnfs_trans cgs);
    cgs.cgsstate = currentState;
    case(currentState)
        CS_INIT: begin
            icounter = 2'd0;
            vcounter = 3'd0;
            cgs.sync_request = 1'b1;
            // only check if it's a control and valid, if the check passes
            // then we check if it's a K28.5 symbol, so we don't need to
            // constantly check all 3 conditions
            if (cgs.is_control_word && cgs.valid) begin
                if (cgs.data == K)
                    kcounter++;
                else
                    kcounter = 3'd0;
            end else
                kcounter = 3'd0;
        end
        CS_CHECK: begin
            cgs.sync_request = 1'b0;
            kcounter = 3'd0;
            if (!cgs.valid) begin
                icounter++;
                vcounter = 3'd0;
            end else
                vcounter++;
        end
        CS_DATA: begin
            icounter = 2'd0;
            vcounter = 3'd0;
        end
        default: begin
            icounter = 2'd0;
            vcounter = 3'd0;
            cgs.sync_request = 1'b1;
            // only check if it's a control and valid, if the check passes
            // then we check if it's a K28.5 symbol, so we don't need to
            // constantly check all 3 conditions
            if (cgs.is_control_word && cgs.valid) begin
                if (cgs.data == K)
                    kcounter++;
                else
                    kcounter = 3'd0;
            end else
                kcounter = 3'd0;
        end
    endcase
endfunction

class IFS_StateMachine;
    rx_jesd204b_layering_config m_cfg;
    ifsstate_e currentState;
    ifsstate_e nextState;
    bit [2:0] kcounter;
    int ocounter;
    // 0 - increment ocounter at reception of next octet
    // 1 - reset ocounter at reception of next octet
    bit reset_octet_counter;
    int previous_af_position;
    // in software FSM, transition is called event, data/stimulus from
    // external associated with the event is event data
    // In this FSM, event data to cause transition is decoded symbol from
    // CGS FSM
    cgsnfs_trans eventData;

    function new();
        currentState = FS_INIT;
        kcounter = 3'd0;
        ocounter = 0;
        reset_octet_counter = 1'b0;
        previous_af_position = 0;
    endfunction

    extern function void update_currentstate();
    extern function void get_nextstate(cgsnfs_trans eventData);
    // do things based on current state and updated cgsnfs_trans
    extern function void state_func(cgsnfs_trans cgs);
    extern function void check_alignment(cgsnfs_trans t);
    extern function bit cross_coupling();
endclass

function void IFS_StateMachine::update_currentstate();
    currentState = nextState;
endfunction

function void IFS_StateMachine::get_nextstate(cgsnfs_trans eventData);
    case(currentState)
        FS_INIT: begin
            if (!(eventData.sync_request ||
                (eventData.data == K && eventData.is_control_word)))
                nextState = FS_DATA;
            else
                nextState = FS_INIT;
        end
        FS_DATA: begin
            if (eventData.data == K && eventData.is_control_word)
                nextState = FS_CHECK;
            else
                nextState = FS_DATA;
        end
        FS_CHECK: begin
            if (kcounter == 3'd4)
                nextState = FS_INIT;
            else if (!(eventData.data == K && eventData.is_control_word))
                nextState = FS_DATA;
            else
                nextState = FS_CHECK;
        end
        default: nextState = FS_INIT;
    endcase
endfunction

function void IFS_StateMachine::state_func(cgsnfs_trans cgs);
    cgs.ifsstate = currentState;
    case(currentState)
        FS_INIT: ocounter = 0;
        FS_DATA: begin
            kcounter = 3'd0;
            if (reset_octet_counter)
                ocounter = 0;
            else
                ocounter = (ocounter + 1) % m_cfg.F;
            check_alignment(cgs);
        end
        FS_CHECK: begin
            kcounter++;
            if (reset_octet_counter)
                ocounter = 0;
            else
                ocounter = (ocounter + 1) % m_cfg.F;
            check_alignment(cgs);
        end
        default: ocounter = 0;
    endcase
endfunction

function void IFS_StateMachine::check_alignment(cgsnfs_trans t);
    if (t.is_control_word) begin
        if ((t.data == A || t.data == F) && t.valid) begin
            // discrambling enabled
            if (m_cfg.scrambling_enable)
                t.is_control_word = 1'b0;

            if (((ocounter == previous_af_position) || cross_coupling()) &&
                t.valid)
                reset_octet_counter = 1'b1;
            if (t.valid || ocounter == (m_cfg.F-1))
                previous_af_position = ocounter;
        end
    end
endfunction

function bit IFS_StateMachine::cross_coupling();
// when frame misalignment is expected to happen transmitter disable IFS
// via control interface, for now it's a PLACEHOLDER
    return 0;
endfunction
