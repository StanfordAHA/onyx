from build_cb_top import define_connect_box, generate_genesis_cb

import os
import mantle as mantle
import magma as m

param_width = 7
param_num_tracks = 8
param_feedthrough_outputs = "11111111"
param_has_constant = 0
param_default_value = 0

generate_genesis_cb(param_width, param_num_tracks, param_feedthrough_outputs, param_has_constant, param_default_value)

cb = define_connect_box(param_width, param_num_tracks, param_has_constant, param_default_value, param_feedthrough_outputs)
m.compile(cb.name, cb, output='coreir')
os.system('coreir -i ' + cb.name + '.json -o ' + cb.name + '.v')

os.system('./run_sim_7_8_11111111_0_0.sh')
