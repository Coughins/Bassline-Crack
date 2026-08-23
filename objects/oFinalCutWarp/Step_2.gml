
fw_steps++;

if (!fw_warped && (fw_ph > _k_fw_seal || fw_steps > _k_fw_seal + 40)) {
  fw_warped = true;
  fw_do_warp();
}
