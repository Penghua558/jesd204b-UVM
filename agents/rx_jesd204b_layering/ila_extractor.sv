class ila_extractor extends uvm_subscriber#(erb_trans);
    `uvm_component_utils(ila_extractor)

    ila_info_extractor m_ila_info_extractor;
    ila_info_extractor::ila_status_e ila_status;
    bit is_conf_data_printed;
    int fd;

    function new( string name , uvm_component parent );
        super.new( name , parent );
        is_conf_data_printed = 1'b0;
    endfunction


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m_ila_info_extractor = new();
    endfunction


    function void write(erb_trans t);
        m_ila_info_extractor.extract_ila_info(t);

        ila_status = m_ila_info_extractor.get_ila_status();
        if (ila_status == ila_info_extractor::INCOMING_ILA) begin
            is_conf_data_printed = 1'b0;
        end

        if (ila_status == ila_info_extractor::ILA_FINISHED) begin
            if (!is_conf_data_printed) begin
                is_conf_data_printed = 1'b1;
                dump_conf_data();
            end
        end
    endfunction

    
    function void dump_conf_data();
        fd = $fopen("ILA_link_configuration_data", "a");
        if (fd) begin
            $fwrite(fd, $sformatf("DID: 0x%h", m_ila_info_extractor.DID));
            $fwrite(fd, $sformatf("BID: 0x%h", m_ila_info_extractor.BID));
            $fwrite(fd, $sformatf("ADJCNT: %0d", m_ila_info_extractor.ADJCNT));
            $fwrite(fd, $sformatf("LID: 0x%h", m_ila_info_extractor.LID));
            $fwrite(fd, $sformatf("PHADJ: %b", m_ila_info_extractor.PHADJ));
            $fwrite(fd, $sformatf("ADJDIR: %b", m_ila_info_extractor.ADJDIR));
            $fwrite(fd, $sformatf("L: %0d", m_ila_info_extractor.L));
            $fwrite(fd, $sformatf("SCR: %b", m_ila_info_extractor.SCR));
            $fwrite(fd, $sformatf("F: %0d", m_ila_info_extractor.F));
            $fwrite(fd, $sformatf("K: %0d", m_ila_info_extractor.K));
            $fwrite(fd, $sformatf("M: %0d", m_ila_info_extractor.M));
            $fwrite(fd, $sformatf("N: %0d", m_ila_info_extractor.N));
            $fwrite(fd, $sformatf("CS: %0d", m_ila_info_extractor.CS));
            $fwrite(fd, $sformatf("N': %0d", 
                m_ila_info_extractor.N_apostrophe));
            $fwrite(fd, $sformatf("SUBCLASSV: %0d", 
                m_ila_info_extractor.SUBCLASSV));
            $fwrite(fd, $sformatf("S: %0d", m_ila_info_extractor.S));
            $fwrite(fd, $sformatf("JESDV: %0d", m_ila_info_extractor.JESDV));
            $fwrite(fd, $sformatf("CF: %0d", m_ila_info_extractor.CF));
            $fwrite(fd, $sformatf("HD: %b", m_ila_info_extractor.HD));
            $fwrite(fd, $sformatf("RES1: 0x%h", m_ila_info_extractor.RES1));
            $fwrite(fd, $sformatf("RES2: 0x%h", m_ila_info_extractor.RES2));
            $fwrite(fd, $sformatf("FCHK: 0x%h", m_ila_info_extractor.FCHK));
            $fclose(fd);
        end else begin
            `uvm_error("ILA EXTRACTOR", 
                "link configuration data file failed to open")
        end
    endfunction
endclass
