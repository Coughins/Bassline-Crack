function scr_trigger_chain() {
    var _dormant = ds_list_create();
    with (oRedLightningOrb) { if (!active) ds_list_add(_dormant, id); }
    with (oRedOrb_2) { if (!active && chain_eligible) ds_list_add(_dormant, id); }
	with (oDNATest) { if (!active && chain_eligible) ds_list_add(_dormant, id); }
	with (oGridBullet) { if (!active && chain_eligible) ds_list_add(_dormant, id); }

    if (ds_list_size(_dormant) > 0) {
        var _starter = _dormant[| irandom(ds_list_size(_dormant) - 1)];
        with (_starter) scr_orb_chain_activate();
        scr_impact_pulse(1.0, 8.0, 0.6);
    }
    ds_list_destroy(_dormant);
}