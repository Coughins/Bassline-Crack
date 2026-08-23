if (variable_instance_exists(id, "hc_wall_left") && instance_exists(hc_wall_left)) {
    instance_destroy(hc_wall_left);
}
if (variable_instance_exists(id, "hc_wall_right") && instance_exists(hc_wall_right)) {
    instance_destroy(hc_wall_right);
}

with (oDNATest) visible = true;
if (instance_exists(oAvoidanceController)) {
    oAvoidanceController.dna_veil = 1;
}
