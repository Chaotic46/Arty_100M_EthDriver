cd arty_eth_100mb
open_project arty_eth_100mb.xpr

reset_runs synth_1
launch_runs synth_1
wait_on_run synth_1

launch_runs impl_1 -to_step write_bitstream -jobs 20
wait_on_run impl_1

write_hw_platform -fixed -include_bit -force -file design.xsa
