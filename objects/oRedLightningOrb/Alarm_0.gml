if (instance_exists(chain_target) && !chain_target.active) {
    with (chain_target) scr_orb_chain_activate();
}
chain_target = noone;