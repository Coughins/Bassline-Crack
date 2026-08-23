function scr_dna_trigger_chain(){
    var _max_index = dna_amount - 1;

    with (oDNATest) {
        if (dna_type == 0 && dna_index == 0) {
            chain_dir = 1;
            scr_dna_chain_activate();
        }
        if (dna_type == 0 && dna_index == _max_index) {
            chain_dir = -1;
            scr_dna_chain_activate();
        }
    }
    scr_impact_pulse(1.0, 8.0, 0.6);
}